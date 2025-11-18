import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/mascota.dart';

/// Servicio para gestionar mascotas del grupo familiar
class MascotasAdminService {
  MascotasAdminService._();

  static final MascotasAdminService instance = MascotasAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Obtener todas las mascotas de un grupo familiar
  Future<List<Mascota>> fetchMascotas(int idGrupof) async {
    final data = await _client
        .from('mascota')
        .select('id_mascota, nombre_m, especie, tamanio, fecha_reg_m, id_grupof')
        .eq('id_grupof', idGrupof)
        .order('fecha_reg_m', ascending: false);

    final list = (data as List).cast<Map<String, dynamic>>();
    return list.map(Mascota.fromJson).toList();
  }

  /// Crear mascota
  Future<Mascota> insertMascota({
    required int idGrupof,
    required String nombreM,
    required String especie,
    required String tamanio,
  }) async {
    final idMascota = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    final mascotaData = {
      'id_mascota': idMascota,
      'nombre_m': nombreM,
      'especie': especie,
      'tamanio': tamanio,
      'fecha_reg_m': DateTime.now().toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    };

    await _client.from('mascota').insert(mascotaData);

    final response = await _client
        .from('mascota')
        .select()
        .eq('id_mascota', idMascota)
        .single();

    return Mascota.fromJson(response as Map<String, dynamic>);
  }

  /// Actualizar mascota
  Future<void> updateMascota(Mascota mascota) async {
    await _client
        .from('mascota')
        .update(mascota.toUpdateData())
        .eq('id_mascota', mascota.idMascota);
  }

  /// Eliminar mascota
  Future<void> deleteMascota(int idMascota) async {
    await _client
        .from('mascota')
        .delete()
        .eq('id_mascota', idMascota);
  }
}

