class Residencia {
  final int idResidencia;
  final String direccion;
  final double lat;
  final double lon;
  final int cutCom;
  final String? telefonoPrincipal;
  final int? numeroPisos;
  final String? instruccionesEspeciales;

  const Residencia({
    required this.idResidencia,
    required this.direccion,
    required this.lat,
    required this.lon,
    required this.cutCom,
    this.telefonoPrincipal,
    this.numeroPisos,
    this.instruccionesEspeciales,
  });

  factory Residencia.fromJson(Map<String, dynamic> json) {
    return Residencia(
      idResidencia: json['id_residencia'] is int
          ? json['id_residencia'] as int
          : int.tryParse(json['id_residencia'].toString()) ?? 0,
      direccion: json['direccion']?.toString() ?? '',
      lat: (json['lat'] is num)
          ? (json['lat'] as num).toDouble()
          : double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lon: (json['lon'] is num)
          ? (json['lon'] as num).toDouble()
          : double.tryParse(json['lon']?.toString() ?? '') ?? 0,
      cutCom: json['cut_com'] is int
          ? json['cut_com'] as int
          : int.tryParse(json['cut_com']?.toString() ?? '') ?? 0,
      telefonoPrincipal: json['telefono_principal']?.toString(),
      numeroPisos: json['numero_pisos'] is int
          ? json['numero_pisos'] as int
          : int.tryParse(json['numero_pisos']?.toString() ?? ''),
      instruccionesEspeciales: json['instrucciones_especiales']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'direccion': direccion,
      'lat': lat,
      'lon': lon,
      'cut_com': cutCom,
    };
    if (idResidencia != 0) {
      data['id_residencia'] = idResidencia;
    }
    if (telefonoPrincipal != null) {
      data['telefono_principal'] = telefonoPrincipal;
    }
    if (numeroPisos != null) {
      data['numero_pisos'] = numeroPisos;
    }
    if (instruccionesEspeciales != null) {
      data['instrucciones_especiales'] = instruccionesEspeciales;
    }
    return data;
  }
}

