/// Modelo para la tabla mascota
class Mascota {
  final int idMascota; // PK
  final String nombreM;
  final String especie;
  final String tamanio;
  final DateTime fechaRegM;
  final int idGrupof; // FK -> grupofamiliar

  Mascota({
    required this.idMascota,
    required this.nombreM,
    required this.especie,
    required this.tamanio,
    required this.fechaRegM,
    required this.idGrupof,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      idMascota: json['id_mascota'] is int
          ? json['id_mascota'] as int
          : int.tryParse(json['id_mascota']?.toString() ?? '') ?? 0,
      nombreM: json['nombre_m']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      tamanio: json['tamanio']?.toString() ?? '',
      fechaRegM: json['fecha_reg_m'] != null
          ? DateTime.parse(json['fecha_reg_m'].toString())
          : DateTime.now(),
      idGrupof: json['id_grupof'] is int
          ? json['id_grupof'] as int
          : int.tryParse(json['id_grupof']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mascota': idMascota,
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    };
  }

  Map<String, dynamic> toInsertData() {
    return {
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String().split('T')[0],
    };
  }
}

