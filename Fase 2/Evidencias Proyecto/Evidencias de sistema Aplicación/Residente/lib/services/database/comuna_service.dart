import 'base_database_service.dart';
import 'database_common.dart';
import '../../models/models.dart';

/// Servicio especializado para operaciones de comunas
class ComunaService extends BaseDatabaseService {

  /// Obtener todas las comunas
  Future<DatabaseResult<List<Comuna>>> obtenerComunas() async {
    try {
      logProgress('Obteniendo todas las comunas');
      
      final response = await client
          .from('comunas')
          .select()
          .order('comuna', ascending: true);
      
      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();
      
      logSuccess('Comunas obtenidas', details: 'Cantidad: ${comunas.length}');
      
      return success(comunas);
      
    } catch (e) {
      logError('Obtener comunas', e);
      return handleError(e, customMessage: 'Error al obtener comunas');
    }
  }

  /// Obtener comuna por ID
  Future<DatabaseResult<Comuna>> obtenerComuna({
    required String cutCom,
  }) async {
    try {
      if (!isValidId(cutCom)) {
        return error('ID de comuna inválido');
      }
      
      logProgress('Obteniendo comuna', details: 'cutCom: $cutCom');
      
      final response = await client
          .from('comunas')
          .select()
          .eq('cut_com', int.parse(cutCom))
          .maybeSingle();
      
      if (response == null) {
        return error('Comuna no encontrada con ID: $cutCom');
      }
      
      final comuna = Comuna.fromJson(response);
      logSuccess('Comuna obtenida', details: 'ID: ${comuna.cutCom}, Nombre: ${comuna.comuna}');
      
      return success(comuna);
      
    } catch (e) {
      logError('Obtener comuna', e);
      return handleError(e, customMessage: 'Error al obtener comuna');
    }
  }

