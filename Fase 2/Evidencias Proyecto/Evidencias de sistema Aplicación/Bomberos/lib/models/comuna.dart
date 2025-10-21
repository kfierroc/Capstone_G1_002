/// Modelo para la tabla comunas
/// 
/// Representa una comuna con su información geográfica y administrativa
class Comuna {
  final String cutCom; // PK
  final String comuna;
  final String cutReg;
  final String region;
  final String cutProv;
  final String provincia;
  final double superficie;
  final String? geometry;

  Comuna({
    required this.cutCom,
    required this.comuna,
    required this.cutReg,
    required this.region,
    required this.cutProv,
    required this.provincia,
    required this.superficie,
    this.geometry,
  });

  /// Crea una copia del modelo con campos actualizados
  Comuna copyWith({
    String? cutCom,
    String? comuna,
    String? cutReg,
    String? region,
    String? cutProv,
    String? provincia,
    double? superficie,
    String? geometry,
  }) {
    return Comuna(
      cutCom: cutCom ?? this.cutCom,
      comuna: comuna ?? this.comuna,
      cutReg: cutReg ?? this.cutReg,
      region: region ?? this.region,
      cutProv: cutProv ?? this.cutProv,
      provincia: provincia ?? this.provincia,
      superficie: superficie ?? this.superficie,
      geometry: geometry ?? this.geometry,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'cut_com': cutCom,
      'comuna': comuna,
      'cut_reg': cutReg,
      'region': region,
      'cut_prov': cutProv,
      'provincia': provincia,
      'superficie': superficie,
      'geometry': geometry,
    };
  }

  /// Crea un Comuna desde JSON de Supabase
  factory Comuna.fromJson(Map<String, dynamic> json) {
    return Comuna(
      cutCom: json['cut_com'] as String,
      comuna: json['comuna'] as String,
      cutReg: json['cut_reg'] as String,
      region: json['region'] as String,
      cutProv: json['cut_prov'] as String,
      provincia: json['provincia'] as String,
      superficie: (json['superficie'] as num).toDouble(),
      geometry: json['geometry'] as String?,
    );
  }

  @override
  String toString() {
    return 'Comuna(cutCom: $cutCom, comuna: $comuna, region: $region, provincia: $provincia)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comuna && other.cutCom == cutCom;
  }

  @override
  int get hashCode => cutCom.hashCode;
}
