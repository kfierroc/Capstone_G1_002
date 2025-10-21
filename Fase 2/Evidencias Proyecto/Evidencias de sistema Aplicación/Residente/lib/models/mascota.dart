/// Modelo para la tabla mascota
///
/// Representa una mascota de un grupo familiar
class Mascota {
  final int idMascota; // PK
  final String nombreM;
  final String especie;
  final String tamanio;
  final DateTime fechaRegM;
  final int idGrupof; // FK -> grupofamiliar
  final DateTime? createdAt; // Campo opcional para compatibilidad
  final DateTime? updatedAt; // Campo opcional para compatibilidad

  Mascota({
    required this.idMascota,
    required this.nombreM,
    required this.especie,
    required this.tamanio,
    required this.fechaRegM,
    required this.idGrupof,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia del modelo con campos actualizados
  Mascota copyWith({
    int? idMascota,
    String? nombreM,
    String? especie,
    String? tamanio,
    DateTime? fechaRegM,
    int? idGrupof,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mascota(
      idMascota: idMascota ?? this.idMascota,
      nombreM: nombreM ?? this.nombreM,
      especie: especie ?? this.especie,
      tamanio: tamanio ?? this.tamanio,
      fechaRegM: fechaRegM ?? this.fechaRegM,
      idGrupof: idGrupof ?? this.idGrupof,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_mascota': idMascota,
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String(),
      'id_grupof': idGrupof,
    };
  }

  /// Crea un Mascota desde JSON de Supabase
  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      idMascota: json['id_mascota'] as int,
      nombreM: json['nombre_m'] as String,
      especie: json['especie'] as String,
      tamanio: json['tamanio'] as String,
      fechaRegM: DateTime.parse(json['fecha_reg_m'] as String),
      idGrupof: json['id_grupof'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_mascota)
  Map<String, dynamic> toInsertData() {
    return {
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String(),
      'id_grupof': idGrupof,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': fechaRegM.toIso8601String(),
      'id_grupof': idGrupof,
    };
  }

  @override
  String toString() {
    return 'Mascota(idMascota: $idMascota, nombreM: $nombreM, especie: $especie, idGrupof: $idGrupof)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mascota && other.idMascota == idMascota;
  }

  @override
  int get hashCode => idMascota.hashCode;
}
