/// Modelo para la tabla registro_v
/// 
/// Representa un registro de vivienda con su información y estado
class RegistroV {
  final int idRegistro; // PK
  final bool vigente;
  final String estado;
  final String material;
  final String tipo;
  final int pisos; // NUEVO CAMPO según esquema actualizado
  final DateTime fechaIniR;
  final DateTime? fechaFinR;
  final int idResidencia; // FK -> residencia
  final int idGrupof; // FK -> grupofamiliar

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
  });

  /// Crea una copia del modelo con campos actualizados
  RegistroV copyWith({
    int? idRegistro,
    bool? vigente,
    String? estado,
    String? material,
    String? tipo,
    int? pisos,
    DateTime? fechaIniR,
    DateTime? fechaFinR,
    int? idResidencia,
    int? idGrupof,
  }) {
    return RegistroV(
      idRegistro: idRegistro ?? this.idRegistro,
      vigente: vigente ?? this.vigente,
      estado: estado ?? this.estado,
      material: material ?? this.material,
      tipo: tipo ?? this.tipo,
      pisos: pisos ?? this.pisos,
      fechaIniR: fechaIniR ?? this.fechaIniR,
      fechaFinR: fechaFinR ?? this.fechaFinR,
      idResidencia: idResidencia ?? this.idResidencia,
      idGrupof: idGrupof ?? this.idGrupof,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_registro': idRegistro,
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String(),
      'fecha_fin_r': fechaFinR?.toIso8601String(),
      'id_residencia': idResidencia,
      'id_grupof': idGrupof,
    };
  }

  /// Crea un RegistroV desde JSON de Supabase
  factory RegistroV.fromJson(Map<String, dynamic> json) {
    return RegistroV(
      idRegistro: json['id_registro'] as int,
      vigente: json['vigente'] as bool,
      estado: json['estado'] as String,
      material: json['material'] as String,
      tipo: json['tipo'] as String,
      pisos: json['pisos'] as int,
      fechaIniR: DateTime.parse(json['fecha_ini_r'] as String),
      fechaFinR: json['fecha_fin_r'] != null 
          ? DateTime.parse(json['fecha_fin_r'] as String)
          : null,
      idResidencia: json['id_residencia'] as int,
      idGrupof: json['id_grupof'] as int,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_registro)
  Map<String, dynamic> toInsertData() {
    return {
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String(),
      'fecha_fin_r': fechaFinR?.toIso8601String(),
      'id_residencia': idResidencia,
      'id_grupof': idGrupof,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'vigente': vigente,
      'estado': estado,
      'material': material,
      'tipo': tipo,
      'pisos': pisos,
      'fecha_ini_r': fechaIniR.toIso8601String(),
      'fecha_fin_r': fechaFinR?.toIso8601String(),
      'id_residencia': idResidencia,
      'id_grupof': idGrupof,
    };
  }

  @override
  String toString() {
    return 'RegistroV(idRegistro: $idRegistro, estado: $estado, material: $material, vigente: $vigente)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegistroV && other.idRegistro == idRegistro;
  }

  @override
  int get hashCode => idRegistro.hashCode;
}
