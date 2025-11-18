/// Modelo para miembro de familia
/// 
/// Representa un miembro de la familia de un residente
/// Compatible con la base de datos de Supabase
class FamilyMember {
  final String id;
  final String? residentId; // ID del residente (null si no está guardado aún)
  final String rut;
  final int age;
  final int birthYear;
  final List<String> conditions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FamilyMember({
    required this.id,
    this.residentId,
    required this.rut,
    required this.age,
    required this.birthYear,
    List<String>? conditions,
    this.createdAt,
    this.updatedAt,
  }) : conditions = conditions ?? [];

  // Crear desde Map (compatibilidad con versión anterior)
  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as String,
      residentId: map['residentId'] as String?,
      rut: map['rut'] as String,
      age: map['age'] as int,
      birthYear: map['birthYear'] as int,
      conditions: (map['conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Convertir a Map (compatibilidad con versión anterior)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'residentId': residentId,
      'rut': rut,
      'age': age,
      'birthYear': birthYear,
      'conditions': conditions,
    };
  }

  // CopyWith para actualizaciones inmutables
  FamilyMember copyWith({
    String? id,
    String? residentId,
    String? rut,
    int? age,
    int? birthYear,
    List<String>? conditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      residentId: residentId ?? this.residentId,
      rut: rut ?? this.rut,
      age: age ?? this.age,
      birthYear: birthYear ?? this.birthYear,
      conditions: conditions ?? this.conditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization (compatible con Supabase)
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      residentId: json['resident_id'] as String?,
      rut: json['rut'] as String,
      age: json['age'] as int,
      birthYear: json['birth_year'] as int,
      conditions: (json['medical_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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
      'rut': rut,
      'age': age,
      'birth_year': birthYear,
      'medical_conditions': conditions,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Crear datos para inserción en Supabase (sin id, createdAt, updatedAt)
  Map<String, dynamic> toInsertData({required String residentId}) {
    return {
      'resident_id': residentId,
      'rut': rut,
      'age': age,
      'birth_year': birthYear,
      'medical_conditions': conditions,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'rut': rut,
      'age': age,
      'birth_year': birthYear,
      'medical_conditions': conditions,
    };
  }

  @override
  String toString() {
    return 'FamilyMember(id: $id, rut: $rut, age: $age, birthYear: $birthYear, conditions: $conditions)';
  }
}

