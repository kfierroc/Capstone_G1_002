import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/residencia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HousesAdminService {
  HousesAdminService._();

  static final HousesAdminService instance = HousesAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Residencia>> fetchHouses({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('residencia')
        .select(
          'id_residencia, direccion, lat, lon, cut_com',
        )
        .order('direccion')
        .range(offset, offset + limit - 1);

    final list = (data as List).cast<Map<String, dynamic>>();
    final houses = list.map(Residencia.fromJson).toList();

    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      return houses.where((house) {
        final phone = house.telefonoPrincipal ?? '';
        final instructions = house.instruccionesEspeciales ?? '';
        return house.direccion.toLowerCase().contains(term) ||
            phone.toLowerCase().contains(term) ||
            instructions.toLowerCase().contains(term);
      }).toList();
    }

    return houses;
  }

  Future<void> insertHouse(Residencia house) async {
    await _client.from('residencia').insert(house.toJson());
  }

  Future<void> updateHouse(Residencia house) async {
    await _client
        .from('residencia')
        .update(house.toJson())
        .eq('id_residencia', house.idResidencia);
  }

  Future<void> deleteHouse(int id) async {
    await _client.from('residencia').delete().eq('id_residencia', id);
  }
}




