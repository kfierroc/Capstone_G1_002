/// Información completa del grupo familiar
class FamilyGroupInfo {
  final int idGroup;
  final int integrantesCount;
  final int mascotasCount;
  final int condicionesMedicasCount;
  final List<IntegranteInfo> integrantes;
  final List<MascotaInfo> mascotas;

  const FamilyGroupInfo({
    required this.idGroup,
    required this.integrantesCount,
    required this.mascotasCount,
    required this.condicionesMedicasCount,
    required this.integrantes,
    required this.mascotas,
  });

  factory FamilyGroupInfo.fromJson(Map<String, dynamic> json) {
    final integrantes = (json['integrantes'] as List<dynamic>?)
            ?.map((e) => IntegranteInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final mascotas = (json['mascotas'] as List<dynamic>?)
            ?.map((e) => MascotaInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Contar condiciones médicas (padecimientos no vacíos)
    final condicionesMedicas = integrantes
        .where((i) => i.padecimiento != null && i.padecimiento!.isNotEmpty)
        .length;

    return FamilyGroupInfo(
      idGroup: json['id_grupof'] as int,
      integrantesCount: integrantes.length,
      mascotasCount: mascotas.length,
      condicionesMedicasCount: condicionesMedicas,
      integrantes: integrantes,
      mascotas: mascotas,
    );
  }
}

/// Información de un integrante
class IntegranteInfo {
  final int idIntegrante;
  final int? anioNac;
  final String? padecimiento;
  final bool activo;

  const IntegranteInfo({
    required this.idIntegrante,
    this.anioNac,
    this.padecimiento,
    required this.activo,
  });

  int? get edad {
    if (anioNac == null) return null;
    return DateTime.now().year - anioNac!;
  }

  factory IntegranteInfo.fromJson(Map<String, dynamic> json) {
    final infoIntegrante = json['info_integrante'] as Map<String, dynamic>?;
    return IntegranteInfo(
      idIntegrante: json['id_integrante'] as int,
      anioNac: infoIntegrante?['anio_nac'] as int?,
      padecimiento: infoIntegrante?['padecimiento']?.toString(),
      activo: json['activo_i'] as bool? ?? true,
    );
  }
}

/// Información de una mascota
class MascotaInfo {
  final int idMascota;
  final String nombre;
  final String especie;
  final String tamanio;

  const MascotaInfo({
    required this.idMascota,
    required this.nombre,
    required this.especie,
    required this.tamanio,
  });

  factory MascotaInfo.fromJson(Map<String, dynamic> json) {
    return MascotaInfo(
      idMascota: json['id_mascota'] as int,
      nombre: json['nombre_m']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      tamanio: json['tamanio']?.toString() ?? '',
    );
  }
}



