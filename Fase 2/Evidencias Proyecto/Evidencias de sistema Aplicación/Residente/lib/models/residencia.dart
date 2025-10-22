/// Modelo para la tabla residencia
/// 
/// Representa una residencia con su ubicación geográfica y detalles adicionales
class Residencia {
  final int idResidencia; // PK
  final String direccion;
  final double lat;
  final double lon;
  final int cutCom; // FK -> comunas (cambiado de outCom a cutCom para coincidir con BD)
  final String? telefonoPrincipal; // Campo agregado
  final int? numeroPisos; // Campo agregado
  final Map<String, dynamic>? instruccionesEspeciales; // Campo JSON
  final DateTime? createdAt; // Campo agregado
  final DateTime? updatedAt; // Campo agregado

  Residencia({
    required this.idResidencia,
    required this.direccion,
    required this.lat,
    required this.lon,
    required this.cutCom, // Cambiado de outCom a cutCom
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
    int? cutCom, // Cambiado de outCom a cutCom
    String? telefonoPrincipal,
    int? numeroPisos,
    Map<String, dynamic>? instruccionesEspeciales,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Residencia(
      idResidencia: idResidencia ?? this.idResidencia,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      cutCom: cutCom ?? this.cutCom, // Cambiado de outCom a cutCom
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
      'cut_com': cutCom, // Cambiado de out_com a cut_com
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
      cutCom: json['cut_com'] as int, // Cambiado de out_com a cut_com
      telefonoPrincipal: json['telefono_principal'] as String?,
      numeroPisos: json['numero_pisos'] as int?,
      instruccionesEspeciales: json['instrucciones_especiales'] != null 
          ? Map<String, dynamic>.from(json['instrucciones_especiales'] as Map)
          : null,
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
      'cut_com': cutCom, // Cambiado de out_com a cut_com
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

  // =============================================
  // MÉTODOS PARA MANEJO DE INSTRUCCIONES ESPECIALES
  // =============================================

  /// Obtiene una instrucción específica por tipo
  String? obtenerInstruccion(String tipo) {
    return instruccionesEspeciales?[tipo] as String?;
  }

  /// Agrega o actualiza una instrucción específica
  Residencia agregarInstruccion(String tipo, String instruccion) {
    final nuevasInstrucciones = Map<String, dynamic>.from(instruccionesEspeciales ?? {});
    nuevasInstrucciones[tipo] = instruccion;
    
    return copyWith(instruccionesEspeciales: nuevasInstrucciones);
  }

  /// Elimina una instrucción específica
  Residencia eliminarInstruccion(String tipo) {
    if (instruccionesEspeciales == null) return this;
    
    final nuevasInstrucciones = Map<String, dynamic>.from(instruccionesEspeciales!);
    nuevasInstrucciones.remove(tipo);
    
    return copyWith(instruccionesEspeciales: nuevasInstrucciones.isEmpty ? null : nuevasInstrucciones);
  }

  /// Obtiene todas las instrucciones como texto formateado
  String obtenerInstruccionesFormateadas() {
    if (instruccionesEspeciales == null || instruccionesEspeciales!.isEmpty) {
      return 'Sin instrucciones especiales';
    }

    final buffer = StringBuffer();
    instruccionesEspeciales!.forEach((tipo, instruccion) {
      buffer.writeln('${_capitalizarPrimeraLetra(tipo)}: $instruccion');
    });
    
    return buffer.toString().trim();
  }

  /// Verifica si tiene instrucciones de un tipo específico
  bool tieneInstruccion(String tipo) {
    return instruccionesEspeciales?.containsKey(tipo) ?? false;
  }

  /// Obtiene todos los tipos de instrucciones disponibles
  List<String> obtenerTiposInstrucciones() {
    return instruccionesEspeciales?.keys.toList() ?? [];
  }

  /// Método auxiliar para capitalizar la primera letra
  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  // =============================================
  // CONSTANTES PARA TIPOS DE INSTRUCCIONES
  // =============================================

  static const String tipoGeneral = 'general';
  static const String tipoAcceso = 'acceso';
  static const String tipoEmergencia = 'emergencia';
  static const String tipoContacto = 'contacto';
  static const String tipoObservaciones = 'observaciones';
  static const String tipoAccesoEmergencia = 'acceso_emergencia';
  static const String tipoHidrantes = 'hidrantes';
  static const String tipoEscaleras = 'escaleras';
  static const String tipoContactoEmergencia = 'contacto_emergencia';
}
