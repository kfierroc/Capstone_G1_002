/// Modelo para la tabla info_integrante
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

  factory InfoIntegrante.fromJson(Map<String, dynamic> json) {
    return InfoIntegrante(
      idIntegrante: json['id_integrante'] is int
          ? json['id_integrante'] as int
          : int.tryParse(json['id_integrante']?.toString() ?? '') ?? 0,
      fechaRegIi: json['fecha_reg_ii'] != null
          ? DateTime.parse(json['fecha_reg_ii'].toString())
          : DateTime.now(),
      anioNac: json['anio_nac'] is int
          ? json['anio_nac'] as int
          : int.tryParse(json['anio_nac']?.toString() ?? '') ?? 2000,
      padecimiento: json['padecimiento']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_integrante': idIntegrante,
      'fecha_reg_ii': fechaRegIi.toIso8601String().split('T')[0],
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    };
  }

  Map<String, dynamic> toInsertData() {
    return {
      'id_integrante': idIntegrante,
      'fecha_reg_ii': fechaRegIi.toIso8601String().split('T')[0],
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'fecha_reg_ii': fechaRegIi.toIso8601String().split('T')[0],
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    };
  }
}

