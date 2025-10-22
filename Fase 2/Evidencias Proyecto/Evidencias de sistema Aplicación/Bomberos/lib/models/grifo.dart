/// Modelo para la tabla grifo
/// 
/// Representa un grifo de agua con su ubicación
class Grifo {
  final int idGrifo; // PK
  final double lat;
  final double lon;
  final int cutCom; // FK -> comunas (cambiado de outCom a cutCom para coincidir con BD)

  Grifo({
    required this.idGrifo,
    required this.lat,
    required this.lon,
    required this.cutCom, // Cambiado de outCom a cutCom
  });

  /// Crea una copia del modelo con campos actualizados
  Grifo copyWith({
    int? idGrifo,
    double? lat,
    double? lon,
    int? cutCom, // Cambiado de outCom a cutCom
  }) {
    return Grifo(
      idGrifo: idGrifo ?? this.idGrifo,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      cutCom: cutCom ?? this.cutCom, // Cambiado de outCom a cutCom
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_grifo': idGrifo,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom, // Cambiado de out_com a cut_com
    };
  }

  /// Crea un Grifo desde JSON de Supabase
  factory Grifo.fromJson(Map<String, dynamic> json) {
    return Grifo(
      idGrifo: json['id_grifo'] as int,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as int, // Cambiado de out_com a cut_com
    );
  }

  /// Convierte el modelo a JSON para insertar en Supabase
  Map<String, dynamic> toInsertData() {
    return {
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  /// Convierte el modelo a JSON para actualizar en Supabase
  Map<String, dynamic> toUpdateData() {
    return {
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  /// Getters para compatibilidad con nombres anteriores
  String get direccionGrifo => 'Lat: $lat, Lon: $lon';
  double get latitudGrifo => lat;
  double get longitudGrifo => lon;


  @override
  String toString() {
    return 'Grifo(idGrifo: $idGrifo, lat: $lat, lon: $lon, cutCom: $cutCom)'; // Cambiado de outCom a cutCom
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grifo && other.idGrifo == idGrifo;
  }

  @override
  int get hashCode => idGrifo.hashCode;
}