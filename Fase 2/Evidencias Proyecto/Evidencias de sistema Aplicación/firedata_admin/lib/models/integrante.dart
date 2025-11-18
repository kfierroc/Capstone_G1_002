/// Modelo para la tabla integrante
class Integrante {
  final int idIntegrante; // PK
  final bool activoI;
  final DateTime fechaIniI;
  final DateTime? fechaFinI;
  final int idGrupof; // FK -> grupofamiliar

  Integrante({
    required this.idIntegrante,
    required this.activoI,
    required this.fechaIniI,
    this.fechaFinI,
    required this.idGrupof,
  });

  factory Integrante.fromJson(Map<String, dynamic> json) {
    return Integrante(
      idIntegrante: json['id_integrante'] is int
          ? json['id_integrante'] as int
          : int.tryParse(json['id_integrante']?.toString() ?? '') ?? 0,
      activoI: json['activo_i'] as bool? ?? true,
      fechaIniI: json['fecha_ini_i'] != null
          ? DateTime.parse(json['fecha_ini_i'].toString())
          : DateTime.now(),
      fechaFinI: json['fecha_fin_i'] != null
          ? DateTime.tryParse(json['fecha_fin_i'].toString())
          : null,
      idGrupof: json['id_grupof'] is int
          ? json['id_grupof'] as int
          : int.tryParse(json['id_grupof']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_integrante': idIntegrante,
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String().split('T')[0],
      'fecha_fin_i': fechaFinI?.toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    };
  }

  Map<String, dynamic> toInsertData() {
    return {
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String().split('T')[0],
      'fecha_fin_i': fechaFinI?.toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    };
  }
}

