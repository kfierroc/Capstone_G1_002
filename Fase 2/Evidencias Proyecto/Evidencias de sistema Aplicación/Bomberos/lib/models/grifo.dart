/// Modelo de datos para un Grifo de agua
class Grifo {
  final String id;
  final String direccion;
  final String comuna;
  final String tipo;
  final String estado;
  final DateTime ultimaInspeccion;
  final String notas;
  final String reportadoPor;
  final DateTime fechaReporte;
  final double lat;
  final double lng;

  Grifo({
    required this.id,
    required this.direccion,
    required this.comuna,
    required this.tipo,
    required this.estado,
    required this.ultimaInspeccion,
    required this.notas,
    required this.reportadoPor,
    required this.fechaReporte,
    required this.lat,
    required this.lng,
  });

  /// Crea una copia del grifo con campos actualizados
  Grifo copyWith({
    String? id,
    String? direccion,
    String? comuna,
    String? tipo,
    String? estado,
    DateTime? ultimaInspeccion,
    String? notas,
    String? reportadoPor,
    DateTime? fechaReporte,
    double? lat,
    double? lng,
  }) {
    return Grifo(
      id: id ?? this.id,
      direccion: direccion ?? this.direccion,
      comuna: comuna ?? this.comuna,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      ultimaInspeccion: ultimaInspeccion ?? this.ultimaInspeccion,
      notas: notas ?? this.notas,
      reportadoPor: reportadoPor ?? this.reportadoPor,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  /// Convierte el modelo a Map para guardarlo en base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'direccion': direccion,
      'comuna': comuna,
      'tipo': tipo,
      'estado': estado,
      'ultima_inspeccion': ultimaInspeccion.toIso8601String(),
      'notas': notas,
      'reportado_por': reportadoPor,
      'fecha_reporte': fechaReporte.toIso8601String(),
      'lat': lat,
      'lng': lng,
    };
  }

  /// Crea un Grifo desde un Map de base de datos
  factory Grifo.fromMap(Map<String, dynamic> map) {
    return Grifo(
      id: map['id'],
      direccion: map['direccion'],
      comuna: map['comuna'],
      tipo: map['tipo'],
      estado: map['estado'],
      ultimaInspeccion: DateTime.parse(map['ultima_inspeccion']),
      notas: map['notas'],
      reportadoPor: map['reportado_por'],
      fechaReporte: DateTime.parse(map['fecha_reporte']),
      lat: map['lat'],
      lng: map['lng'],
    );
  }
}
