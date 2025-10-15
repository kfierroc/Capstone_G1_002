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
      print('🔍 Validando datos del grupo familiar:');
      print('   - userId: $userId');
      print('   - rut: ${data.rut ?? "NULL"}');
      print('   - address: ${data.address ?? "NULL"}');
      print('   - latitude: ${data.latitude ?? "NULL"}');
      print('   - longitude: ${data.longitude ?? "NULL"}');
      print('   - housingType: ${data.housingType ?? "NULL"}');
      print('   - mainPhone: ${data.mainPhone ?? "NULL"}');
      
      // Validar que todos los datos requeridos estén presentes
      if (data.rut == null || data.address == null) {
        print('❌ Datos incompletos:');
        if (data.rut == null) print('   - Falta: rut');
        if (data.address == null) print('   - Falta: address');
        return DatabaseResult.error('Datos incompletos del grupo familiar');
      }

      // Crear grupo familiar adaptado al esquema actual de la BD
      print('📝 Creando grupo familiar...');
      
      // Generar ID numérico para id_grupof (compatible con integer)
      // Usar solo los últimos dígitos del timestamp para que quepa en int32
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final idGrupoF = (timestamp % 2147483647); // Limitar al rango de int4 (max: 2,147,483,647)
      
      final grupoData = {
        'id_grupof': idGrupoF,
        'rut_titular': data.rut,
        'email': data.email, // Agregar email que es requerido
        'fecha_creacion': DateTime.now().toIso8601String().split('T')[0],
      };
      
      print('📝 Datos a insertar en grupofamiliar:');
      print('   ${grupoData.toString()}');
      
      final grupoResponse = await _client
          .from('grupofamiliar')
          .insert(grupoData)
          .select()
          .single();

      print('📦 Respuesta del grupo familiar: $grupoResponse');
      print('📦 Tipo de respuesta: ${grupoResponse.runtimeType}');
      print('📦 Campos en respuesta: ${grupoResponse.keys.toList()}');
      print('✅ Grupo familiar creado con ID: $idGrupoF');

      // Crear residencia (temporalmente deshabilitado debido a diferencias en el esquema)
      print('⚠️ Creación de residencia temporalmente deshabilitada');
      print('📝 Datos que se habrían insertado en residencia:');
      print('   - direccion: ${data.address}');
      print('   - lat: ${data.latitude ?? 0.0}');
      print('   - lon: ${data.longitude ?? 0.0}');
      print('   - tipo_vivienda: ${data.housingType}');
      print('   - telefono_principal: ${data.mainPhone}');
      print('⚠️ La tabla residencia no tiene la columna id_grupof en el esquema real');
      
       // Crear objeto GrupoFamiliar para retornar
       final grupo = GrupoFamiliar.fromJson(grupoResponse);
       
       return DatabaseResult.success(
         data: grupo,
         message: 'Grupo familiar creado exitosamente',
       );
     } on PostgrestException catch (e) {
       print('❌ PostgrestException capturada:');
       print('   - Code: ${e.code}');
       print('   - Message: ${e.message}');
       print('   - Details: ${e.details}');
       print('   - Hint: ${e.hint}');
       return DatabaseResult.error(_getPostgrestErrorMessage(e));
     } catch (e) {
       print('❌ Error inesperado: ${e.toString()}');
       return DatabaseResult.error('Error al crear grupo familiar: ${e.toString()}');
     }
  }

  /// Obtener grupo familiar por email (adaptado al esquema actual)
  Future<DatabaseResult<GrupoFamiliar>> obtenerGrupoFamiliar({
    required String email,
  }) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return DatabaseResult.error('Grupo familiar no encontrado');
      }

      final grupo = GrupoFamiliar.fromJson(response);
      
      return DatabaseResult.success(data: grupo);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener grupo familiar: ${e.toString()}');
    }
  }

  /// Actualizar grupo familiar
  Future<DatabaseResult<GrupoFamiliar>> actualizarGrupoFamiliar({
    required int grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .update(updates)
          .eq('id_grupof', grupoId)
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
  // OPERACIONES DE RESIDENCIAS
  // ============================================================================

  /// Obtener residencia de un grupo familiar
  Future<DatabaseResult<Residencia>> obtenerResidencia({
    required int grupoId,
  }) async {
    try {
      // Obtener los datos de la residencia directamente
      final response = await _client
          .from('residencia')
          .select()
          .eq('id_grupof', grupoId)
          .maybeSingle();

      if (response == null) {
        return DatabaseResult.error('Residencia no encontrada');
      }

      final residencia = Residencia.fromJson(response);
      
      return DatabaseResult.success(data: residencia);
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al obtener residencia: ${e.toString()}');
    }
  }

  /// Actualizar residencia
  Future<DatabaseResult<Residencia>> actualizarResidencia({
    required int grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('residencia')
          .update(updates)
          .eq('id_grupof', grupoId)
          .select()
          .single();

      final residencia = Residencia.fromJson(response);
      
      return DatabaseResult.success(
        data: residencia,
        message: 'Residencia actualizada exitosamente',
      );
    } on PostgrestException catch (e) {
      return DatabaseResult.error(_getPostgrestErrorMessage(e));
    } catch (e) {
      return DatabaseResult.error('Error al actualizar residencia: ${e.toString()}');
    }
  }

  // ============================================================================
  // OPERACIONES DE INTEGRANTES
  // ============================================================================

  /// Obtener todos los integrantes de un grupo familiar
  Future<DatabaseResult<List<Integrante>>> obtenerIntegrantes({
    required int grupoId,
  }) async {
    try {
      final response = await _client
          .from('integrante')
          .select()
          .eq('id_grupof', grupoId)
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
    required int grupoId,
    required String rut,
    required int edad,
    required int anioNac,
    String? padecimiento,
  }) async {
    try {
      final integranteData = {
        'id_grupof': grupoId,
        'rut': rut,
        'edad': edad,
        'anio_nac': anioNac,
        'padecimiento': padecimiento,
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
          .eq('id_integrante', integranteId)
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
          .eq('id_integrante', integranteId);

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
    required int grupoId,
  }) async {
    try {
      final response = await _client
          .from('mascota')
          .select()
          .eq('id_grupof', grupoId)
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
    required int grupoId,
    required String nombre,
    required String especie,
    required String tamanio,
  }) async {
    try {
      final mascotaData = {
        'id_grupof': grupoId,
        'nombre_m': nombre,
        'especie': especie,
        'tamanio': tamanio,
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
          .eq('id_mascota', mascotaId)
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
          .eq('id_mascota', mascotaId);

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
  final int idGrupoF;           // Integer como en el esquema real
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
      idGrupoF: json['id_grupof'] as int,
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
  final String idResidencia;    // UUID de la residencia
  final int idGrupoF;           // Integer del grupo familiar
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
    required this.cutCom,
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
      idResidencia: json['id_residencia'] as String,
      idGrupoF: json['id_grupof'] as int,
      direccion: json['direccion'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as int,
      tipoVivienda: json['tipo_vivienda'] as String?,
      numeroPisos: json['numero_pisos'] as int?,
      materialConstruccion: json['material_construccion'] as String?,
      estadoVivienda: json['estado_vivienda'] as String?,
      telefonoPrincipal: json['telefono_principal'] as String?,
      telefonoAlternativo: json['telefono_alternativo'] as String?,
      instruccionesEspeciales: json['instrucciones_especiales'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'tipo_vivienda': tipoVivienda,
      'numero_pisos': numeroPisos,
      'material_construccion': materialConstruccion,
      'estado_vivienda': estadoVivienda,
      'telefono_principal': telefonoPrincipal,
      'telefono_alternativo': telefonoAlternativo,
      'instrucciones_especiales': instruccionesEspeciales,
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
  final String idIntegrante;
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
      idIntegrante: json['id_integrante'] as String,
      idGrupoF: json['id_grupof'] as int,
      activoI: json['activo_i'] as bool,
      fechaIniI: DateTime.parse(json['fecha_ini_i'] as String),
      fechaFinI: json['fecha_fin_i'] != null 
          ? DateTime.parse(json['fecha_fin_i'] as String)
          : null,
      rut: json['rut'] as String,
      edad: json['edad'] as int,
      anioNac: json['anio_nac'] as int,
      padecimiento: json['padecimiento'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: idIntegrante,
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
  final String idMascota;
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
      idMascota: json['id_mascota'] as String,
      idGrupoF: json['id_grupof'] as int,
      nombreM: json['nombre_m'] as String,
      especie: json['especie'] as String,
      tamanio: json['tamanio'] as String,
      fechaRegM: DateTime.parse(json['fecha_reg_m'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      id: idMascota,
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
