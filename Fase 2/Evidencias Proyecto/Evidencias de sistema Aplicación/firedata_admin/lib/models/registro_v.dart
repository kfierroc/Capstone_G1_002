/// Modelo para la tabla registro_v
/// 
/// Representa un registro de vivienda con su información y estado
class RegistroV {
  final int idRegistro; // PK
  final bool vigente;
  final String estado;
  final String material;
  final String tipo;
  final int pisos;
  final DateTime fechaIniR;
  final DateTime? fechaFinR;
  final int idResidencia; // FK -> residencia
  final int idGrupof; // FK -> grupofamiliar
  final String? instruccionesEspeciales;

  RegistroV({
    required this.idRegistro,
    required this.vigente,
    required this.estado,
    required this.material,
    required this.tipo,
    required this.pisos,
    required this.fechaIniR,
    this.fechaFinR,
    required this.idResidencia,
    required this.idGrupof,
    this.instruccionesEspeciales,
  });

  factory RegistroV.fromJson(Map<String, dynamic> json) {
    return RegistroV(
      idRegistro: json['id_registro'] is int
          ? json['id_registro'] as int
          : int.tryParse(json['id_registro']?.toString() ?? '') ?? 0,
      vigente: json['vigente'] as bool? ?? true,
      estado: json['estado']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      pisos: json['pisos'] is int
          ? json['pisos'] as int
          : int.tryParse(json['pisos']?.toString() ?? '') ?? 1,
      fechaIniR: json['fecha_ini_r'] != null
          ? DateTime.parse(json['fecha_ini_r'].toString())
          : DateTime.now(),
      fechaFinR: json['fecha_fin_r'] != null
          ? DateTime.tryParse(json['fecha_fin_r'].toString())
          : null,
      idResidencia: json['id_residencia'] is int
          ? json['id_residencia'] as int
          : int.tryParse(json['id_residencia']?.toString() ?? '') ?? 0,
      idGrupof: json['id_grupof'] is int
          ? json['id_grupof'] as int
          : int.tryParse(json['id_grupof']?.toString() ?? '') ?? 0,
      instruccionesEspeciales: json['instrucciones_especiales']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_registro': idRegistro,
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String().split('T')[0],
      'fecha_fin_r': fechaFinR?.toIso8601String().split('T')[0],
      'id_residencia': idResidencia,
      'id_grupof': idGrupof,
      'instrucciones_especiales': instruccionesEspeciales,
    };
  }

  Map<String, dynamic> toInsertData() {
    return {
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String().split('T')[0],
      'fecha_fin_r': fechaFinR?.toIso8601String().split('T')[0],
      'id_residencia': idResidencia,
      'id_grupof': idGrupof,
      'instrucciones_especiales': instruccionesEspeciales,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String().split('T')[0],
      'fecha_fin_r': fechaFinR?.toIso8601String().split('T')[0],
      'instrucciones_especiales': instruccionesEspeciales,
    };
  }
}

