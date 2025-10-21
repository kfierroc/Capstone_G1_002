/// Modelo para la tabla bombero
/// 
/// Representa un bombero con su información personal
class Bombero {
  final int rutNum; // PK
  final String rutDv;
  final String emailB;

  Bombero({
    required this.rutNum,
    required this.rutDv,
    required this.emailB,
  });

  /// Crea una copia del modelo con campos actualizados
  Bombero copyWith({
    int? rutNum,
    String? rutDv,
    String? emailB,
  }) {
    return Bombero(
      rutNum: rutNum ?? this.rutNum,
      rutDv: rutDv ?? this.rutDv,
      emailB: emailB ?? this.emailB,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'email_b': emailB,
    };
  }

  /// Crea un Bombero desde JSON de Supabase
  factory Bombero.fromJson(Map<String, dynamic> json) {
    return Bombero(
      rutNum: json['rut_num'] as int,
      rutDv: json['rut_dv'] as String,
      emailB: json['email_b'] as String,
    );
  }

  /// Crear datos para inserción en Supabase
  Map<String, dynamic> toInsertData() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'email_b': emailB,
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'rut_dv': rutDv,
      'email_b': emailB,
    };
  }

  /// Obtener RUT completo formateado
  String get rutCompleto => '$rutNum-$rutDv';

  /// Crear Bombero desde RUT completo
  factory Bombero.fromRutCompleto(String rutCompleto, String email) {
    final rutParts = rutCompleto.split('-');
    final rutNum = int.parse(rutParts[0].replaceAll('.', ''));
    final rutDv = rutParts.length > 1 ? rutParts[1] : '';
    
    return Bombero(
      rutNum: rutNum,
      rutDv: rutDv,
      emailB: email,
    );
  }

  @override
  String toString() {
    return 'Bombero(rutNum: $rutNum, rutDv: $rutDv, emailB: $emailB)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bombero && other.rutNum == rutNum;
  }

  @override
  int get hashCode => rutNum.hashCode;
}
