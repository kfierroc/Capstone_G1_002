import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/grifo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HydrantsAdminService {
  HydrantsAdminService._();

  static final HydrantsAdminService instance = HydrantsAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Grifo>> fetchHydrants({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('grifo')
        .select('id_grifo, lat, lon, cut_com')
        .order('id_grifo')
        .range(offset, offset + limit - 1);

    final list = (data as List).cast<Map<String, dynamic>>();
    final hydrants = list.map(Grifo.fromJson).toList();

    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      return hydrants.where((grifo) {
        final id = grifo.idGrifo.toString();
        final coordinates = '${grifo.lat},${grifo.lon}'.toLowerCase();
        return id.contains(term) ||
            coordinates.contains(term) ||
            grifo.cutCom.toString().contains(term);
      }).toList();
    }

    return hydrants;
  }

  Future<void> insertHydrant(Grifo grifo) async {
    await _client.from('grifo').insert(grifo.toInsertData());
  }

  Future<void> updateHydrant(Grifo grifo) async {
    await _client
        .from('grifo')
        .update(grifo.toUpdateData())
        .eq('id_grifo', grifo.idGrifo);
  }

  Future<void> deleteHydrant(int id) async {
    await _client.from('grifo').delete().eq('id_grifo', id);
  }
}




