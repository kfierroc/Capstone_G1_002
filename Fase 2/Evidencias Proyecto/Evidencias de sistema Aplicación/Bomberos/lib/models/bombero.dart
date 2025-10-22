/// Modelo para la tabla bombero
/// 
/// Representa un bombero con su información personal
class Bombero {
  final int rutNum; // PK
  final String rutDv;
  final String compania; // NUEVO CAMPO según esquema actualizado
  final String nombBombero; // NUEVO CAMPO según esquema actualizado
  final String apePBombero; // NUEVO CAMPO según esquema actualizado
  final String emailB;
  final int cutCom; // Cambiado de outCom a cutCom para coincidir con la BD

  Bombero({
    required this.rutNum,
    required this.rutDv,
    required this.compania,
    required this.nombBombero,
    required this.apePBombero,
    required this.emailB,
    required this.cutCom, // Cambiado de outCom a cutCom
  });

  /// Crea una copia del modelo con campos actualizados
  Bombero copyWith({
    int? rutNum,
    String? rutDv,
    String? compania,
    String? nombBombero,
    String? apePBombero,
    String? emailB,
    int? cutCom, // Cambiado de outCom a cutCom
  }) {
    return Bombero(
      rutNum: rutNum ?? this.rutNum,
      rutDv: rutDv ?? this.rutDv,
      compania: compania ?? this.compania,
      nombBombero: nombBombero ?? this.nombBombero,
      apePBombero: apePBombero ?? this.apePBombero,
      emailB: emailB ?? this.emailB,
      cutCom: cutCom ?? this.cutCom, // Cambiado de outCom a cutCom
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'compania': compania, // Corregido: sin ñ
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom, // Cambiado de out_com a cut_com
    };
  }

  /// Crea un Bombero desde JSON de Supabase
  factory Bombero.fromJson(Map<String, dynamic> json) {
    return Bombero(
      rutNum: json['rut_num'] as int,
      rutDv: json['rut_dv'] as String,
      compania: json['compania'] as String? ?? '', // Corregido: sin ñ
      nombBombero: json['nomb_bombero'] as String? ?? '',
      apePBombero: json['ape_p_bombero'] as String? ?? '',
      emailB: json['email_b'] as String,
      cutCom: json['cut_com'] as int? ?? 0, // Cambiado de out_com a cut_com
    );
  }

  /// Crear datos para inserción en Supabase
  Map<String, dynamic> toInsertData() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'compania': compania, // Corregido: sin ñ
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom, // Cambiado de out_com a cut_com
    };
  }

  /// Crear datos para actualización en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'rut_dv': rutDv,
      'compania': compania, // Corregido: sin ñ
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom, // Cambiado de out_com a cut_com
    };
  }

  /// Obtener RUT completo formateado
  String get rutCompleto => '$rutNum-$rutDv';

  /// Crear Bombero desde RUT completo
  factory Bombero.fromRutCompleto(String rutCompleto, String email, {int? cutCom}) {
    final rutParts = rutCompleto.split('-');
    final rutNum = int.parse(rutParts[0].replaceAll('.', ''));
    final rutDv = rutParts.length > 1 ? rutParts[1] : '';
    
    return Bombero(
      rutNum: rutNum,
      rutDv: rutDv,
      compania: '', // Valor por defecto
      nombBombero: '', // Valor por defecto
      apePBombero: '', // Valor por defecto
      emailB: email,
      cutCom: cutCom ?? 13101, // Santiago por defecto (CUT válido)
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
