/// Modelo para la tabla grifo
/// 
/// Representa un grifo de agua con su ubicación
class Grifo {
  final int idGrifo; // PK
  final double lat;
  final double lon;
  final int cutCom;

  Grifo({
    required this.idGrifo,
    required this.lat,
    required this.lon,
    required this.cutCom,
  });

  Grifo copyWith({
    int? idGrifo,
    double? lat,
    double? lon,
    int? cutCom,
  }) {
    return Grifo(
      idGrifo: idGrifo ?? this.idGrifo,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      cutCom: cutCom ?? this.cutCom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_grifo': idGrifo,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  factory Grifo.fromJson(Map<String, dynamic> json) {
    return Grifo(
      idGrifo: json['id_grifo'] as int,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as int,
    );
  }

  Map<String, dynamic> toInsertData() {
    return {
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  String get direccionGrifo => 'Lat: $lat, Lon: $lon';
  double get latitudGrifo => lat;
  double get longitudGrifo => lon;

  @override
  String toString() {
    return 'Grifo(idGrifo: $idGrifo, lat: $lat, lon: $lon, cutCom: $cutCom)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grifo && other.idGrifo == idGrifo;
  }

  @override
  int get hashCode => idGrifo.hashCode;
}