  /// Buscar comunas por nombre
  Future<DatabaseResult<List<Comuna>>> buscarComunas({
    required String query,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return error('La consulta de búsqueda no puede estar vacía');
      }
      
      logProgress('Buscando comunas', details: 'Query: $query');
      
      final response = await client
          .from('comunas')
          .select()
          .ilike('comuna', '%${query.trim()}%')
          .order('comuna', ascending: true);
      
      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();
      
      logSuccess('Comunas encontradas', details: 'Cantidad: ${comunas.length}');
      
      return success(comunas);
      
    } catch (e) {
      logError('Buscar comunas', e);
      return handleError(e, customMessage: 'Error al buscar comunas');
    }
  }

  /// Obtener comunas por región
  Future<DatabaseResult<List<Comuna>>> obtenerComunasPorRegion({
    required String region,
  }) async {
    try {
      logProgress('Obteniendo comunas por región', details: 'Región: $region');
      
      final response = await client
          .from('comunas')
          .select()
          .eq('region', region.trim())
          .order('comuna', ascending: true);
      
      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();
      
      logSuccess('Comunas obtenidas por región', details: 'Cantidad: ${comunas.length}');
      
      return success(comunas);
      
    } catch (e) {
      logError('Obtener comunas por región', e);
      return handleError(e, customMessage: 'Error al obtener comunas por región');
    }
  }

  /// Obtener comunas por provincia
  Future<DatabaseResult<List<Comuna>>> obtenerComunasPorProvincia({
    required String provincia,
  }) async {
    try {
      logProgress('Obteniendo comunas por provincia', details: 'Provincia: $provincia');
      
      final response = await client
          .from('comunas')
          .select()
          .eq('provincia', provincia.trim())
          .order('comuna', ascending: true);
      
      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();
      
      logSuccess('Comunas obtenidas por provincia', details: 'Cantidad: ${comunas.length}');
      
      return success(comunas);
      
    } catch (e) {
      logError('Obtener comunas por provincia', e);
      return handleError(e, customMessage: 'Error al obtener comunas por provincia');
    }
  }

  /// Obtener todas las regiones
  Future<DatabaseResult<List<String>>> obtenerRegiones() async {
    try {
      logProgress('Obteniendo todas las regiones');
      
      final response = await client
          .from('comunas')
          .select('region')
          .order('region', ascending: true);
      
      final regiones = (response as List)
          .map((json) => json['region'] as String)
          .toSet() // Eliminar duplicados
          .toList();
      
      logSuccess('Regiones obtenidas', details: 'Cantidad: ${regiones.length}');
      
      return success(regiones);
      
    } catch (e) {
      logError('Obtener regiones', e);
      return handleError(e, customMessage: 'Error al obtener regiones');
    }
  }

  /// Obtener provincias por región
  Future<DatabaseResult<List<String>>> obtenerProvinciasPorRegion({
    required String region,
  }) async {
    try {
      logProgress('Obteniendo provincias por región', details: 'Región: $region');
      
      final response = await client
          .from('comunas')
          .select('provincia')
          .eq('region', region.trim())
          .order('provincia', ascending: true);
      
      final provincias = (response as List)
          .map((json) => json['provincia'] as String)
          .toSet() // Eliminar duplicados
          .toList();
      
      logSuccess('Provincias obtenidas por región', details: 'Cantidad: ${provincias.length}');
      
      return success(provincias);
      
    } catch (e) {
      logError('Obtener provincias por región', e);
      return handleError(e, customMessage: 'Error al obtener provincias por región');
    }
  }

  /// Obtener estadísticas de comunas
  Future<DatabaseResult<Map<String, dynamic>>> obtenerEstadisticasComunas() async {
    try {
      logProgress('Obteniendo estadísticas de comunas');
      
      final response = await client
          .from('comunas')
          .select('region, provincia, superficie');
      
      final comunas = (response as List).cast<Map<String, dynamic>>();
      
      // Calcular estadísticas
      final totalComunas = comunas.length;
      final regiones = <String, int>{};
      final provincias = <String, int>{};
      double superficieTotal = 0;
      
      for (final comuna in comunas) {
        final region = comuna['region'] as String? ?? 'No especificada';
        final provincia = comuna['provincia'] as String? ?? 'No especificada';
        final superficie = (comuna['superficie'] as num?)?.toDouble() ?? 0;
        
        regiones[region] = (regiones[region] ?? 0) + 1;
        provincias[provincia] = (provincias[provincia] ?? 0) + 1;
        superficieTotal += superficie;
      }
      
      final estadisticas = {
        'total_comunas': totalComunas,
        'total_regiones': regiones.length,
        'total_provincias': provincias.length,
        'superficie_total': superficieTotal,
        'superficie_promedio': totalComunas > 0 ? superficieTotal / totalComunas : 0,
        'regiones': regiones,
        'provincias': provincias,
        'region_con_mas_comunas': regiones.isNotEmpty 
            ? regiones.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'provincia_con_mas_comunas': provincias.isNotEmpty 
            ? provincias.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
      };
      
      logSuccess('Estadísticas de comunas obtenidas', details: 'Total: $totalComunas');
      
      return success(estadisticas);
      
    } catch (e) {
      logError('Obtener estadísticas de comunas', e);
      return handleError(e, customMessage: 'Error al obtener estadísticas de comunas');
    }
  }

  /// Verificar si existe una comuna
  Future<bool> existeComuna(String cutCom) async {
    try {
      if (!isValidId(cutCom)) {
        return false;
      }
      
      final response = await client
          .from('comunas')
          .select('cut_com')
          .eq('cut_com', int.parse(cutCom))
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      logError('Verificar existencia de comuna', e);
      return false;
    }
  }

  /// Obtener comuna más cercana por coordenadas (si hay datos de geometría)
  Future<DatabaseResult<Comuna?>> obtenerComunaMasCercana({
    required double lat,
    required double lon,
  }) async {
    try {
      logProgress('Obteniendo comuna más cercana', details: 'lat: $lat, lon: $lon');
      
      // Esta consulta requiere que la tabla tenga datos de geometría
      // Por ahora, devolvemos null hasta que se implemente la funcionalidad geográfica
      logProgress('Funcionalidad geográfica no implementada aún');
      
      return success(null);
      
    } catch (e) {
      logError('Obtener comuna más cercana', e);
      return handleError(e, customMessage: 'Error al obtener comuna más cercana');
    }
  }
}
