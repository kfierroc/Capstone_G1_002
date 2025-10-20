import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/registration_data.dart';
import '../models/family_member.dart';
import '../models/pet.dart';

/// Servicio de base de datos actualizado para el modelo de datos del usuario
/// 
/// Maneja todas las operaciones de la base de datos para:
/// - Grupos familiares (grupofamiliar)
/// - Residencias (residencia)
/// - Integrantes (integrante)
/// - Mascotas (mascota)
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Obtener el cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  // ============================================================================
  // OPERACIONES DE GRUPOS FAMILIARES
  // ============================================================================

  /// Crear grupo familiar completo (grupo + residencia)
  /// 
  /// Debe llamarse después de que el usuario se registre
  Future<DatabaseResult<GrupoFamiliar>> crearGrupoFamiliar({
    required String userId,
    required RegistrationData data,
  }) async {
    try {
      debugPrint('🔍 Validando datos del grupo familiar:');
      debugPrint('   - userId: $userId');
      debugPrint('   - rut: ${data.rut ?? "NULL"}');
      debugPrint('   - address: ${data.address ?? "NULL"}');
      debugPrint('   - latitude: ${data.latitude ?? "NULL"}');
      debugPrint('   - longitude: ${data.longitude ?? "NULL"}');
      debugPrint('   - housingType: ${data.housingType ?? "NULL"}');
      debugPrint('   - mainPhone: ${data.mainPhone ?? "NULL"}');
      
      // Validar que todos los datos requeridos estén presentes
      if (data.rut == null || data.address == null) {
        debugPrint('❌ Datos incompletos:');
        if (data.rut == null) debugPrint('   - Falta: rut');
        if (data.address == null) debugPrint('   - Falta: address');
        return DatabaseResult.error('Datos incompletos del grupo familiar');
      }

      // Crear grupo familiar adaptado al esquema actual de la BD
      debugPrint('📝 Creando grupo familiar...');
      
      // Generar ID manualmente para id_grupof (compatible con INTEGER)
      final idGrupoF = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Usar segundos en lugar de milisegundos
      
      final grupoData = {
        'id_grupof': idGrupoF, // ID manual para compatibilidad con esquema actual
        'rut_titular': data.rut,
        'email': data.email, // Agregar email que es requerido
        'fecha_creacion': DateTime.now().toIso8601String().split('T')[0],
      };
      
      debugPrint('📝 Datos a insertar en grupofamiliar:');
      debugPrint('   ${grupoData.toString()}');
      
      final grupoResponse = await _client
          .from('grupofamiliar')
          .insert(grupoData)
          .select()
          .single();

      debugPrint('📦 Respuesta del grupo familiar: $grupoResponse');
      debugPrint('📦 Tipo de respuesta: ${grupoResponse.runtimeType}');
      debugPrint('📦 Campos en respuesta: ${grupoResponse.keys.toList()}');
      debugPrint('✅ Grupo familiar creado con ID: ${grupoResponse['id_grupof']}');

       // Crear residencia usando el método público
       debugPrint('📝 Creando residencia y registro_v...');
       
       final grupo = GrupoFamiliar.fromJson(grupoResponse);
       
       try {
         // Usar el método público crearResidencia que maneja residencia + registro_v
        await crearResidencia(
          grupoId: grupo.idGrupoF.toString(),
          data: data,
        );
         debugPrint('✅ Residencia y registro_v creados exitosamente');
       } catch (e) {
         debugPrint('❌ Error al crear residencia: $e');
         debugPrint('   - Tipo de error: ${e.runtimeType}');
         if (e is PostgrestException) {
           debugPrint('   - Código: ${e.code}');
           debugPrint('   - Mensaje: ${e.message}');
           debugPrint('   - Detalles: ${e.details}');
           debugPrint('   - Hint: ${e.hint}');
         }
         debugPrint('   - Continuando sin residencia...');
       }
      
       // Crear objeto GrupoFamiliar para retornar
       
       return DatabaseResult.success(
         data: grupo,
         message: 'Grupo familiar creado exitosamente',
       );
     } on PostgrestException catch (e) {
       debugPrint('❌ PostgrestException capturada:');
       debugPrint('   - Code: ${e.code}');
       debugPrint('   - Message: ${e.message}');
       debugPrint('   - Details: ${e.details}');
       debugPrint('   - Hint: ${e.hint}');
       return DatabaseResult.error(_getPostgrestErrorMessage(e));
     } catch (e) {
       debugPrint('❌ Error inesperado: ${e.toString()}');
       return DatabaseResult.error('Error al crear grupo familiar: ${e.toString()}');
     }
  }

  /// Obtener grupo familiar por email (adaptado al esquema actual)
  Future<DatabaseResult<GrupoFamiliar>> obtenerGrupoFamiliar({
    required String email,
  }) async {
    try {
      debugPrint('🔍 Buscando grupo familiar para email: $email');
      
      // Primero, intentar obtener todos los grupos familiares para debugging
      debugPrint('🔍 Verificando todos los grupos familiares en la base de datos...');
      final allGroupsResponse = await _client
          .from('grupofamiliar')
          .select('id_grupof, email, rut_titular, fecha_creacion')
          .limit(10);
      
      debugPrint('📊 Total de grupos familiares encontrados: ${allGroupsResponse.length}');
      for (int i = 0; i < allGroupsResponse.length; i++) {
        final group = allGroupsResponse[i];
        debugPrint('   Grupo $i: id="${group['id_grupof']}", email="${group['email']}", rut="${group['rut_titular']}", fecha="${group['fecha_creacion']}"');
      }
      
      // Verificar específicamente si hay múltiples registros para el email buscado
      final duplicateCheck = await _client
          .from('grupofamiliar')
          .select('id_grupof, email, rut_titular, fecha_creacion')
          .eq('email', email);
      
      debugPrint('🔍 Verificación de duplicados para $email:');
      debugPrint('   - Registros encontrados: ${duplicateCheck.length}');
      for (int i = 0; i < duplicateCheck.length; i++) {
        final duplicate = duplicateCheck[i];
        debugPrint('   - Duplicado $i: id="${duplicate['id_grupof']}", rut="${duplicate['rut_titular']}", fecha="${duplicate['fecha_creacion']}"');
      }
      
      // Si hay múltiples registros, eliminar los registros migrados (con "Sin RUT")
      if (duplicateCheck.length > 1) {
        debugPrint('🔍 Limpiando registros duplicados...');
        for (final duplicate in duplicateCheck) {
          if (duplicate['rut_titular'] == 'Sin RUT') {
            debugPrint('🗑️ Eliminando registro migrado: ${duplicate['id_grupof']}');
            try {
              await _client
                  .from('grupofamiliar')
                  .delete()
                  .eq('id_grupof', duplicate['id_grupof']);
              debugPrint('✅ Registro migrado eliminado');
            } catch (e) {
              debugPrint('❌ Error al eliminar registro migrado: $e');
            }
          }
        }
      }
      
      // Ahora buscar el grupo específico (priorizar el más antiguo)
      debugPrint('🔍 Buscando grupo familiar específico para: $email');
      final response = await _client
          .from('grupofamiliar')
          .select()
          .eq('email', email)
          .order('fecha_creacion', ascending: true) // Priorizar el más antiguo
          .limit(1)
          .maybeSingle();

      debugPrint('📦 Respuesta de la consulta específica: $response');

      if (response == null) {
        debugPrint('❌ No se encontró grupo familiar para el email: $email');
        return DatabaseResult.error('Grupo familiar no encontrado');
      }

      debugPrint('✅ Grupo familiar encontrado: $response');
      final grupo = GrupoFamiliar.fromJson(response);
      
      return DatabaseResult.success(data: grupo);
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException en obtenerGrupoFamiliar:');
      debugPrint('   - Code: ${e.code}');
      debugPrint('   - Message: ${e.message}');
      debugPrint('   - Details: ${e.details}');
      debugPrint('   - Hint: ${e.hint}');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado en obtenerGrupoFamiliar: $e');
      return DatabaseResult.error('Error al obtener grupo familiar: ${e.toString()}');
    }
  }

  /// Actualizar grupo familiar
  Future<DatabaseResult<GrupoFamiliar>> actualizarGrupoFamiliar({
    required String grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .update(updates)
          .eq('id_grupof', int.parse(grupoId))
          .select()
          .single();

      final grupo = GrupoFamiliar.fromJson(response);
      
      return DatabaseResult.success(
        data: grupo,
        message: 'Grupo familiar actualizado exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al actualizar grupo familiar: ${e.toString()}');
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA COMUNAS
  // ============================================================================

  /// Desactivar registros_v antiguos para un grupo familiar
  Future<void> _desactivarRegistrosAntiguos(String grupoId) async {
    try {
      await _client
          .from('registro_v')
          .update({'vigente': false})
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true);
      
      debugPrint('✅ Registros antiguos desactivados para grupo: $grupoId');
    } catch (e) {
      debugPrint('⚠️ Error al desactivar registros antiguos: $e');
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA COMUNAS
  // ============================================================================

  /// Obtiene una comuna válida para crear residencias
  /// Primero busca comunas existentes, si no hay ninguna crea una temporal válida
  Future<int> _obtenerComunaValida() async {
    try {
      // 1. Buscar comunas existentes
      final comunasResponse = await _client
          .from('comunas')
          .select('cut_com')
          .limit(1);
      
      if (comunasResponse.isNotEmpty) {
        final cutCom = comunasResponse.first['cut_com'] as int;
        debugPrint('✅ Usando comuna existente: $cutCom');
        return cutCom;
      }
      
      debugPrint('⚠️ No se encontraron comunas existentes, creando comuna temporal...');
      
      // 2. Crear comuna temporal con todos los campos requeridos
      const cutComTemporal = 99999;
      
      try {
        await _client
            .from('comunas')
            .insert({
              'cut_com': cutComTemporal,
              'comuna': 'Comuna Temporal',
              'cut_reg': 99, // Región temporal
              'region': 'Región Temporal',
              'cut_prov': 999, // Provincia temporal
              'provincia': 'Provincia Temporal',
              'superficie': 1.0, // Superficie mínima en km²
              'geometry': 'MULTIPOLYGON(((-1 -1, 1 -1, 1 1, -1 1, -1 -1)))', // Cuadrado genérico
            })
            .select();
        
        debugPrint('✅ Comuna temporal creada: $cutComTemporal');
        return cutComTemporal;
        
      } catch (e) {
        debugPrint('❌ Error al crear comuna temporal: $e');
        
        // 3. Si falla, intentar con una comuna más simple
        const cutComAlternativo = 99998;
        try {
          await _client
              .from('comunas')
              .insert({
                'cut_com': cutComAlternativo,
                'comuna': 'Comuna Alternativa',
                'cut_reg': 98,
                'region': 'Región Alternativa',
                'cut_prov': 998,
                'provincia': 'Provincia Alternativa',
                'superficie': 1.0,
                'geometry': 'MULTIPOLYGON(((-1 -1, 1 -1, 1 1, -1 1, -1 -1)))', // Cuadrado pequeño alternativo
              })
              .select();
          
          debugPrint('✅ Comuna alternativa creada: $cutComAlternativo');
          return cutComAlternativo;
          
        } catch (e2) {
          debugPrint('❌ Error al crear comuna alternativa: $e2');
          return 0; // Indica error
        }
      }
      
    } catch (e) {
      debugPrint('❌ Error al buscar comunas: $e');
      return 0; // Indica error
    }
  }

  // ============================================================================
  // OPERACIONES DE RESIDENCIAS
  // ============================================================================

  /// Crear residencia para un grupo familiar
  Future<DatabaseResult<Residencia>> crearResidencia({
    required String grupoId,
    required RegistrationData data,
  }) async {
    try {
      debugPrint('📝 Creando residencia y registro_v para grupo: $grupoId');
      
      // 1. Buscar una comuna existente primero
      int cutCom = await _obtenerComunaValida();
      
      if (cutCom == 0) {
        return DatabaseResult.error('No se pudo obtener una comuna válida para crear la residencia');
      }
      
      // 2. Crear la residencia
      final idResidencia = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final residenciaData = {
        'id_residencia': idResidencia,
        // 'id_grupof': int.parse(grupoId), // Esta columna no existe en residencia, se maneja en registro_v
        'direccion': (data.address != null && data.address!.isNotEmpty) 
            ? data.address!
            : 'Dirección temporal $idResidencia', // Usar ID único para evitar duplicados
        'lat': data.latitude != null ? double.parse(data.latitude!.toStringAsFixed(1)) : 0.0,
        'lon': data.longitude != null ? double.parse(data.longitude!.toStringAsFixed(1)) : 0.0,
        'cut_com': cutCom, // Usar el código de comuna válido
        // Solo incluir campos que existen en la BD real
        if (data.housingType != null) 'tipo_vivienda': data.housingType,
        if (data.numberOfFloors != null) 'numero_pisos': data.numberOfFloors,
        if (data.constructionMaterial != null) 'material_construccion': data.constructionMaterial,
        if (data.mainPhone != null) 'telefono_principal': data.mainPhone,
        if (data.alternatePhone != null) 'telefono_alternativo': data.alternatePhone,
        if (data.specialInstructions != null) 'instrucciones_especiales': data.specialInstructions,
        // Comentar campos que no existen en la BD real
        // 'estado_vivienda': data.housingCondition, // No existe en la BD real
      };
      
      debugPrint('📝 Datos de residencia: $residenciaData');
      
      final residenciaResponse = await _client
          .from('residencia')
          .insert(residenciaData)
          .select()
          .single();
          
      debugPrint('✅ Residencia creada: ${residenciaResponse['id_residencia']}');
      
      // 3. Desactivar registros antiguos para evitar duplicados
      await _desactivarRegistrosAntiguos(grupoId);
      
      // 4. Crear el registro_v para relacionar grupo con residencia
      final idRegistro = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1; // Diferente al id_residencia
      
      final registroVData = {
        'id_registro': idRegistro,
        'id_residencia': idResidencia, // Usar int directamente
        'id_grupof': int.parse(grupoId), // Convertir String a int
        'vigente': true,
        'estado': 'Activo',
        'material': data.constructionMaterial,
        'tipo': data.housingType,
        'fecha_ini_r': DateTime.now().toIso8601String().split('T')[0],
      };
      
      debugPrint('📝 Datos de registro_v: $registroVData');
      
      await _client
          .from('registro_v')
          .insert(registroVData)
          .select()
          .single();
          
      debugPrint('✅ Registro_v creado: $idRegistro');
      
      final residencia = Residencia.fromJson(residenciaResponse);
      
      return DatabaseResult.success(
        data: residencia,
        message: 'Residencia y registro creados exitosamente',
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Error al crear residencia: $e');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado al crear residencia: $e');
      return DatabaseResult.error('Error al crear residencia: ${e.toString()}');
    }
  }

  /// Obtener residencia de un grupo familiar
  Future<DatabaseResult<Residencia>> obtenerResidencia({
    required String grupoId,
  }) async {
    try {
      debugPrint('🔍 Buscando residencia para grupo: $grupoId');
      
      // Obtener residencia a través de registro_v
      final response = await _client
          .from('registro_v')
          .select('''
            id_registro,
            id_residencia,
            id_grupof,
            vigente,
            estado,
            material,
            tipo,
            fecha_ini_r,
            fecha_fin_r,
            residencia:residencia(*)
          ''')
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true)
          .order('fecha_ini_r', ascending: false) // Ordenar por fecha más reciente
          .limit(1)
          .maybeSingle();

      if (response == null) {
        debugPrint('❌ No se encontró registro_v vigente para grupo: $grupoId');
        return DatabaseResult.error('Residencia no encontrada');
      }

      debugPrint('✅ Registro_v encontrado: ${response['id_registro']}');
      
      // Extraer datos de la residencia desde la relación
      final residenciaData = response['residencia'] as Map<String, dynamic>?;
      if (residenciaData == null) {
        debugPrint('❌ No se encontraron datos de residencia en la relación');
        return DatabaseResult.error('Datos de residencia no encontrados');
      }

      final residencia = Residencia.fromJson(residenciaData);
      
      return DatabaseResult.success(data: residencia);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error al obtener residencia: $e');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener residencia: $e');
      return DatabaseResult.error('Error al obtener residencia: ${e.toString()}');
    }
  }

  /// Actualizar residencia
  Future<DatabaseResult<Residencia>> actualizarResidencia({
    required String grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      debugPrint('📝 Actualizando residencia para grupo: $grupoId');
      
      // 1. Obtener el registro_v vigente para encontrar la residencia
      final registroResponse = await _client
          .from('registro_v')
          .select('id_residencia')
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true)
          .order('fecha_ini_r', ascending: false) // Ordenar por fecha más reciente
          .limit(1)
          .maybeSingle();

      if (registroResponse == null) {
        debugPrint('❌ No se encontró registro_v vigente para grupo: $grupoId');
        return DatabaseResult.error('No se encontró residencia asociada al grupo');
      }

      final idResidencia = registroResponse['id_residencia'];
      debugPrint('✅ Residencia encontrada: $idResidencia');
      
      if (idResidencia == null) {
        debugPrint('❌ ID de residencia es null');
        return DatabaseResult.error('ID de residencia no encontrado');
      }
      
      // 2. Actualizar la residencia
      final response = await _client
          .from('residencia')
          .update(updates)
          .eq('id_residencia', int.parse(idResidencia.toString()))
          .select()
          .single();

      final residencia = Residencia.fromJson(response);
      
      return DatabaseResult.success(
        data: residencia,
        message: 'Residencia actualizada exitosamente',
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Error al actualizar residencia: $e');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar residencia: $e');
      return DatabaseResult.error('Error al actualizar residencia: ${e.toString()}');
    }
  }

  // ============================================================================
  // OPERACIONES DE INTEGRANTES
  // ============================================================================

  /// Obtener todos los integrantes de un grupo familiar
  Future<DatabaseResult<List<Integrante>>> obtenerIntegrantes({
    required String grupoId,
  }) async {
    try {
      final response = await _client
          .from('integrante')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .eq('activo_i', true)
          .order('created_at', ascending: true);

      final integrantes = (response as List)
          .map((json) => Integrante.fromJson(json))
          .toList();

      return DatabaseResult.success(data: integrantes);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener integrantes: ${e.toString()}');
    }
  }

  /// Agregar integrante al grupo familiar
  Future<DatabaseResult<Integrante>> agregarIntegrante({
    required String grupoId,
    required String rut,
    required int edad,
    required int anioNac,
    String? padecimiento,
  }) async {
    try {
      // Generar ID manualmente para integrante
      final idIntegrante = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final integranteData = {
        'id_integrante': idIntegrante, // ID manual para compatibilidad con esquema actual
        'id_grupof': int.parse(grupoId), // Convertir a int
        'activo_i': true, // Columna requerida
        'fecha_ini_i': DateTime.now().toIso8601String().split('T')[0], // Columna requerida
        'rut': rut, // Ahora existe en la BD real
        'edad': edad, // Ahora existe en la BD real
        'anio_nac': anioNac, // Ahora existe en la BD real
        'padecimiento': padecimiento, // Ahora existe en la BD real
      };

      final response = await _client
          .from('integrante')
          .insert(integranteData)
          .select()
          .single();

      final integrante = Integrante.fromJson(response);
      
      return DatabaseResult.success(
        data: integrante,
        message: 'Integrante agregado exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al agregar integrante: ${e.toString()}');
    }
  }

  /// Actualizar integrante
  Future<DatabaseResult<Integrante>> actualizarIntegrante({
    required String integranteId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('integrante')
          .update(updates)
          .eq('id_integrante', int.parse(integranteId))
          .select()
          .single();

      final integrante = Integrante.fromJson(response);
      
      return DatabaseResult.success(
        data: integrante,
        message: 'Integrante actualizado exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al actualizar integrante: ${e.toString()}');
    }
  }

  /// Eliminar integrante (marcar como inactivo)
  Future<DatabaseResult<void>> eliminarIntegrante({
    required String integranteId,
  }) async {
    try {
      await _client
          .from('integrante')
          .update({
            'activo_i': false,
            'fecha_fin_i': DateTime.now().toIso8601String().split('T')[0],
          })
          .eq('id_integrante', int.parse(integranteId));

      return DatabaseResult.success(
        data: null,
        message: 'Integrante eliminado exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al eliminar integrante: ${e.toString()}');
    }
  }

  // ============================================================================
  // OPERACIONES DE MASCOTAS
  // ============================================================================

  /// Obtener todas las mascotas de un grupo familiar
  Future<DatabaseResult<List<Mascota>>> obtenerMascotas({
    required String grupoId,
  }) async {
    try {
      final response = await _client
          .from('mascota')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .order('created_at', ascending: true);

      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();

      return DatabaseResult.success(data: mascotas);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener mascotas: ${e.toString()}');
    }
  }

  /// Agregar mascota al grupo familiar
  Future<DatabaseResult<Mascota>> agregarMascota({
    required String grupoId,
    required String nombre,
    required String especie,
    required String tamanio,
  }) async {
    try {
      // Generar ID manualmente para mascota
      final idMascota = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final mascotaData = {
        'id_mascota': idMascota, // ID manual para compatibilidad con esquema actual
        'id_grupof': int.parse(grupoId), // Convertir a int
        'nombre_m': nombre,
        'especie': especie,
        'tamanio': tamanio,
        'fecha_reg_m': DateTime.now().toIso8601String().split('T')[0], // Agregar fecha de registro
      };

      final response = await _client
          .from('mascota')
          .insert(mascotaData)
          .select()
          .single();

      final mascota = Mascota.fromJson(response);
      
      return DatabaseResult.success(
        data: mascota,
        message: 'Mascota agregada exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al agregar mascota: ${e.toString()}');
    }
  }

  /// Actualizar mascota
  Future<DatabaseResult<Mascota>> actualizarMascota({
    required String mascotaId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('mascota')
          .update(updates)
          .eq('id_mascota', int.parse(mascotaId))
          .select()
          .single();

      final mascota = Mascota.fromJson(response);
      
      return DatabaseResult.success(
        data: mascota,
        message: 'Mascota actualizada exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al actualizar mascota: ${e.toString()}');
    }
  }

  /// Eliminar mascota
  Future<DatabaseResult<void>> eliminarMascota({
    required String mascotaId,
  }) async {
    try {
      await _client
          .from('mascota')
          .delete()
          .eq('id_mascota', int.parse(mascotaId));

      return DatabaseResult.success(
        data: null,
        message: 'Mascota eliminada exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al eliminar mascota: ${e.toString()}');
    }
  }

  // ============================================================================
  // OPERACIONES DE COMUNAS
  // ============================================================================

  /// Obtener todas las comunas
  Future<DatabaseResult<List<Comuna>>> obtenerComunas() async {
    try {
      final response = await _client
          .from('comunas')
          .select()
          .order('comuna', ascending: true);

      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();

      return DatabaseResult.success(data: comunas);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener comunas: ${e.toString()}');
    }
  }

  // ============================================================================
  // OPERACIONES COMPLETAS DE USUARIO
  // ============================================================================

  /// Cargar toda la información del usuario (grupo familiar + residencia + integrantes + mascotas)
  Future<DatabaseResult<Map<String, dynamic>>> cargarInformacionCompletaUsuario({
    required String email,
  }) async {
    try {
      debugPrint('🔍 Cargando información completa del usuario: $email');
      
      // 1. Obtener grupo familiar
      final grupoResult = await obtenerGrupoFamiliar(email: email);
      if (!grupoResult.isSuccess) {
        debugPrint('⚠️ Grupo familiar no encontrado para $email');
        debugPrint('🔍 Verificando si el usuario realmente no existe...');
        
        // Verificar si realmente no existe consultando directamente
        try {
          final directResponse = await _client
              .from('grupofamiliar')
              .select('email, rut_titular')
              .eq('email', email)
              .maybeSingle();
          
          if (directResponse != null) {
            debugPrint('⚠️ El usuario SÍ existe en la BD pero hay un problema con obtenerGrupoFamiliar');
            debugPrint('   - Email encontrado: ${directResponse['email']}');
            debugPrint('   - RUT: ${directResponse['rut_titular']}');
            return DatabaseResult.error('Error al cargar datos del usuario. Contacta al soporte técnico.');
          }
        } catch (e) {
          debugPrint('❌ Error al verificar existencia directa: $e');
        }
        
        debugPrint('🔍 Usuario realmente no existe, intentando migrar...');
        
        // Intentar migrar usuario existente solo si realmente no existe
        final migracionResult = await _migrarUsuarioExistente(email: email);
        if (!migracionResult.isSuccess) {
          return DatabaseResult.error('No se encontró información del usuario. Asegúrate de completar el registro correctamente. Error de migración: ${migracionResult.error}');
        }
        
        debugPrint('✅ Usuario migrado exitosamente: ${migracionResult.data!.idGrupoF}');
      } else {
        debugPrint('✅ Grupo familiar encontrado: ${grupoResult.data!.idGrupoF}');
      }
      
      // Obtener el grupo familiar final
      final grupoFinalResult = await obtenerGrupoFamiliar(email: email);
      if (!grupoFinalResult.isSuccess) {
        return DatabaseResult.error('Error al obtener grupo familiar');
      }
      
      final grupo = grupoFinalResult.data!;
      
      // 2. Obtener residencia
      debugPrint('🔍 Buscando residencia para grupo: ${grupo.idGrupoF}');
      final residenciaResult = await obtenerResidencia(grupoId: grupo.idGrupoF.toString());
      Residencia? residencia = residenciaResult.isSuccess ? residenciaResult.data : null;
      
      if (residencia == null) {
        debugPrint('⚠️ No se encontró residencia para el grupo ${grupo.idGrupoF}');
        debugPrint('   - Esto significa que no se creó la residencia durante el registro');
        debugPrint('   - Creando residencia automáticamente...');
        
        try {
          // Crear residencia automáticamente para usuarios existentes
          final residenciaResult = await crearResidencia(
            grupoId: grupo.idGrupoF.toString(),
            data: RegistrationData(
              email: grupo.email,
              rut: grupo.rutTitular,
              address: 'Dirección no especificada',
              latitude: 0.0,
              longitude: 0.0,
              mainPhone: 'Sin teléfono',
              alternatePhone: null,
              housingType: 'No especificado',
              numberOfFloors: 1,
              constructionMaterial: 'No especificado',
              housingCondition: 'No especificado',
              specialInstructions: 'Usuario migrado - información por completar',
            ),
          );
          
          if (residenciaResult.isSuccess) {
            debugPrint('✅ Residencia creada automáticamente para usuario existente');
            // Recargar la residencia recién creada
            final nuevaResidenciaResult = await obtenerResidencia(grupoId: grupo.idGrupoF.toString());
            if (nuevaResidenciaResult.isSuccess) {
              residencia = nuevaResidenciaResult.data;
              debugPrint('✅ Residencia cargada: ${residencia?.direccion}');
            }
          } else {
            debugPrint('❌ Error al crear residencia automáticamente: ${residenciaResult.error}');
          }
        } catch (e) {
          debugPrint('❌ Error al crear residencia automáticamente: $e');
        }
      } else {
        debugPrint('✅ Residencia encontrada: ${residencia.direccion}');
      }
      
      // 3. Obtener integrantes
      final integrantesResult = await obtenerIntegrantes(grupoId: grupo.idGrupoF.toString());
      final integrantes = integrantesResult.isSuccess ? integrantesResult.data ?? [] : [];
      
      // 4. Obtener mascotas
      final mascotasResult = await obtenerMascotas(grupoId: grupo.idGrupoF.toString());
      final mascotas = mascotasResult.isSuccess ? mascotasResult.data ?? [] : [];
      
      // 5. Construir RegistrationData con la información obtenida
      final registrationData = RegistrationData(
        email: grupo.email,
        rut: grupo.rutTitular,
        fullName: null, // No se guarda en la BD actual
        phoneNumber: residencia?.telefonoPrincipal,
        address: residencia?.direccion,
        latitude: residencia?.lat,
        longitude: residencia?.lon,
        mainPhone: residencia?.telefonoPrincipal,
        alternatePhone: residencia?.telefonoAlternativo,
        housingType: residencia?.tipoVivienda,
        numberOfFloors: residencia?.numeroPisos,
        constructionMaterial: residencia?.materialConstruccion,
        housingCondition: residencia?.estadoVivienda,
        specialInstructions: residencia?.instruccionesEspeciales,
      );
      
      debugPrint('✅ Información del usuario cargada exitosamente');
      debugPrint('   - Grupo ID: ${grupo.idGrupoF}');
      debugPrint('   - Email: ${grupo.email}');
      debugPrint('   - RUT: ${grupo.rutTitular}');
      debugPrint('   - Fecha creación: ${grupo.fechaCreacion}');
      debugPrint('   - Dirección: ${residencia?.direccion}');
      debugPrint('   - Teléfono: ${residencia?.telefonoPrincipal}');
      debugPrint('   - Integrantes: ${integrantes.length}');
      debugPrint('   - Mascotas: ${mascotas.length}');
      
      // Verificar si los datos parecen ser de migración
      if (grupo.rutTitular == 'Sin RUT') {
        debugPrint('⚠️ ADVERTENCIA: Se está cargando un usuario migrado con datos por defecto');
        debugPrint('   - Esto sugiere que el usuario real no se está encontrando correctamente');
        debugPrint('   - Verificar si hay múltiples registros para el mismo email');
      }
      
      return DatabaseResult.success(
        data: {
          'registrationData': registrationData,
          'grupoFamiliar': grupo,
          'residencia': residencia,
          'integrantes': integrantes,
          'mascotas': mascotas,
        },
        message: 'Información del usuario cargada exitosamente',
      );
      
    } catch (e) {
      debugPrint('❌ Error al cargar información del usuario: $e');
      return DatabaseResult.error('Error al cargar información del usuario: ${e.toString()}');
    }
  }

  /// Migrar usuario existente que no tiene grupo familiar en la base de datos
  Future<DatabaseResult<GrupoFamiliar>> _migrarUsuarioExistente({
    required String email,
  }) async {
    try {
      debugPrint('🔍 Migrando usuario existente: $email');
      
      // Obtener el user_id del usuario autenticado
      // final authService = AuthService();
      // final userId = authService.userId;
      
      // if (userId == null) {
      //   return DatabaseResult.error('No se pudo obtener el ID del usuario autenticado');
      // }
      
      // Generar ID manualmente para id_grupof (compatible con INTEGER)
      final idGrupoF = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Usar segundos en lugar de milisegundos
      
      final grupoData = {
        'id_grupof': idGrupoF, // ID manual para compatibilidad con esquema actual
        // 'user_id': userId, // Comentado temporalmente hasta que se actualice el esquema
        'rut_titular': 'Sin RUT', // Valor temporal que se puede actualizar
        'email': email,
        'fecha_creacion': DateTime.now().toIso8601String().split('T')[0],
      };
      
      debugPrint('📝 Datos a insertar en grupofamiliar para migración:');
      debugPrint('   ${grupoData.toString()}');
      
      final response = await _client
          .from('grupofamiliar')
          .insert(grupoData)
          .select()
          .single();

      final grupo = GrupoFamiliar.fromJson(response);
      
      debugPrint('✅ Usuario migrado exitosamente: ${grupo.idGrupoF}');
      
      return DatabaseResult.success(
        data: grupo,
        message: 'Usuario migrado exitosamente',
      );
    } catch (e) {
      debugPrint('❌ Error al migrar usuario: $e');
      return DatabaseResult.error('Error al migrar usuario: ${e.toString()}');
    }
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  /// Obtener mensaje de error amigable para errores de Postgrest
  String _getPostgrestErrorMessage(PostgrestException error) {
    if (error.message.contains('duplicate key')) {
      return 'Este registro ya existe';
    } else if (error.message.contains('foreign key')) {
      return 'Error de referencia: verifica que los datos relacionados existan';
    } else if (error.message.contains('violates check constraint')) {
      return 'Los datos no cumplen con las validaciones requeridas';
    } else {
      return error.message;
    }
  }
}

