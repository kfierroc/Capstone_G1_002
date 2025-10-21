/// Modelo para la tabla grupofamiliar
/// 
/// Representa un grupo familiar con autenticación de Supabase
/// IMPORTANTE: No maneja contraseñas, usa Supabase Auth
class GrupoFamiliar {
  final int idGrupof; // PK
  final String rutTitular;
  final String email;
  final DateTime fechaCreacion;
  final String? authUserId; // UUID UNIQUE para conectar con Supabase Auth

  GrupoFamiliar({
    required this.idGrupof,
    required this.rutTitular,
    required this.email,
    required this.fechaCreacion,
    this.authUserId,
  });

  /// Crea una copia del modelo con campos actualizados
  GrupoFamiliar copyWith({
    int? idGrupof,
    String? rutTitular,
    String? email,
    DateTime? fechaCreacion,
    String? authUserId,
  }) {
    return GrupoFamiliar(
      idGrupof: idGrupof ?? this.idGrupof,
      rutTitular: rutTitular ?? this.rutTitular,
      email: email ?? this.email,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      authUserId: authUserId ?? this.authUserId,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_grupof': idGrupof,
      'rut_titular': rutTitular,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'auth_user_id': authUserId,
    };
  }

  /// Crea un GrupoFamiliar desde JSON de Supabase
  factory GrupoFamiliar.fromJson(Map<String, dynamic> json) {
    return GrupoFamiliar(
      idGrupof: json['id_grupof'] as int,
      rutTitular: json['rut_titular'] as String,
      email: json['email'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      authUserId: json['auth_user_id'] as String?,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_grupof)
  Map<String, dynamic> toInsertData() {
    return {
      'rut_titular': rutTitular,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'auth_user_id': authUserId,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'rut_titular': rutTitular,
      'email': email,
      'auth_user_id': authUserId,
    };
  }

  @override
  String toString() {
    return 'GrupoFamiliar(idGrupof: $idGrupof, rutTitular: $rutTitular, email: $email, authUserId: $authUserId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrupoFamiliar && other.idGrupof == idGrupof;
  }

  @override
  int get hashCode => idGrupof.hashCode;
}
