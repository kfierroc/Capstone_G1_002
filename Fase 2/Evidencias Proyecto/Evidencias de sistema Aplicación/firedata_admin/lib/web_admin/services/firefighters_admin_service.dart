import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/bombero.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirefightersAdminService {
  FirefightersAdminService._();

  static final FirefightersAdminService instance = FirefightersAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Bombero>> fetchFirefighters({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('bombero')
        .select(
          'rut_num, rut_dv, compania, nomb_bombero, ape_p_bombero, email_b, cut_com',
        )
        .order('nomb_bombero')
        .range(offset, offset + limit - 1);

    final list = (data as List).cast<Map<String, dynamic>>();
    final firefighters = list.map(Bombero.fromJson).toList();

    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      return firefighters.where((bombero) {
        final email = bombero.emailB ?? '';
        return bombero.nombBombero.toLowerCase().contains(term) ||
            bombero.apePBombero.toLowerCase().contains(term) ||
            email.toLowerCase().contains(term) ||
            bombero.rutCompleto.toLowerCase().contains(term);
      }).toList();
    }

    return firefighters;
  }

  Future<void> insertFirefighter(Bombero bombero) async {
    await _client.from('bombero').insert(bombero.toJson());
  }

  Future<void> updateFirefighter(Bombero bombero) async {
    await _client.from('bombero').update(bombero.toJson()).eq('rut_num', bombero.rutNum);
  }

  Future<void> deleteFirefighter(int rutNum) async {
    await _client.from('bombero').delete().eq('rut_num', rutNum);
  }
}




