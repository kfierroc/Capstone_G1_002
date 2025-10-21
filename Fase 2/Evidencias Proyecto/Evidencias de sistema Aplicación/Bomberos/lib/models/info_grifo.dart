/// Modelo para la tabla info_grifo
/// 
/// Representa información adicional de un grifo
class InfoGrifo {
  final int idRegGrifo; // PK
  final int idGrifo; // FK -> grifo
  final DateTime fechaRegistro;
  final String estado;
  final int rutNum; // FK -> bombero

  InfoGrifo({
    required this.idRegGrifo,
    required this.idGrifo,
    required this.fechaRegistro,
    required this.estado,
    required this.rutNum,
  });

  /// Crea una copia del modelo con campos actualizados
  InfoGrifo copyWith({
    int? idRegGrifo,
    int? idGrifo,
    DateTime? fechaRegistro,
    String? estado,
    int? rutNum,
  }) {
    return InfoGrifo(
      idRegGrifo: idRegGrifo ?? this.idRegGrifo,
      idGrifo: idGrifo ?? this.idGrifo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      estado: estado ?? this.estado,
      rutNum: rutNum ?? this.rutNum,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_reg_grifo': idRegGrifo,
      'id_grifo': idGrifo,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'rut_num': rutNum,
    };
  }

  /// Crea un InfoGrifo desde JSON de Supabase
  factory InfoGrifo.fromJson(Map<String, dynamic> json) {
    return InfoGrifo(
      idRegGrifo: json['id_reg_grifo'] as int,
      idGrifo: json['id_grifo'] as int,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      estado: json['estado'] as String,
      rutNum: json['rut_num'] as int,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_reg_grifo)
  Map<String, dynamic> toInsertData() {
    return {
      'id_grifo': idGrifo,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'rut_num': rutNum,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'id_grifo': idGrifo,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'rut_num': rutNum,
    };
  }

  @override
  String toString() {
    return 'InfoGrifo(idRegGrifo: $idRegGrifo, idGrifo: $idGrifo, estado: $estado, rutNum: $rutNum)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InfoGrifo && other.idRegGrifo == idRegGrifo;
  }

  @override
  int get hashCode => idRegGrifo.hashCode;
}
