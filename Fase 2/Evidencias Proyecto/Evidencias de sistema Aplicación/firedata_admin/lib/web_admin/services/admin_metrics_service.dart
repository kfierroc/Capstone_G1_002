import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firedata_admin/config/supabase_config.dart';

class AdminMetrics {
  final int residents;
  final int firefighters;
  final int houses;
  final int hydrants;

  const AdminMetrics({
    required this.residents,
    required this.firefighters,
    required this.houses,
    required this.hydrants,
  });
}

class AdminMetricsService {
  AdminMetricsService._();

  static final AdminMetricsService instance = AdminMetricsService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<AdminMetrics> loadMetrics() async {
    final residents = await _countTable(
      table: 'grupofamiliar',
      idColumn: 'id_grupof',
    );
    final firefighters = await _countTable(
      table: 'bombero',
      idColumn: 'rut_num',
    );
    final houses = await _countTable(
      table: 'residencia',
      idColumn: 'id_residencia',
    );
    final hydrants = await _countTable(
      table: 'grifo',
      idColumn: 'id_grifo',
    );

    return AdminMetrics(
      residents: residents,
      firefighters: firefighters,
      houses: houses,
      hydrants: hydrants,
    );
  }

  Future<int> _countTable({
    required String table,
    required String idColumn,
  }) async {
    try {
      final response = await _client.from(table).select(idColumn);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }
}




