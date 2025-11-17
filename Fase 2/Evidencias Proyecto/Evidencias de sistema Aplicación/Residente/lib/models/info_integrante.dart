/// Modelo para la tabla info_integrante
/// 
/// Representa información adicional de un integrante
class InfoIntegrante {
  final int idIntegrante; // PK FK -> integrante
  final DateTime fechaRegIi;
  final int anioNac;
  final String? padecimiento;

  InfoIntegrante({
    required this.idIntegrante,
    required this.fechaRegIi,
    required this.anioNac,
    this.padecimiento,
  });

  /// Crea una copia del modelo con campos actualizados
  InfoIntegrante copyWith({
    int? idIntegrante,
    DateTime? fechaRegIi,
    int? anioNac,
    String? padecimiento,
  }) {
    return InfoIntegrante(
      idIntegrante: idIntegrante ?? this.idIntegrante,
      fechaRegIi: fechaRegIi ?? this.fechaRegIi,
      anioNac: anioNac ?? this.anioNac,
      padecimiento: padecimiento ?? this.padecimiento,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_integrante': idIntegrante,
      'fecha_reg_ii': fechaRegIi.toIso8601String(),
      'anio_nac': anioNac, // Nombre correcto de columna según esquema real
    };
    
    // Solo incluir padecimiento si no es null ni vacío
    if (padecimiento != null && padecimiento!.isNotEmpty) {
      data['padecimiento'] = padecimiento;
    }
    
    return data;
  }

  /// Crea un InfoIntegrante desde JSON de Supabase
  factory InfoIntegrante.fromJson(Map<String, dynamic> json) {
    return InfoIntegrante(
      idIntegrante: json['id_integrante'] as int,
      fechaRegIi: DateTime.parse(json['fecha_reg_ii'] as String),
      anioNac: json['anio_nac'] as int, // Nombre correcto de columna según esquema real
      padecimiento: json['padecimiento'] as String?,
    );
  }

  /// Crear datos para inserción en Supabase
  Map<String, dynamic> toInsertData() {
    final data = <String, dynamic>{
      'id_integrante': idIntegrante,
      'fecha_reg_ii': fechaRegIi.toIso8601String(),
      'anio_nac': anioNac, // Nombre correcto de columna según esquema real
    };
    
    // Solo incluir padecimiento si no es null ni vacío
    if (padecimiento != null && padecimiento!.isNotEmpty) {
      data['padecimiento'] = padecimiento;
    }
    
    return data;
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    final data = <String, dynamic>{
      'fecha_reg_ii': fechaRegIi.toIso8601String(),
      'anio_nac': anioNac, // Nombre correcto de columna según esquema real
    };
    
    // Solo incluir padecimiento si no es null ni vacío
    if (padecimiento != null && padecimiento!.isNotEmpty) {
      data['padecimiento'] = padecimiento;
    }
    
    return data;
  }

  @override
  String toString() {
    return 'InfoIntegrante(idIntegrante: $idIntegrante, anioNac: $anioNac, padecimiento: $padecimiento)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InfoIntegrante && other.idIntegrante == idIntegrante;
  }

  @override
  int get hashCode => idIntegrante.hashCode;
}
