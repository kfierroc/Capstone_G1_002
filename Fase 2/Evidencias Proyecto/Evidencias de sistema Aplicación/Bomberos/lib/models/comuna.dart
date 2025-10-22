/// Modelo para la tabla comunas
/// 
/// Representa una comuna con su información geográfica y administrativa
class Comuna {
  final int cutCom; // PK (cambió de outCom a cutCom según estándar)
  final String comuna;
  final int cutReg; // Cambió de outReg a cutReg según estándar
  
  /// Getter para el nombre de la comuna (alias para comuna)
  String get nombre => comuna;
  
  /// Getter para el nombre de la comuna (alias para comuna)
  String get nombreComuna => comuna;
  final String region;
  final int cutProv; // Cambió de outProv a cutProv según estándar
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
    int? cutCom,
    String? comuna,
    int? cutReg,
    String? region,
    int? cutProv,
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
      cutCom: json['cut_com'] as int,
      comuna: json['comuna'] as String,
      cutReg: json['cut_reg'] as int,
      region: json['region'] as String,
      cutProv: json['cut_prov'] as int,
      provincia: json['provincia'] as String,
      superficie: (json['superficie'] as num).toDouble(),
      geometry: json['geometry'] as String?,
    );
  }

  /// Convierte el modelo a JSON para insertar en Supabase
  Map<String, dynamic> toInsertData() {
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

  /// Convierte el modelo a JSON para actualizar en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'comuna': comuna,
      'cut_reg': cutReg,
      'region': region,
      'cut_prov': cutProv,
      'provincia': provincia,
      'superficie': superficie,
      'geometry': geometry,
    };
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
