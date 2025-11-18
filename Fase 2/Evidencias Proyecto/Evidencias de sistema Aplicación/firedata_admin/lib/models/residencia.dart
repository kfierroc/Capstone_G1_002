class Residencia {
  final int idResidencia;
  final String direccion;
  final double lat;
  final double lon;
  final int cutCom;
  final String? telefonoPrincipal;
  final int? numeroPisos;
  final String? instruccionesEspeciales;
  
  // Información de registro_v (relación con grupo familiar)
  final int? idRegistro;
  final bool? vigente;
  final String? estado;
  final String? material;
  final String? tipo;
  final int? pisos;
  final DateTime? fechaIniR;
  final DateTime? fechaFinR;
  final int? idGrupof;
  
  // Información del residente relacionado (solo lectura)
  final String? rutResidente;

  const Residencia({
    required this.idResidencia,
    required this.direccion,
    required this.lat,
    required this.lon,
    required this.cutCom,
    this.telefonoPrincipal,
    this.numeroPisos,
    this.instruccionesEspeciales,
    this.idRegistro,
    this.vigente,
    this.estado,
    this.material,
    this.tipo,
    this.pisos,
    this.fechaIniR,
    this.fechaFinR,
    this.idGrupof,
    this.rutResidente,
  });

  factory Residencia.fromJson(Map<String, dynamic> json) {
    // Manejar datos anidados de registro_v y grupofamiliar
    final registroV = json['registro_v'] as Map<String, dynamic>?;
    
    // Manejar grupofamiliar que puede venir como lista o objeto
    Map<String, dynamic>? grupoFamiliar;
    if (registroV != null && registroV.containsKey('grupofamiliar')) {
      final grupoFamiliarData = registroV['grupofamiliar'];
      if (grupoFamiliarData is List && grupoFamiliarData.isNotEmpty) {
        grupoFamiliar = grupoFamiliarData.first as Map<String, dynamic>?;
      } else if (grupoFamiliarData is Map) {
        grupoFamiliar = grupoFamiliarData as Map<String, dynamic>?;
      }
    }
    
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
      numeroPisos: null, // Campo no existe en la tabla residencia, se obtiene de registro_v
      instruccionesEspeciales: registroV?['instrucciones_especiales']?.toString(), // Se obtiene de registro_v, no de residencia
      // Información de registro_v
      idRegistro: registroV != null
          ? (registroV['id_registro'] is int
              ? registroV['id_registro'] as int
              : int.tryParse(registroV['id_registro']?.toString() ?? ''))
          : null,
      vigente: registroV?['vigente'] as bool?,
      estado: registroV?['estado']?.toString(),
      material: registroV?['material']?.toString(),
      tipo: registroV?['tipo']?.toString(),
      pisos: registroV != null
          ? (registroV['pisos'] is int
              ? registroV['pisos'] as int
              : int.tryParse(registroV['pisos']?.toString() ?? ''))
          : null,
      fechaIniR: registroV?['fecha_ini_r'] != null
          ? DateTime.tryParse(registroV!['fecha_ini_r'].toString())
          : null,
      fechaFinR: registroV?['fecha_fin_r'] != null
          ? DateTime.tryParse(registroV!['fecha_fin_r'].toString())
          : null,
      idGrupof: registroV != null
          ? (registroV['id_grupof'] is int
              ? registroV['id_grupof'] as int
              : int.tryParse(registroV['id_grupof']?.toString() ?? ''))
          : null,
      // RUT del residente relacionado
      rutResidente: grupoFamiliar?['rut_titular']?.toString(),
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
    // telefono_principal no existe en la tabla residencia según el error
    // numero_pisos no existe en la tabla residencia, está en registro_v
    // instrucciones_especiales no se guarda en residencia, está en registro_v
    return data;
  }
}

