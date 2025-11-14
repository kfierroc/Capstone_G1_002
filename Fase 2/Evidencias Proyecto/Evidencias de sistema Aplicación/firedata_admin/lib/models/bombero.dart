/// Modelo para la tabla bombero
/// 
/// Representa un bombero con su información personal
class Bombero {
  final int rutNum; // PK
  final String rutDv;
  final String compania;
  final String nombBombero;
  final String apePBombero;
  final String emailB;
  final int cutCom;

  Bombero({
    required this.rutNum,
    required this.rutDv,
    required this.compania,
    required this.nombBombero,
    required this.apePBombero,
    required this.emailB,
    required this.cutCom,
  });

  Bombero copyWith({
    int? rutNum,
    String? rutDv,
    String? compania,
    String? nombBombero,
    String? apePBombero,
    String? emailB,
    int? cutCom,
  }) {
    return Bombero(
      rutNum: rutNum ?? this.rutNum,
      rutDv: rutDv ?? this.rutDv,
      compania: compania ?? this.compania,
      nombBombero: nombBombero ?? this.nombBombero,
      apePBombero: apePBombero ?? this.apePBombero,
      emailB: emailB ?? this.emailB,
      cutCom: cutCom ?? this.cutCom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'compania': compania,
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom,
    };
  }

  factory Bombero.fromJson(Map<String, dynamic> json) {
    return Bombero(
      rutNum: json['rut_num'] as int,
      rutDv: json['rut_dv'] as String,
      compania: json['compania'] as String? ?? '',
      nombBombero: json['nomb_bombero'] as String? ?? '',
      apePBombero: json['ape_p_bombero'] as String? ?? '',
      emailB: json['email_b'] as String,
      cutCom: json['cut_com'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toInsertData() {
    return {
      'rut_num': rutNum,
      'rut_dv': rutDv,
      'compania': compania,
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'rut_dv': rutDv,
      'compania': compania,
      'nomb_bombero': nombBombero,
      'ape_p_bombero': apePBombero,
      'email_b': emailB,
      'cut_com': cutCom,
    };
  }

  String get rutCompleto => '$rutNum-$rutDv';

  factory Bombero.fromRutCompleto(String rutCompleto, String email, {int? cutCom}) {
    final rutParts = rutCompleto.split('-');
    final rutNum = int.parse(rutParts[0].replaceAll('.', ''));
    final rutDv = rutParts.length > 1 ? rutParts[1] : '';
    
    return Bombero(
      rutNum: rutNum,
      rutDv: rutDv,
      compania: '',
      nombBombero: '',
      apePBombero: '',
      emailB: email,
      cutCom: cutCom ?? 13101,
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

