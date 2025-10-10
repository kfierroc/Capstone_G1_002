/// Modelo para mascota
class Pet {
  final String id;
  final String name;
  final String species;
  final String size;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.size,
  });

  // Crear desde Map
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      size: map['size'] as String,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'size': size,
    };
  }

  // CopyWith para actualizaciones inmutables
  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? size,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      size: size ?? this.size,
    );
  }

  // JSON serialization
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      size: json['size'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'size': size,
    };
  }
}

