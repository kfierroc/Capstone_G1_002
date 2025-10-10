/// Modelo para miembro de familia
class FamilyMember {
  final String id;
  final String rut;
  final int age;
  final int birthYear;
  final List<String> conditions;

  FamilyMember({
    required this.id,
    required this.rut,
    required this.age,
    required this.birthYear,
    List<String>? conditions,
  }) : conditions = conditions ?? [];

  // Crear desde Map
  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as String,
      rut: map['rut'] as String,
      age: map['age'] as int,
      birthYear: map['birthYear'] as int,
      conditions: (map['conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rut': rut,
      'age': age,
      'birthYear': birthYear,
      'conditions': conditions,
    };
  }

  // CopyWith para actualizaciones inmutables
  FamilyMember copyWith({
    String? id,
    String? rut,
    int? age,
    int? birthYear,
    List<String>? conditions,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      rut: rut ?? this.rut,
      age: age ?? this.age,
      birthYear: birthYear ?? this.birthYear,
      conditions: conditions ?? this.conditions,
    );
  }

  // JSON serialization
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      rut: json['rut'] as String,
      age: json['age'] as int,
      birthYear: json['birth_year'] as int,
      conditions: (json['medical_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rut': rut,
      'age': age,
      'birth_year': birthYear,
      'medical_conditions': conditions,
    };
  }
}

