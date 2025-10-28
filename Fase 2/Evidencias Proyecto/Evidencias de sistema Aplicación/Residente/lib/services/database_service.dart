import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

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

  /// Parsear condiciones médicas desde string a lista
  List<String> _parseMedicalConditions(String? padecimiento) {
    if (padecimiento == null || padecimiento.isEmpty) {
      return <String>[];
    }
    
    return padecimiento
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

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
      debugPrint('   - mainPhone: ${data.phoneNumber ?? "NULL"}'); // Updated to use phoneNumber from step 2
      
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
        'nomb_titular': data.fullName ?? '', // NUEVO CAMPO según esquema actualizado
        'ape_p_titular': '', // NUEVO CAMPO - se puede extraer del fullName si es necesario
        'telefono_titular': data.phoneNumber ?? '', // Updated to use phoneNumber from step 2
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
      debugPrint('🔧 Actualizando grupo familiar: $grupoId');
      debugPrint('🔧 Datos a actualizar: $updates');
      
      final response = await _client
          .from('grupofamiliar')
          .update(updates)
          .eq('id_grupof', int.parse(grupoId))
          .select()
          .single();

      debugPrint('✅ Respuesta de actualización: $response');
      
      final grupo = GrupoFamiliar.fromJson(response);
      
      debugPrint('✅ Grupo familiar actualizado exitosamente');
      debugPrint('   - Nuevo teléfono: ${grupo.telefonoTitular}');
      
      return DatabaseResult.success(
        data: grupo,
        message: 'Grupo familiar actualizado exitosamente',
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de Supabase al actualizar grupo familiar: ${e.message}');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar grupo familiar: $e');
      return DatabaseResult.error('Error al actualizar grupo familiar: ${e.toString()}');
    }
  }

  /// Actualizar teléfono principal del grupo familiar
  Future<DatabaseResult<GrupoFamiliar>> actualizarTelefonoPrincipal({
    required String grupoId,
    required String telefono,
  }) async {
    try {
      debugPrint('📝 Actualizando teléfono principal para grupo: $grupoId');
      
      final response = await _client
          .from('grupofamiliar')
          .update({'telefono_titular': telefono})
          .eq('id_grupof', int.parse(grupoId))
          .select()
          .single();

      final grupo = GrupoFamiliar.fromJson(response);
      
      return DatabaseResult.success(
        data: grupo,
        message: 'Teléfono principal actualizado exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al actualizar teléfono principal: ${e.toString()}');
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
        final cutCom = comunasResponse.first['cut_com'] as int; // Cambiado de out_com a cut_com
        debugPrint('✅ Usando comuna existente: $cutCom'); // Cambiado de outCom a cutCom
        return cutCom; // Cambiado de outCom a cutCom
      }
      
      debugPrint('⚠️ No se encontraron comunas existentes, creando comuna temporal...');
      
      // 2. Crear comuna temporal con todos los campos requeridos
      const cutComTemporal = 99999; // Cambiado de outComTemporal a cutComTemporal
      
      try {
        await _client
            .from('comunas')
            .insert({
              'cut_com': cutComTemporal, // Cambiado de out_com a cut_com
              'comuna': 'Comuna Temporal',
              'out_reg': 99, // Región temporal
              'region': 'Región Temporal',
              'out_prov': 999, // Provincia temporal
              'provincia': 'Provincia Temporal',
              'superficie': 1.0, // Superficie mínima en km²
              'geometry': 'MULTIPOLYGON(((-1 -1, 1 -1, 1 1, -1 1, -1 -1)))', // Cuadrado genérico
            })
            .select();
        
        debugPrint('✅ Comuna temporal creada: $cutComTemporal'); // Cambiado de outComTemporal a cutComTemporal
        return cutComTemporal; // Cambiado de outComTemporal a cutComTemporal
        
      } catch (e) {
        debugPrint('❌ Error al crear comuna temporal: $e');
        
        // 3. Si falla, intentar con una comuna más simple
        const cutComAlternativo = 99998; // Cambiado de outComAlternativo a cutComAlternativo
        try {
          await _client
              .from('comunas')
              .insert({
                'cut_com': cutComAlternativo, // Cambiado de out_com a cut_com
                'comuna': 'Comuna Alternativa',
                'out_reg': 98,
                'region': 'Región Alternativa',
                'out_prov': 998,
                'provincia': 'Provincia Alternativa',
                'superficie': 1.0,
                'geometry': 'MULTIPOLYGON(((-1 -1, 1 -1, 1 1, -1 1, -1 -1)))', // Cuadrado pequeño alternativo
              })
              .select();
          
          debugPrint('✅ Comuna alternativa creada: $cutComAlternativo'); // Cambiado de outComAlternativo a cutComAlternativo
          return cutComAlternativo; // Cambiado de outComAlternativo a cutComAlternativo
          
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
      int cutCom = await _obtenerComunaValida(); // Cambiado de outCom a cutCom
      
      if (cutCom == 0) { // Cambiado de outCom a cutCom
        return DatabaseResult.error('No se pudo obtener una comuna válida para crear la residencia');
      }
      
      // 2. Crear la residencia
      final idResidencia = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Asegurar que lat/lon tengan la precisión correcta para DECIMAL(9,6)
      double lat = 0.0;
      double lon = 0.0;
      
      if (data.latitude != null) {
        lat = double.parse(data.latitude!.toStringAsFixed(6));
        // Asegurar que esté dentro del rango válido para coordenadas
        if (lat < -90.0 || lat > 90.0) {
          lat = -33.448890; // Santiago por defecto
        }
      } else {
        lat = -33.448890; // Santiago por defecto
      }
      
      if (data.longitude != null) {
        lon = double.parse(data.longitude!.toStringAsFixed(6));
        // Asegurar que esté dentro del rango válido para coordenadas
        if (lon < -180.0 || lon > 180.0) {
          lon = -70.669270; // Santiago por defecto
        }
      } else {
        lon = -70.669270; // Santiago por defecto
      }
      
      final residenciaData = {
        'id_residencia': idResidencia,
        'direccion': (data.address != null && data.address!.isNotEmpty) 
            ? data.address!
            : null, // No usar dirección temporal
        'lat': lat,
        'lon': lon,
        'cut_com': cutCom, // Cambiado de out_com a cut_com
        'numero_pisos': data.numberOfFloors, // Agregar número de pisos
      };
      
      debugPrint('📝 Datos de residencia: $residenciaData');
      debugPrint('📍 Coordenadas procesadas: lat=$lat, lon=$lon');
      debugPrint('📍 Precisión: lat=${lat.toStringAsFixed(6)}, lon=${lon.toStringAsFixed(6)}');
      
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
        'pisos': data.numberOfFloors ?? 1, // NUEVO CAMPO según esquema actualizado
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
      debugPrint('📝 Datos a actualizar: $updates');
      
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
      
      // 2. Preparar datos de actualización con mapeo correcto
      final residenciaUpdates = <String, dynamic>{};
      
      // Mapear campos de RegistrationData a campos de la tabla residencia
      if (updates.containsKey('address')) {
        residenciaUpdates['direccion'] = updates['address'];
      }
      if (updates.containsKey('latitude')) {
        residenciaUpdates['lat'] = updates['latitude'];
      }
      if (updates.containsKey('longitude')) {
        residenciaUpdates['lon'] = updates['longitude'];
      }
      if (updates.containsKey('numberOfFloors')) {
        residenciaUpdates['numero_pisos'] = updates['numberOfFloors'];
      }
      // Campo eliminado - no hacer nada
      if (updates.containsKey('specialInstructions')) {
        updates.remove('specialInstructions');
      }
      
      debugPrint('📝 Datos de residencia a actualizar: $residenciaUpdates');
      
      // 3. Actualizar la residencia
      final response = await _client
          .from('residencia')
          .update(residenciaUpdates)
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

  /// Actualizar registro_v de un grupo familiar
  Future<DatabaseResult<void>> actualizarRegistroV({
    required String grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      debugPrint('📝 Actualizando registro_v para grupo: $grupoId');
      debugPrint('📝 Datos a actualizar en registro_v: $updates');
      
      // Mapear campos de RegistrationData a campos de registro_v
      final registroVUpdates = <String, dynamic>{};
      
      if (updates.containsKey('housingType')) {
        registroVUpdates['tipo'] = updates['housingType'];
      }
      if (updates.containsKey('constructionMaterial')) {
        registroVUpdates['material'] = updates['constructionMaterial'];
      }
      if (updates.containsKey('housingCondition')) {
        registroVUpdates['estado'] = updates['housingCondition'];
      }
      if (updates.containsKey('numberOfFloors')) {
        registroVUpdates['pisos'] = updates['numberOfFloors'];
      }
      debugPrint('📝 Datos de registro_v a actualizar: $registroVUpdates');
      
      // Actualizar campos básicos
      if (registroVUpdates.isNotEmpty) {
        await _client
            .from('registro_v')
            .update(registroVUpdates)
            .eq('id_grupof', int.parse(grupoId))
            .eq('vigente', true);
        debugPrint('✅ Campos de registro_v actualizados');
      }
      
      debugPrint('✅ Registro_v actualizado exitosamente');
      
      return DatabaseResult.success(
        data: null,
        message: 'Registro_v actualizado exitosamente',
      );
    } on PostgrestException catch (e) {
      debugPrint('❌ Error al actualizar registro_v: $e');
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar registro_v: $e');
      return DatabaseResult.error('Error al actualizar registro_v: ${e.toString()}');
    }
  }

  /// Obtener todos los integrantes de un grupo familiar con JOIN a info_integrante
  Future<DatabaseResult<List<Integrante>>> obtenerIntegrantes({
    required String grupoId,
  }) async {
    try {
      // Hacer JOIN con info_integrante para obtener todos los datos
      final response = await _client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_grupof', int.parse(grupoId))
          .eq('activo_i', true)
          .order('fecha_ini_i', ascending: true);

      final integrantes = (response as List)
          .map((json) => _crearIntegranteDesdeJoin(json))
          .toList();

      return DatabaseResult.success(data: integrantes);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener integrantes: ${e.toString()}');
    }
  }

  /// Crear Integrante desde el resultado del JOIN con info_integrante
  Integrante _crearIntegranteDesdeJoin(Map<String, dynamic> json) {
    final infoIntegrante = json['info_integrante'] as Map<String, dynamic>?;
    
    return Integrante(
      idIntegrante: json['id_integrante'] as int,
      activoI: json['activo_i'] as bool? ?? true,
      fechaIniI: json['fecha_ini_i'] != null 
          ? DateTime.parse(json['fecha_ini_i'] as String)
          : DateTime.now(),
      fechaFinI: json['fecha_fin_i'] != null 
          ? DateTime.parse(json['fecha_fin_i'] as String)
          : null,
      idGrupof: json['id_grupof'] as int,
      // Datos de info_integrante
      rut: json['rut'] as String? ?? '', // RUT del integrante
      edad: infoIntegrante != null ? _calcularEdad(infoIntegrante['anio_nac'] as int?) : 0,
      anioNac: infoIntegrante?['anio_nac'] as int? ?? 0,
      padecimiento: infoIntegrante?['padecimiento'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Calcular edad desde año de nacimiento
  int _calcularEdad(int? anioNac) {
    if (anioNac == null) return 0;
    return DateTime.now().year - anioNac;
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
      
      // Campos que SÍ existen en tabla integrante según esquema real
      final integranteData = {
        'id_integrante': idIntegrante, // ID manual para compatibilidad con esquema actual
        'id_grupof': int.parse(grupoId), // Convertir a int
        'activo_i': true, // Columna requerida
        'fecha_ini_i': DateTime.now().toIso8601String().split('T')[0], // Columna requerida
        // Campos que NO existen en tabla integrante según esquema real:
        // 'rut': rut, // Está en info_integrante
        // 'edad': edad, // Está en info_integrante
        // 'anio_nac': anioNac, // Está en info_integrante
        // 'padecimiento': padecimiento, // Está en info_integrante
      };

      final response = await _client
          .from('integrante')
          .insert(integranteData)
          .select()
          .single();

      // Ahora insertar en info_integrante con los datos adicionales
      final infoIntegranteData = {
        'id_integrante': idIntegrante, // FK a integrante
        'fecha_reg_ii': DateTime.now().toIso8601String().split('T')[0],
        'anio_nac': anioNac, // Este campo SÍ existe en info_integrante
        'padecimiento': padecimiento, // Este campo SÍ existe en info_integrante
      };

      await _client
          .from('info_integrante')
          .insert(infoIntegranteData);

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
      // Separar campos que van a integrante vs info_integrante
      final integranteUpdates = <String, dynamic>{};
      final infoIntegranteUpdates = <String, dynamic>{};
      
      // Campos que van a la tabla integrante
      if (updates.containsKey('activo_i')) {
        integranteUpdates['activo_i'] = updates['activo_i'];
      }
      if (updates.containsKey('fecha_ini_i')) {
        integranteUpdates['fecha_ini_i'] = updates['fecha_ini_i'];
      }
      if (updates.containsKey('fecha_fin_i')) {
        integranteUpdates['fecha_fin_i'] = updates['fecha_fin_i'];
      }
      
      // Campos que van a la tabla info_integrante
      if (updates.containsKey('anio_nac')) {
        infoIntegranteUpdates['anio_nac'] = updates['anio_nac'];
      }
      if (updates.containsKey('padecimiento')) {
        infoIntegranteUpdates['padecimiento'] = updates['padecimiento'];
      }
      
      // Actualizar tabla integrante si hay cambios
      if (integranteUpdates.isNotEmpty) {
        await _client
            .from('integrante')
            .update(integranteUpdates)
            .eq('id_integrante', int.parse(integranteId));
      }
      
      // Actualizar tabla info_integrante si hay cambios
      if (infoIntegranteUpdates.isNotEmpty) {
        await _client
            .from('info_integrante')
            .update(infoIntegranteUpdates)
            .eq('id_integrante', int.parse(integranteId));
      }
      
      // Obtener el integrante actualizado con JOIN
      final response = await _client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_integrante', int.parse(integranteId))
          .single();

      final integrante = _crearIntegranteDesdeJoin(response);
      
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
          .order('fecha_reg_m', ascending: true);

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
      // Generar ID único para la mascota
      final idMascota = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final mascotaData = {
        'id_mascota': idMascota, // Agregar ID de mascota
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
              address: null, // No especificar dirección por defecto
              latitude: null,
              longitude: null,
              phoneNumber: null, // No especificar teléfono por defecto
              // Campo alternatePhone eliminado
              housingType: null,
              numberOfFloors: null,
              constructionMaterial: null,
              housingCondition: null,
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
      // Obtener datos del integrante titular (primer integrante)
      final integranteTitular = integrantes.isNotEmpty ? integrantes.first : null;
      
      // Obtener datos del registro_v para material, tipo, estado, pisos
      String? materialVivienda;
      String? tipoVivienda;
      String? estadoVivienda;
      int? pisosVivienda;
      String? instruccionesEspeciales;
      
      if (integrantes.isNotEmpty) {
        // Buscar registro_v vigente para obtener material, tipo, estado, pisos
        try {
          final registroVResponse = await _client
              .from('registro_v')
              .select('material, tipo, estado, pisos')
              .eq('id_grupof', grupo.idGrupoF)
              .eq('vigente', true)
              .order('fecha_ini_r', ascending: false)
              .limit(1)
              .maybeSingle();
          
          if (registroVResponse != null) {
            materialVivienda = registroVResponse['material'] as String?;
            tipoVivienda = registroVResponse['tipo'] as String?;
            estadoVivienda = registroVResponse['estado'] as String?;
            pisosVivienda = registroVResponse['pisos'] as int?;
            debugPrint('📋 Datos básicos de registro_v cargados: material=$materialVivienda, tipo=$tipoVivienda, estado=$estadoVivienda, pisos=$pisosVivienda');
          }
        } catch (e) {
          debugPrint('⚠️ Error al cargar registro_v: $e');
        }
      }
      
      // Campo instrucciones_especiales eliminado del sistema

      // Extraer datos del grupo familiar usando toJson para evitar problemas de reconocimiento
      final grupoJson = grupo.toJson();
      final nombreTitular = grupoJson['nomb_titular'] as String? ?? '';
      final apellidoTitular = grupoJson['ape_p_titular'] as String? ?? '';
      final telefonoTitular = grupoJson['telefono_titular'] as String? ?? '';
      
      // Construir nombre completo solo si hay datos
      final nombreCompleto = nombreTitular.isNotEmpty || apellidoTitular.isNotEmpty 
          ? '${nombreTitular.trim()} ${apellidoTitular.trim()}'.trim()
          : 'Usuario';
      
      final registrationData = RegistrationData(
        email: grupo.email,
        rut: grupo.rutTitular,
        fullName: nombreCompleto, // Usar nombre completo construido
        phoneNumber: telefonoTitular.isNotEmpty ? telefonoTitular : 'No especificado', // Usar teléfono del grupo familiar
        mainPhone: telefonoTitular.isNotEmpty ? telefonoTitular : 'No especificado', // También asignar mainPhone
        address: residencia?.direccion,
        latitude: residencia?.lat,
        longitude: residencia?.lon,
        // Campo alternatePhone eliminado
        housingType: tipoVivienda, // Cargar desde registro_v
        numberOfFloors: residencia?.numeroPisos ?? pisosVivienda, // Priorizar residencia.numero_pisos
        constructionMaterial: materialVivienda, // Cargar desde registro_v
        housingCondition: estadoVivienda, // Cargar desde registro_v.estado
        age: integranteTitular?.edad, // ✅ Agregar edad del integrante titular
        birthYear: integranteTitular?.anioNac, // ✅ Agregar año de nacimiento
        medicalConditions: _parseMedicalConditions(integranteTitular?.padecimiento), // Cargar condiciones médicas del integrante titular
      );
      
      debugPrint('✅ Información del usuario cargada exitosamente');
      debugPrint('   - Grupo ID: ${grupo.idGrupoF}');
      debugPrint('   - Email: ${grupo.email}');
      debugPrint('   - RUT: ${grupo.rutTitular}');
      debugPrint('   - Teléfono del grupo: $telefonoTitular');
      debugPrint('   - Fecha creación: ${grupo.fechaCreacion}');
      debugPrint('   - Dirección: ${residencia?.direccion}');
      debugPrint('   - Coordenadas: ${residencia?.lat}, ${residencia?.lon}');
      debugPrint('   - Integrante titular edad: ${integranteTitular?.edad}');
      debugPrint('   - Integrante titular año nacimiento: ${integranteTitular?.anioNac}');
      debugPrint('   - Padecimiento: ${integranteTitular?.padecimiento}');
      debugPrint('   - Condiciones médicas cargadas: ${_parseMedicalConditions(integranteTitular?.padecimiento)}');
      debugPrint('   - Instrucciones especiales: $instruccionesEspeciales');
      debugPrint('   - Integrantes: ${integrantes.length}');
      debugPrint('   - Mascotas: ${mascotas.length}');
      debugPrint('   - RegistrationData.rut: ${registrationData.rut}');
      debugPrint('   - RegistrationData.phoneNumber: ${registrationData.phoneNumber}');
      debugPrint('   - RegistrationData.mainPhone: ${registrationData.mainPhone}');
      
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
      
      // Extraer el nombre del email para usarlo como nombre temporal
      final emailPart = email.split('@')[0];
      final nameParts = emailPart.split(RegExp(r'[._]'));
      final tempNombre = nameParts.isNotEmpty ? nameParts.first[0].toUpperCase() + nameParts.first.substring(1) : 'Usuario';
      final tempApellido = nameParts.length > 1 ? nameParts.last[0].toUpperCase() + nameParts.last.substring(1) : 'Temporal';
      
      final grupoData = {
        'id_grupof': idGrupoF, // ID manual para compatibilidad con esquema actual
        'rut_titular': '00000000', // RUT temporal - debe ser actualizado
        'nomb_titular': tempNombre,
        'ape_p_titular': tempApellido,
        'telefono_titular': '', // Teléfono vacío temporalmente
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
  final String nombTitular;     // NUEVO CAMPO según esquema actualizado
  final String apePTitular;     // NUEVO CAMPO según esquema actualizado
  final String telefonoTitular; // NUEVO CAMPO según esquema actualizado
  final String email;           // Email como en el esquema real
  final DateTime fechaCreacion;
  final DateTime createdAt;
  final DateTime updatedAt;

  GrupoFamiliar({
    required this.idGrupoF,
    required this.rutTitular,
    required this.nombTitular,
    required this.apePTitular,
    required this.telefonoTitular,
    required this.email,
    required this.fechaCreacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GrupoFamiliar.fromJson(Map<String, dynamic> json) {
    return GrupoFamiliar(
      idGrupoF: json['id_grupof'] as int, // Usar int directamente
      rutTitular: json['rut_titular'] as String,
      nombTitular: json['nomb_titular'] as String? ?? '',
      apePTitular: json['ape_p_titular'] as String? ?? '',
      telefonoTitular: json['telefono_titular'] as String? ?? '',
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
      'nomb_titular': nombTitular,
      'ape_p_titular': apePTitular,
      'telefono_titular': telefonoTitular,
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
      materialConstruccion: json['material'] as String?, // Corregido nombre de columna
      estadoVivienda: json['estado_vivienda'] as String?, // Puede no existir en la BD real
      telefonoPrincipal: json['telefono_principal'] as String?, // Ahora existe
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
      // 'material': materialConstruccion, // Corregido nombre de columna
      // 'estado_vivienda': estadoVivienda, // Columna no existe en la BD
      // 'telefono_principal': telefonoPrincipal, // Columna no existe en la BD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Obtener latitud (ya no escalada)
  double get latitude => lat;
  
  /// Obtener longitud (ya no escalada)
  double get longitude => lon;
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
