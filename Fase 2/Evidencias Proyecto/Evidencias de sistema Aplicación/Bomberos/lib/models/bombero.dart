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
  final bool? isAdmin; // Campo para administrador de firedata_admin

  Bombero({
    required this.rutNum,
    required this.rutDv,
    required this.compania,
    required this.nombBombero,
    required this.apePBombero,
    required this.emailB,
    required this.cutCom, // Cambiado de outCom a cutCom
    this.isAdmin,
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
    bool? isAdmin,
  }) {
    return Bombero(
      rutNum: rutNum ?? this.rutNum,
      rutDv: rutDv ?? this.rutDv,
      compania: compania ?? this.compania,
      nombBombero: nombBombero ?? this.nombBombero,
      apePBombero: apePBombero ?? this.apePBombero,
      emailB: emailB ?? this.emailB,
      cutCom: cutCom ?? this.cutCom, // Cambiado de outCom a cutCom
      isAdmin: isAdmin ?? this.isAdmin,
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
      'is_admin': isAdmin,
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
      isAdmin: json['is_admin'] as bool? ?? (json['is_admin'] == 1 || json['is_admin'] == true),
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
      'is_admin': isAdmin,
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
      'is_admin': isAdmin,
    };
  }

  /// Obtener RUT completo formateado
  String get rutCompleto {
    // Formatear RUT con puntos: 12.345.678-9
    final rutStr = rutNum.toString();
    String formatted = '';
    int counter = 0;
    
    for (int i = rutStr.length - 1; i >= 0; i--) {
      if (counter == 3) {
        formatted = '.$formatted';
        counter = 0;
      }
      formatted = rutStr[i] + formatted;
      counter++;
    }
    
    return '$formatted-$rutDv';
  }

  /// Crear Bombero desde RUT completo
  factory Bombero.fromRutCompleto(String rutCompleto, String compania, {String? email, int? cutCom}) {
    final rutParts = rutCompleto.split('-');
    final rutNum = int.parse(rutParts[0].replaceAll('.', ''));
    final rutDv = rutParts.length > 1 ? rutParts[1] : '';
    
    return Bombero(
      rutNum: rutNum,
      rutDv: rutDv,
      compania: compania,
      nombBombero: '', // Valor por defecto
      apePBombero: '', // Valor por defecto
      emailB: email ?? '',
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
