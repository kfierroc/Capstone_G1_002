import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio para manejar operaciones CRUD de residencias
/// Incluye métodos seguros con try/catch para todas las operaciones
class ResidenciaService {
  static final ResidenciaService _instance = ResidenciaService._internal();
  factory ResidenciaService() => _instance;
  ResidenciaService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar una nueva residencia
  Future<ServiceResult<Residencia>> insertResidencia(Residencia residencia) async {
    try {
      final response = await _client
          .from('residencia')
          .insert(residencia.toInsertData())
          .select()
          .single();

      final nuevaResidencia = Residencia.fromJson(response);
      return ServiceResult.success(nuevaResidencia);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar residencia: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar residencia: ${e.toString()}');
    }
  }

  /// Obtener residencia por ID
  Future<ServiceResult<Residencia>> getResidenciaById(int idResidencia) async {
    try {
      final response = await _client
          .from('residencia')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('id_residencia', idResidencia)
          .single();

      final residencia = Residencia.fromJson(response);
      return ServiceResult.success(residencia);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener residencia: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener residencia: ${e.toString()}');
    }
  }

  /// Obtener todas las residencias de una comuna
  Future<ServiceResult<List<Residencia>>> getResidenciasByComuna(String cutCom) async {
    try {
      final response = await _client
          .from('residencia')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('cut_com', cutCom);

      final residencias = (response as List)
          .map((json) => Residencia.fromJson(json))
          .toList();

      return ServiceResult.success(residencias);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener residencias: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener residencias: ${e.toString()}');
    }
  }

  /// Buscar residencias por dirección (búsqueda parcial)
  Future<ServiceResult<List<Residencia>>> searchResidenciasByDireccion(String direccion) async {
    try {
      final response = await _client
          .from('residencia')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .ilike('direccion', '%$direccion%')
          .limit(50);

      final residencias = (response as List)
          .map((json) => Residencia.fromJson(json))
          .toList();

      return ServiceResult.success(residencias);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al buscar residencias: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al buscar residencias: ${e.toString()}');
    }
  }

  /// Buscar residencias cercanas a coordenadas (radio aproximado)
  Future<ServiceResult<List<Residencia>>> getResidenciasNearby({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    try {
      // Usar una consulta SQL personalizada para búsqueda por radio
      final response = await _client
          .rpc('get_residencias_nearby', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      final residencias = (response as List)
          .map((json) => Residencia.fromJson(json))
          .toList();

      return ServiceResult.success(residencias);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al buscar residencias cercanas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al buscar residencias cercanas: ${e.toString()}');
    }
  }

  /// Actualizar residencia
  Future<ServiceResult<Residencia>> updateResidencia(Residencia residencia) async {
    try {
      final response = await _client
          .from('residencia')
          .update(residencia.toJson())
          .eq('id_residencia', residencia.idResidencia)
          .select()
          .single();

      final residenciaActualizada = Residencia.fromJson(response);
      return ServiceResult.success(residenciaActualizada);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar residencia: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar residencia: ${e.toString()}');
    }
  }

  /// Eliminar residencia
  Future<ServiceResult<void>> deleteResidencia(int idResidencia) async {
    try {
      await _client
          .from('residencia')
          .delete()
          .eq('id_residencia', idResidencia);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar residencia: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar residencia: ${e.toString()}');
    }
  }

  /// Verificar si existe una residencia con la misma dirección en la misma comuna
  Future<ServiceResult<bool>> existeResidencia(String direccion, String cutCom) async {
    try {
      final response = await _client
          .from('residencia')
          .select('id_residencia')
          .eq('direccion', direccion)
          .eq('cut_com', cutCom)
          .limit(1);

      return ServiceResult.success((response as List).isNotEmpty);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al verificar residencia: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al verificar residencia: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de residencias por comuna
  Future<ServiceResult<Map<String, int>>> getEstadisticasResidencias() async {
    try {
      final response = await _client
          .from('residencia')
          .select('cut_com, comunas!inner(comuna)');

      final Map<String, int> estadisticas = {};
      
      for (final item in response as List) {
        final comuna = item['comunas']['comuna'] as String;
        estadisticas[comuna] = (estadisticas[comuna] ?? 0) + 1;
      }

      return ServiceResult.success(estadisticas);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas: ${e.toString()}');
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
