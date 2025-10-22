/// Modelo para la tabla grupofamiliar
/// 
/// Representa un grupo familiar con solo id estándar
class GrupoFamiliar {
  final int idGrupof; // PK
  final String rutTitular;
  final String nombTitular; // NUEVO CAMPO según esquema actualizado
  final String apePTitular; // NUEVO CAMPO según esquema actualizado
  final String telefonoTitular; // NUEVO CAMPO según esquema actualizado
  final String email;
  final DateTime fechaCreacion;

  GrupoFamiliar({
    required this.idGrupof,
    required this.rutTitular,
    required this.nombTitular,
    required this.apePTitular,
    required this.telefonoTitular,
    required this.email,
    required this.fechaCreacion,
  });

  /// Crea una copia del modelo con campos actualizados
  GrupoFamiliar copyWith({
    int? idGrupof,
    String? rutTitular,
    String? nombTitular,
    String? apePTitular,
    String? telefonoTitular,
    String? email,
    DateTime? fechaCreacion,
  }) {
    return GrupoFamiliar(
      idGrupof: idGrupof ?? this.idGrupof,
      rutTitular: rutTitular ?? this.rutTitular,
      nombTitular: nombTitular ?? this.nombTitular,
      apePTitular: apePTitular ?? this.apePTitular,
      telefonoTitular: telefonoTitular ?? this.telefonoTitular,
      email: email ?? this.email,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_grupof': idGrupof,
      'rut_titular': rutTitular,
      'nomb_titular': nombTitular,
      'ape_p_titular': apePTitular,
      'telefono_titular': telefonoTitular,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crea un GrupoFamiliar desde JSON de Supabase
  factory GrupoFamiliar.fromJson(Map<String, dynamic> json) {
    return GrupoFamiliar(
      idGrupof: json['id_grupof'] as int,
      rutTitular: json['rut_titular'] as String,
      nombTitular: json['nomb_titular'] as String? ?? '',
      apePTitular: json['ape_p_titular'] as String? ?? '',
      telefonoTitular: json['telefono_titular'] as String? ?? '',
      email: json['email'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  /// Crear datos para inserción en Supabase (sin id_grupof)
  Map<String, dynamic> toInsertData() {
    return {
      'rut_titular': rutTitular,
      'nomb_titular': nombTitular,
      'ape_p_titular': apePTitular,
      'telefono_titular': telefonoTitular,
      'email': email,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'rut_titular': rutTitular,
      'nomb_titular': nombTitular,
      'ape_p_titular': apePTitular,
      'telefono_titular': telefonoTitular,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'GrupoFamiliar(idGrupof: $idGrupof, rutTitular: $rutTitular, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrupoFamiliar && other.idGrupof == idGrupof;
  }

  @override
  int get hashCode => idGrupof.hashCode;
}
