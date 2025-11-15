/// Modelo compartido para residentes usado en el panel administrativo web.
class Resident {
  final int idGroup;
  final String rut;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime? createdAt;
  final int? integrantesCount;
  final int? mascotasCount;
  final int? condicionesMedicasCount;

  const Resident({
    required this.idGroup,
    required this.rut,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.createdAt,
    this.integrantesCount,
    this.mascotasCount,
    this.condicionesMedicasCount,
  });

  String get fullName => '$firstName $lastName'.trim();
  
  int get totalIntegrantes => integrantesCount ?? 0;

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      idGroup: json['id_grupof'] is int
          ? json['id_grupof'] as int
          : int.tryParse(json['id_grupof']?.toString() ?? '') ?? 0,
      rut: json['rut_titular']?.toString() ?? '',
      firstName: json['nomb_titular']?.toString() ?? '',
      lastName: json['ape_p_titular']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['telefono_titular']?.toString() ?? '',
      createdAt: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      integrantesCount: json['integrantes_count'] as int?,
      mascotasCount: json['mascotas_count'] as int?,
      condicionesMedicasCount: json['condiciones_medicas_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_grupof': idGroup,
        'rut_titular': rut,
        'nomb_titular': firstName,
        'ape_p_titular': lastName,
        'email': email,
        'telefono_titular': phone,
        'fecha_creacion': createdAt?.toIso8601String(),
      };
}

