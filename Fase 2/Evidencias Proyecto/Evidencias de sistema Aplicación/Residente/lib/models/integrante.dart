// Modelo para la tabla integrante
// 
// Representa un integrante de un grupo familiar
import 'package:flutter/foundation.dart';
import 'family_member.dart';

class Integrante {
  final int idIntegrante; // PK
  final bool activoI;
  final DateTime fechaIniI;
  final DateTime? fechaFinI;
  final int idGrupof; // FK -> grupofamiliar
  final String rut; // RUT del integrante
  final int edad; // Edad del integrante
  final int anioNac; // Año de nacimiento
  final String? padecimiento; // Condiciones médicas
  final DateTime createdAt;
  final DateTime updatedAt;

  Integrante({
    required this.idIntegrante,
    required this.activoI,
    required this.fechaIniI,
    this.fechaFinI,
    required this.idGrupof,
    required this.rut,
    required this.edad,
    required this.anioNac,
    this.padecimiento,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del modelo con campos actualizados
  Integrante copyWith({
    int? idIntegrante,
    bool? activoI,
    DateTime? fechaIniI,
    DateTime? fechaFinI,
    int? idGrupof,
    String? rut,
    int? edad,
    int? anioNac,
    String? padecimiento,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Integrante(
      idIntegrante: idIntegrante ?? this.idIntegrante,
      activoI: activoI ?? this.activoI,
      fechaIniI: fechaIniI ?? this.fechaIniI,
      fechaFinI: fechaFinI ?? this.fechaFinI,
      idGrupof: idGrupof ?? this.idGrupof,
      rut: rut ?? this.rut,
      edad: edad ?? this.edad,
      anioNac: anioNac ?? this.anioNac,
      padecimiento: padecimiento ?? this.padecimiento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_integrante': idIntegrante,
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String(),
      'fecha_fin_i': fechaFinI?.toIso8601String(),
      'id_grupof': idGrupof,
      'rut': rut,
      'edad': edad,
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un Integrante desde JSON de Supabase
  factory Integrante.fromJson(Map<String, dynamic> json) {
    return Integrante(
      idIntegrante: json['id_integrante'] as int,
      activoI: json['activo_i'] as bool,
      fechaIniI: DateTime.parse(json['fecha_ini_i'] as String),
      fechaFinI: json['fecha_fin_i'] != null 
          ? DateTime.parse(json['fecha_fin_i'] as String)
          : null,
      idGrupof: json['id_grupof'] as int,
      rut: json['rut'] as String? ?? '',
      edad: json['edad'] as int? ?? 0,
      anioNac: json['anio_nac'] as int? ?? 0,
      padecimiento: json['padecimiento'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Crear datos para inserción en Supabase (sin id_integrante)
  Map<String, dynamic> toInsertData() {
    return {
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String(),
      'fecha_fin_i': fechaFinI?.toIso8601String(),
      'id_grupof': idGrupof,
      'rut': rut,
      'edad': edad,
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'activo_i': activoI,
      'fecha_ini_i': fechaIniI.toIso8601String(),
      'fecha_fin_i': fechaFinI?.toIso8601String(),
      'id_grupof': idGrupof,
      'rut': rut,
      'edad': edad,
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    };
  }

  @override
  String toString() {
    return 'Integrante(idIntegrante: $idIntegrante, activoI: $activoI, idGrupof: $idGrupof)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Integrante && other.idIntegrante == idIntegrante;
  }

  @override
  int get hashCode => idIntegrante.hashCode;

  /// Convierte Integrante a FamilyMember para compatibilidad
  FamilyMember? toFamilyMember() {
    try {
      return FamilyMember(
        id: idIntegrante.toString(),
        rut: rut.isNotEmpty ? rut : 'Sin RUT', // Usar RUT real del integrante
        age: edad > 0 ? edad : DateTime.now().year - fechaIniI.year,
        birthYear: anioNac > 0 ? anioNac : fechaIniI.year,
        conditions: padecimiento?.isNotEmpty == true 
            ? padecimiento!.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList()
            : [],
        createdAt: fechaIniI,
        updatedAt: fechaFinI ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error al convertir Integrante a FamilyMember: $e');
      return null;
    }
  }
}