// ============================================================================
// MODELOS ACTUALIZADOS
// ============================================================================

/// Modelo de Grupo Familiar (grupofamiliar) - Adaptado al esquema real
class GrupoFamiliar {
  final int idGrupoF;           // INTEGER como en el esquema real
  final String rutTitular;
  final String email;           // Email como en el esquema real
  final DateTime fechaCreacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrupoFamiliar({
    required this.idGrupoF,
    required this.rutTitular,
    required this.email,
    required this.fechaCreacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GrupoFamiliar.fromJson(Map<String, dynamic> json) {
    return GrupoFamiliar(
      idGrupoF: json['id_grupof'] as int, // Usar int directamente
      rutTitular: json['rut_titular'] as String,
      email: json['email'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_grupof': idGrupoF,
      'rut_titular': rutTitular,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Modelo de Residencia (adaptado al esquema real)
class Residencia {
  final int idResidencia;    // INTEGER de la residencia
  final int idGrupoF;           // INTEGER del grupo familiar
  final String direccion;
  final double lat;             // Coordenadas como double
  final double lon;             // Coordenadas como double
  final int cutCom;
  final String? tipoVivienda;
  final int? numeroPisos;
  final String? materialConstruccion;
  final String? estadoVivienda;
  final String? telefonoPrincipal;
  final String? telefonoAlternativo;
  final String? instruccionesEspeciales;
  final DateTime createdAt;
  final DateTime updatedAt;

  Residencia({
    required this.idResidencia,
    required this.idGrupoF,
    required this.direccion,
    required this.lat,
    required this.lon,
    required this.cutCom, // Requerido ya que lo estamos enviando
    this.tipoVivienda,
    this.numeroPisos,
    this.materialConstruccion,
    this.estadoVivienda,
    this.telefonoPrincipal,
    this.telefonoAlternativo,
    this.instruccionesEspeciales,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Residencia.fromJson(Map<String, dynamic> json) {
    return Residencia(
      idResidencia: json['id_residencia'] as int, // Usar int directamente
      idGrupoF: 0, // Esta columna no existe en residencia, se maneja en registro_v
      direccion: json['direccion'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as int,
      tipoVivienda: json['tipo_vivienda'] as String?, // Ahora existe
      numeroPisos: json['numero_pisos'] as int?, // Ahora existe
      materialConstruccion: json['material_construccion'] as String?, // Ahora existe
      estadoVivienda: json['estado_vivienda'] as String?, // Puede no existir en la BD real
      telefonoPrincipal: json['telefono_principal'] as String?, // Ahora existe
      telefonoAlternativo: json['telefono_alternativo'] as String?, // Ahora existe
      instruccionesEspeciales: json['instrucciones_especiales'] as String?, // Ahora existe
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_residencia': idResidencia,
      'id_grupof': idGrupoF,
      'direccion': direccion,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
      // 'tipo_vivienda': tipoVivienda, // Columna no existe en la BD
      // 'numero_pisos': numeroPisos, // Columna no existe en la BD
      // 'material_construccion': materialConstruccion, // Columna no existe en la BD
      // 'estado_vivienda': estadoVivienda, // Columna no existe en la BD
      // 'telefono_principal': telefonoPrincipal, // Columna no existe en la BD
      // 'telefono_alternativo': telefonoAlternativo, // Columna no existe en la BD
      // 'instrucciones_especiales': instruccionesEspeciales, // Columna no existe en la BD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Obtener latitud (ya no escalada)
  double get latitude => lat;
  
  /// Obtener longitud (ya no escalada)
  double get longitude => lon;
}

/// Modelo de Integrante (actualizado)
class Integrante {
  final int idIntegrante;
  final int idGrupoF;
  final bool activoI;
  final DateTime fechaIniI;
  final DateTime? fechaFinI;
  final String rut;
  final int edad;
  final int anioNac;
  final String? padecimiento;
  final DateTime createdAt;
  final DateTime updatedAt;

  Integrante({
    required this.idIntegrante,
    required this.idGrupoF,
    required this.activoI,
    required this.fechaIniI,
    this.fechaFinI,
    required this.rut,
    required this.edad,
    required this.anioNac,
    this.padecimiento,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Integrante.fromJson(Map<String, dynamic> json) {
    return Integrante(
      idIntegrante: json['id_integrante'] as int, // Usar int directamente
      idGrupoF: json['id_grupof'] as int, // Usar int directamente
      activoI: json['activo_i'] as bool? ?? true,
      fechaIniI: json['fecha_ini_i'] != null 
          ? DateTime.parse(json['fecha_ini_i'] as String)
          : DateTime.now(),
      fechaFinI: json['fecha_fin_i'] != null 
          ? DateTime.parse(json['fecha_fin_i'] as String)
          : null,
      rut: json['rut'] as String? ?? '',
      edad: json['edad'] as int? ?? 0,
      anioNac: json['anio_nac'] as int? ?? 0,
      padecimiento: json['padecimiento'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_integrante': idIntegrante,
      'id_grupof': idGrupoF,
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String(),
      'fecha_fin_i': fechaFinI?.toIso8601String(),
      'rut': rut,
      'edad': edad,
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convertir a FamilyMember (para compatibilidad)
  FamilyMember toFamilyMember() {
    return FamilyMember(
      id: idIntegrante.toString(),
      residentId: idGrupoF.toString(),
      rut: rut,
      age: edad,
      birthYear: anioNac,
      conditions: padecimiento != null ? [padecimiento!] : [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Modelo de Mascota (actualizado)
class Mascota {
  final int idMascota;
  final int idGrupoF;
  final String nombreM;
  final String especie;
  final String tamanio;
  final DateTime fechaRegM;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mascota({
    required this.idMascota,
    required this.idGrupoF,
    required this.nombreM,
    required this.especie,
    required this.tamanio,
    required this.fechaRegM,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      idMascota: json['id_mascota'] as int, // Usar int directamente
      idGrupoF: json['id_grupof'] as int, // Usar int directamente
      nombreM: json['nombre_m'] as String? ?? '',
      especie: json['especie'] as String? ?? '',
      tamanio: json['tamanio'] as String? ?? '',
      fechaRegM: json['fecha_reg_m'] != null 
          ? DateTime.parse(json['fecha_reg_m'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mascota': idMascota,
      'id_grupof': idGrupoF,
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convertir a Pet (para compatibilidad)
  Pet toPet() {
    return Pet(
      id: idMascota.toString(),
      residentId: idGrupoF.toString(),
      name: nombreM,
      species: especie,
      size: tamanio,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Modelo de Comuna
class Comuna {
  final int cutCom;
  final String comuna;
  final int cutReg;
  final String region;
  final int cutProv;
  final String provincia;
  final double superficie;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comuna({
    required this.cutCom,
    required this.comuna,
    required this.cutReg,
    required this.region,
    required this.cutProv,
    required this.provincia,
    required this.superficie,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comuna.fromJson(Map<String, dynamic> json) {
    return Comuna(
      cutCom: json['cut_com'] as int,
      comuna: json['comuna'] as String,
      cutReg: json['cut_reg'] as int,
      region: json['region'] as String,
      cutProv: json['cut_prov'] as int,
      provincia: json['provincia'] as String,
      superficie: json['superficie'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cut_com': cutCom,
      'comuna': comuna,
      'cut_reg': cutReg,
      'region': region,
      'cut_prov': cutProv,
      'provincia': provincia,
      'superficie': superficie,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Modelo de Registro V (para relacionar grupo familiar con residencia)
class RegistroV {
  final int idRegistro;
  final int idResidencia;
  final int idGrupoF;
  final bool vigente;
  final String estado;
  final String? material;
  final String? tipo;
  final DateTime fechaIniR;
  final DateTime? fechaFinR;

  RegistroV({
    required this.idRegistro,
    required this.idResidencia,
    required this.idGrupoF,
    required this.vigente,
    required this.estado,
    this.material,
    this.tipo,
    required this.fechaIniR,
    this.fechaFinR,
  });

  factory RegistroV.fromJson(Map<String, dynamic> json) {
    return RegistroV(
      idRegistro: json['id_registro'] as int,
      idResidencia: json['id_residencia'] as int,
      idGrupoF: json['id_grupof'] as int,
      vigente: json['vigente'] as bool,
      estado: json['estado'] as String,
      material: json['material'] as String?,
      tipo: json['tipo'] as String?,
      fechaIniR: DateTime.parse(json['fecha_ini_r'] as String),
      fechaFinR: json['fecha_fin_r'] != null 
          ? DateTime.parse(json['fecha_fin_r'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_registro': idRegistro,
      'id_residencia': idResidencia,
      'id_grupof': idGrupoF,
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'fecha_ini_r': fechaIniR.toIso8601String().split('T')[0],
      'fecha_fin_r': fechaFinR?.toIso8601String().split('T')[0],
    };
  }
}

/// Resultado de operaciones de base de datos (reutilizado)
class DatabaseResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;

  DatabaseResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });

  /// Resultado exitoso
  factory DatabaseResult.success({
    required T? data,
    String? message,
  }) {
    return DatabaseResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  /// Resultado con error
  factory DatabaseResult.error(String error) {
    return DatabaseResult._(
      isSuccess: false,
      error: error,
    );
  }
}
