import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/resident.dart';
import 'package:firedata_admin/models/family_group_info.dart';

/// Servicio simple para obtener residentes desde Supabase.
///
/// Reutiliza la configuración existente (`SupabaseConfig`) y mapea la respuesta
/// a objetos `Resident`. Adapta los nombres de columnas según tu esquema real.
class ResidentsAdminService {
  ResidentsAdminService._();

  static final ResidentsAdminService instance = ResidentsAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Resident>> fetchResidents({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = _client
        .from('grupofamiliar')
        .select(
          'id_grupof, rut_titular, nomb_titular, ape_p_titular, telefono_titular, email, fecha_creacion',
        )
        .order('fecha_creacion', ascending: false)
        .range(offset, offset + limit - 1);
    
    final data = await query;
    final list = (data as List).cast<Map<String, dynamic>>();
    var residents = list.map(Resident.fromJson).toList();

    // Aplicar filtro de búsqueda si se proporciona
    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      residents = residents.where((resident) {
        return resident.fullName.toLowerCase().contains(term) ||
            resident.rut.toLowerCase().contains(term) ||
            resident.email.toLowerCase().contains(term) ||
            resident.phone.toLowerCase().contains(term);
      }).toList();
    }

    // Cargar información del grupo familiar para todos los residentes en paralelo
    final familyInfoFutures = residents.map((resident) => 
      fetchFamilyGroupInfo(resident.idGroup)
    ).toList();
    
    final familyInfoList = await Future.wait(familyInfoFutures);

    // Crear lista actualizada con información del grupo familiar
    final updatedResidents = <Resident>[];
    for (int i = 0; i < residents.length; i++) {
      final resident = residents[i];
      final familyInfo = familyInfoList[i];
      
      updatedResidents.add(Resident(
        idGroup: resident.idGroup,
        rut: resident.rut,
        firstName: resident.firstName,
        lastName: resident.lastName,
        email: resident.email,
        phone: resident.phone,
        createdAt: resident.createdAt,
        integrantesCount: familyInfo?.integrantesCount,
        mascotasCount: familyInfo?.mascotasCount,
        condicionesMedicasCount: familyInfo?.condicionesMedicasCount,
      ));
    }

    return updatedResidents;
  }

  /// Obtener información completa del grupo familiar
  Future<FamilyGroupInfo?> fetchFamilyGroupInfo(int idGroup) async {
    try {
      // Obtener integrantes con info_integrante
      final integrantesData = await _client
          .from('integrante')
          .select('''
            id_integrante,
            activo_i,
            info_integrante(anio_nac, padecimiento)
          ''')
          .eq('id_grupof', idGroup)
          .eq('activo_i', true);

      // Obtener mascotas
      final mascotasData = await _client
          .from('mascota')
          .select('id_mascota, nombre_m, especie, tamanio')
          .eq('id_grupof', idGroup);

      final integrantes = (integrantesData as List)
          .map((e) => IntegranteInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      final mascotas = (mascotasData as List)
          .map((e) => MascotaInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      final condicionesMedicas = integrantes
          .where((i) => i.padecimiento != null && i.padecimiento!.isNotEmpty)
          .length;

      return FamilyGroupInfo(
        idGroup: idGroup,
        integrantesCount: integrantes.length,
        mascotasCount: mascotas.length,
        condicionesMedicasCount: condicionesMedicas,
        integrantes: integrantes,
        mascotas: mascotas,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> insertResident(Resident resident) async {
    await _client.from('grupofamiliar').insert(resident.toJson());
  }

  Future<void> updateResident(Resident resident) async {
    // Solo actualizar campos editables (teléfono y email)
    // No actualizar: id_grupof, rut_titular, nomb_titular, ape_p_titular, fecha_creacion
    await _client
        .from('grupofamiliar')
        .update({
          'telefono_titular': resident.phone,
          'email': resident.email,
        })
        .eq('id_grupof', resident.idGroup);
  }

  Future<void> deleteResident(int idGroup) async {
    await _client.from('grupofamiliar').delete().eq('id_grupof', idGroup);
  }
}




