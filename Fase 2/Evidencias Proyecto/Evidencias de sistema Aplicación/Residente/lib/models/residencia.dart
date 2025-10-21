/// Modelo para la tabla residencia
/// 
/// Representa una residencia con su ubicación geográfica y detalles adicionales
class Residencia {
  final int idResidencia; // PK
  final String direccion;
  final double lat;
  final double lon;
  final String cutCom; // FK -> comunas
  final String? telefonoPrincipal; // Campo agregado
  final int? numeroPisos; // Campo agregado
  final String? instruccionesEspeciales; // Campo agregado
  final DateTime? createdAt; // Campo agregado
  final DateTime? updatedAt; // Campo agregado

  Residencia({
    required this.idResidencia,
    required this.direccion,
    required this.lat,
    required this.lon,
    required this.cutCom,
    this.telefonoPrincipal,
    this.numeroPisos,
    this.instruccionesEspeciales,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una copia del modelo con campos actualizados
  Residencia copyWith({
    int? idResidencia,
    String? direccion,
    double? lat,
    double? lon,
    String? cutCom,
    String? telefonoPrincipal,
    int? numeroPisos,
    String? instruccionesEspeciales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Residencia(
      idResidencia: idResidencia ?? this.idResidencia,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      cutCom: cutCom ?? this.cutCom,
      telefonoPrincipal: telefonoPrincipal ?? this.telefonoPrincipal,
      numeroPisos: numeroPisos ?? this.numeroPisos,
      instruccionesEspeciales: instruccionesEspeciales ?? this.instruccionesEspeciales,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id_residencia': idResidencia,
      'direccion': direccion,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
      'telefono_principal': telefonoPrincipal,
      'numero_pisos': numeroPisos,
      'instrucciones_especiales': instruccionesEspeciales,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea un Residencia desde JSON de Supabase
  factory Residencia.fromJson(Map<String, dynamic> json) {
    return Residencia(
      idResidencia: json['id_residencia'] as int,
      direccion: json['direccion'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      cutCom: json['cut_com'] as String,
      telefonoPrincipal: json['telefono_principal'] as String?,
      numeroPisos: json['numero_pisos'] as int?,
      instruccionesEspeciales: json['instrucciones_especiales'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Crear datos para inserción en Supabase (sin id_residencia)
  Map<String, dynamic> toInsertData() {
    return {
      'direccion': direccion,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
      'telefono_principal': telefonoPrincipal,
      'numero_pisos': numeroPisos,
      'instrucciones_especiales': instruccionesEspeciales,
    };
  }

  @override
  String toString() {
    return 'Residencia(idResidencia: $idResidencia, direccion: $direccion, lat: $lat, lon: $lon, telefonoPrincipal: $telefonoPrincipal, numeroPisos: $numeroPisos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Residencia && other.idResidencia == idResidencia;
  }

  @override
  int get hashCode => idResidencia.hashCode;
}
