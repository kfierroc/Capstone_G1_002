import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio para manejar operaciones CRUD de grifos
/// Incluye métodos seguros con try/catch para todas las operaciones
class GrifoService {
  static final GrifoService _instance = GrifoService._internal();
  factory GrifoService() => _instance;
  GrifoService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar un nuevo grifo
  Future<ServiceResult<Grifo>> insertGrifo(Grifo grifo) async {
    try {
      final response = await _client
          .from('grifo')
          .insert(grifo.toInsertData())
          .select()
          .single();

      final nuevoGrifo = Grifo.fromJson(response);
      return ServiceResult.success(nuevoGrifo);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar grifo: ${e.toString()}');
    }
  }

  /// Obtener grifo por ID
  Future<ServiceResult<Grifo>> getGrifoById(int idGrifo) async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('id_grifo', idGrifo)
          .single();

      final grifo = Grifo.fromJson(response);
      return ServiceResult.success(grifo);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifo: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos de una comuna
  Future<ServiceResult<List<Grifo>>> getGrifosByComuna(String cutCom) async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('cut_com', cutCom);

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      return ServiceResult.success(grifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos con su información adicional
  Future<ServiceResult<List<Map<String, dynamic>>>> getGrifosConInfo() async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*),
            info_grifo(*)
          ''');

      return ServiceResult.success(response);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos con información: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos con información: ${e.toString()}');
    }
  }

  /// Buscar grifos cercanos a coordenadas (radio aproximado)
  Future<ServiceResult<List<Grifo>>> getGrifosNearby({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    try {
      // Usar una consulta SQL personalizada para búsqueda por radio
      final response = await _client
          .rpc('get_grifos_nearby', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      return ServiceResult.success(grifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al buscar grifos cercanos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al buscar grifos cercanos: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de grifos por comuna
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasGrifos() async {
    try {
      final response = await _client
          .from('grifo')
          .select('cut_com, comunas!inner(comuna)');

      final Map<String, int> estadisticas = {};
      
      for (final item in response as List) {
        final comuna = item['comunas']['comuna'] as String;
        estadisticas[comuna] = (estadisticas[comuna] ?? 0) + 1;
      }

      return ServiceResult.success({
        'total_grifos': estadisticas.values.fold(0, (sum, count) => sum + count),
        'por_comuna': estadisticas,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas: ${e.toString()}');
    }
  }

  /// Actualizar grifo
  Future<ServiceResult<Grifo>> updateGrifo(Grifo grifo) async {
    try {
      final response = await _client
          .from('grifo')
          .update(grifo.toJson())
          .eq('id_grifo', grifo.idGrifo)
          .select()
          .single();

      final grifoActualizado = Grifo.fromJson(response);
      return ServiceResult.success(grifoActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar grifo: ${e.toString()}');
    }
  }

  /// Eliminar grifo
  Future<ServiceResult<void>> deleteGrifo(int idGrifo) async {
    try {
      await _client
          .from('grifo')
          .delete()
          .eq('id_grifo', idGrifo);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar grifo: ${e.toString()}');
    }
  }

  /// Verificar si existe un grifo en las mismas coordenadas
  Future<ServiceResult<bool>> existeGrifoEnCoordenadas(double lat, double lon) async {
    try {
      final response = await _client
          .from('grifo')
          .select('id_grifo')
          .eq('lat', lat)
          .eq('lon', lon)
          .limit(1);

      return ServiceResult.success((response as List).isNotEmpty);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al verificar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al verificar grifo: ${e.toString()}');
    }
  }
}

/// Servicio para manejar operaciones CRUD de info_grifo
class InfoGrifoService {
  static final InfoGrifoService _instance = InfoGrifoService._internal();
  factory InfoGrifoService() => _instance;
  InfoGrifoService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar información de grifo
  Future<ServiceResult<InfoGrifo>> insertInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .insert(infoGrifo.toInsertData())
          .select()
          .single();

      final nuevaInfoGrifo = InfoGrifo.fromJson(response);
      return ServiceResult.success(nuevaInfoGrifo);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar información de grifo: ${e.toString()}');
    }
  }

  /// Obtener información de grifo por ID de grifo
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifoByGrifoId(int idGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('''
            *,
            bombero!inner(*)
          ''')
          .eq('id_grifo', idGrifo);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      return ServiceResult.success(infoGrifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información de grifo: ${e.toString()}');
    }
  }

  /// Obtener información de grifo por RUT de bombero
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifoByBomberoRut(int rutNum) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('''
            *,
            grifo!inner(
              *,
              comunas!inner(*)
            ),
            bombero!inner(*)
          ''')
          .eq('rut_num', rutNum);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      return ServiceResult.success(infoGrifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información de grifo por bombero: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información de grifo por bombero: ${e.toString()}');
    }
  }

  /// Actualizar información de grifo
  Future<ServiceResult<InfoGrifo>> updateInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .update(infoGrifo.toUpdateData())
          .eq('id_reg_grifo', infoGrifo.idRegGrifo)
          .select()
          .single();

      final infoGrifoActualizado = InfoGrifo.fromJson(response);
      return ServiceResult.success(infoGrifoActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar información de grifo: ${e.toString()}');
    }
  }

  /// Eliminar información de grifo
  Future<ServiceResult<void>> deleteInfoGrifo(int idRegGrifo) async {
    try {
      await _client
          .from('info_grifo')
          .delete()
          .eq('id_reg_grifo', idRegGrifo);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar información de grifo: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de inspecciones por bombero
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasInspecciones(int rutNum) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('estado')
          .eq('rut_num', rutNum);

      final Map<String, int> estadisticas = {};
      
      for (final item in response as List) {
        final estado = item['estado'] as String;
        estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
      }

      return ServiceResult.success({
        'total_inspecciones': estadisticas.values.fold(0, (sum, count) => sum + count),
        'por_estado': estadisticas,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas de inspecciones: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas de inspecciones: ${e.toString()}');
    }
  }
}

/// Clase para representar el resultado de operaciones de servicio
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ServiceResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ServiceResult.success(T data) => ServiceResult._(
    isSuccess: true,
    data: data,
  );

  factory ServiceResult.error(String error) => ServiceResult._(
    isSuccess: false,
    error: error,
  );
}
