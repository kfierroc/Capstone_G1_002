import '../config/supabase_config.dart';

/// Servicio para manejar búsquedas de domicilios
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  /// Busca domicilios por dirección
  Future<List<Map<String, dynamic>>> searchAddresses(String query) async {
    try {
      final response = await SupabaseConfig.client
          .from('domicilio')
          .select()
          .ilike('direccion', '%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // En caso de error, retornar datos de ejemplo
      return _getMockData();
    }
  }

  /// Obtiene datos de ejemplo para desarrollo
  List<Map<String, dynamic>> _getMockData() {
    return [
      {
        'id': '1',
        'address': 'Av. Libertador 1234, Depto 5B, Las Condes, Santiago',
        'people_count': 4,
        'pets_count': 2,
        'last_update': '2024-01-15',
      },
      {
        'id': '2',
        'address': 'Calle Principal 567, Casa 12, Maipú, Santiago',
        'people_count': 3,
        'pets_count': 1,
        'last_update': '2024-01-10',
      },
    ];
  }

  /// Valida si una consulta de búsqueda es válida
  bool isValidSearchQuery(String query) {
    return query.trim().isNotEmpty && query.trim().length >= 3;
  }

  /// Formatea la consulta de búsqueda
  String formatSearchQuery(String query) {
    return query.trim().toLowerCase();
  }
}
