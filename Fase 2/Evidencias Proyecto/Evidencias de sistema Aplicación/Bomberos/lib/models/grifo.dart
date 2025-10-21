/// Modelo para la tabla grifo
/// 
/// Representa un grifo de agua con su ubicación
class Grifo {
  final int idGrifo; // PK
  final double lat;
  final double lon;
  final String cutCom; // FK -> comunas

  Grifo({
    required this.idGrifo,
    required this.lat,
    required this.lon,
    required this.cutCom,
  });

  /// Crea una copia del modelo con campos actualizados
  Grifo copyWith({
    int? idGrifo,
    double? lat,
    double? lon,
    String? cutCom,
  }) {
    return Grifo(
      idGrifo: idGrifo ?? this.idGrifo,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      cutCom: cutCom ?? this.cutCom,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_grifo': idGrifo,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

  /// Crea un Grifo desde JSON de Supabase
  factory Grifo.fromJson(Map<String, dynamic> json) {
    return Grifo(
      idGrifo: json['id_grifo'] as int,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as String,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_grifo)
  Map<String, dynamic> toInsertData() {
    return {
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
  }

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