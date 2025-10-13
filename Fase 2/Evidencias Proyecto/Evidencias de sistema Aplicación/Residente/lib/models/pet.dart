/// Modelo para mascota
/// 
/// Representa una mascota de un residente
/// Compatible con la base de datos de Supabase
class Pet {
  final String id;
  final String? residentId; // ID del residente (null si no está guardado aún)
  final String name;
  final String species;
  final String size;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    required this.id,
    this.residentId,
    required this.name,
    required this.species,
    required this.size,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde Map (compatibilidad con versión anterior)
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as String,
      residentId: map['residentId'] as String?,
      name: map['name'] as String,
      species: map['species'] as String,
      size: map['size'] as String,
    );
  }

  // Convertir a Map (compatibilidad con versión anterior)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'residentId': residentId,
      'name': name,
      'species': species,
      'size': size,
    };
  }

  // CopyWith para actualizaciones inmutables
  Pet copyWith({
    String? id,
    String? residentId,
    String? name,
    String? species,
    String? size,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      residentId: residentId ?? this.residentId,
      name: name ?? this.name,
      species: species ?? this.species,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization (compatible con Supabase)
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      residentId: json['resident_id'] as String?,
      name: json['name'] as String,
      species: json['species'] as String,
      size: json['size'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      'name': name,
      'species': species,
      'size': size,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Crear datos para inserción en Supabase (sin id, createdAt, updatedAt)
  Map<String, dynamic> toInsertData({required String residentId}) {
    return {
      'resident_id': residentId,
      'name': name,
      'species': species,
      'size': size,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'name': name,
      'species': species,
      'size': size,
    };
  }
}

