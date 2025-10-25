import 'base_database_service.dart';
import 'database_common.dart';
import '../../models/models.dart';

/// Servicio especializado para operaciones de residencias
class ResidenciaService extends BaseDatabaseService {

  /// Crear residencia
  Future<DatabaseResult<Residencia>> crearResidencia({
    required int idResidencia,
    required String direccion,
    required double lat,
    required double lon,
    required int cutCom,
    int? numeroPisos,
    String? instruccionesEspeciales,
  }) async {
    try {
      logProgress('Creando residencia', details: 'ID: $idResidencia, dirección: $direccion');
      
      final residenciaData = {
        'id_residencia': idResidencia,
        'direccion': direccion,
        'lat': lat,
        'lon': lon,
        'cut_com': cutCom,
        'numero_pisos': numeroPisos,
      };
      
      logProgress('Insertando residencia', details: 'Datos: $residenciaData');
      
      final response = await client
          .from('residencia')
          .insert(residenciaData)
          .select()
          .single();
      
      final residencia = Residencia.fromJson(response);
      logSuccess('Residencia creada', details: 'ID: ${residencia.idResidencia}');
      
      return success(residencia, message: 'Residencia creada exitosamente');
      
    } catch (e) {
      logError('Crear residencia', e);
      return handleError(e, customMessage: 'Error al crear residencia');
    }
  }

  /// Obtener residencia por ID
  Future<DatabaseResult<Residencia>> obtenerResidencia({
    required String residenciaId,
  }) async {
    try {
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Obteniendo residencia', details: 'ID: $residenciaId');
      
      final response = await client
          .from('residencia')
          .select()
          .eq('id_residencia', int.parse(residenciaId))
          .maybeSingle();
      
      if (response == null) {
        return error('Residencia no encontrada con ID: $residenciaId');
      }
      
      final residencia = Residencia.fromJson(response);
      logSuccess('Residencia obtenida', details: 'ID: ${residencia.idResidencia}');
      
      return success(residencia);
      
    } catch (e) {
      logError('Obtener residencia', e);
      return handleError(e, customMessage: 'Error al obtener residencia');
    }
  }

  /// Obtener residencia por dirección
  Future<DatabaseResult<Residencia>> obtenerResidenciaPorDireccion({
    required String direccion,
  }) async {
    try {
      logProgress('Obteniendo residencia por dirección', details: 'Dirección: $direccion');
      
      final response = await client
          .from('residencia')
          .select()
          .eq('direccion', direccion.trim())
          .maybeSingle();
      
      if (response == null) {
        return error('Residencia no encontrada con dirección: $direccion');
      }
      
      final residencia = Residencia.fromJson(response);
      logSuccess('Residencia obtenida por dirección', details: 'ID: ${residencia.idResidencia}');
      
      return success(residencia);
      
    } catch (e) {
      logError('Obtener residencia por dirección', e);
      return handleError(e, customMessage: 'Error al obtener residencia por dirección');
    }
  }

  /// Actualizar residencia
  Future<DatabaseResult<Residencia>> actualizarResidencia({
    required String residenciaId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Actualizando residencia', details: 'ID: $residenciaId, updates: $updates');
      
      // Manejar instrucciones especiales si están en los updates
      if (updates.containsKey('specialInstructions')) {
        // Campo eliminado - no hacer nada
        updates.remove('specialInstructions');
      }
      
      final response = await client
          .from('residencia')
          .update(updates)
          .eq('id_residencia', int.parse(residenciaId))
          .select()
          .single();
      
      final residencia = Residencia.fromJson(response);
      logSuccess('Residencia actualizada', details: 'ID: ${residencia.idResidencia}');
      
      return success(residencia, message: 'Residencia actualizada exitosamente');
      
    } catch (e) {
      logError('Actualizar residencia', e);
      return handleError(e, customMessage: 'Error al actualizar residencia');
    }
  }

  /// Actualizar instrucciones especiales
  Future<DatabaseResult<void>> actualizarInstruccionesEspeciales({
    required String residenciaId,
    required String? instrucciones,
  }) async {
    try {
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Actualizando instrucciones especiales', details: 'ID: $residenciaId');
      
      final updates = <String, dynamic>{
        // Campo instrucciones_especiales eliminado del sistema
      };
      
      await client
          .from('residencia')
          .update(updates)
          .eq('id_residencia', int.parse(residenciaId));
      
      logSuccess('Instrucciones especiales actualizadas', details: 'ID: $residenciaId');
      
      return success(null, message: 'Instrucciones especiales actualizadas exitosamente');
      
    } catch (e) {
      logError('Actualizar instrucciones especiales', e);
      return handleError(e, customMessage: 'Error al actualizar instrucciones especiales');
    }
  }

  /// Obtener instrucciones especiales
  Future<DatabaseResult<String?>> obtenerInstruccionesEspeciales({
    required String residenciaId,
  }) async {
    try {
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Obteniendo instrucciones especiales', details: 'ID: $residenciaId');
      
      final response = await client
          .from('residencia')
          .select('id_residencia')
          .eq('id_residencia', int.parse(residenciaId))
          .maybeSingle();
      
      if (response == null) {
        return error('Residencia no encontrada con ID: $residenciaId');
      }
      
      String? instrucciones; // Campo eliminado
      
      logSuccess('Instrucciones especiales obtenidas', details: 'ID: $residenciaId');
      
      return success(instrucciones);
      
    } catch (e) {
      logError('Obtener instrucciones especiales', e);
      return handleError(e, customMessage: 'Error al obtener instrucciones especiales');
    }
  }

  /// Buscar residencias por coordenadas (para bomberos)
  Future<DatabaseResult<List<Map<String, dynamic>>>> buscarResidenciasPorCoordenadas({
    required double lat,
    required double lon,
    double radiusKm = 5.0,
  }) async {
    try {
      logProgress('Buscando residencias por coordenadas', details: 'lat: $lat, lon: $lon, radio: ${radiusKm}km');
      
      // Usar la función de búsqueda geográfica si existe
      final response = await client
          .rpc('search_residencias_nearby', params: {
            'lat': lat,
            'lon': lon,
            'radius_km': radiusKm,
          });
      
      final residencias = (response as List).cast<Map<String, dynamic>>();
      
      logSuccess('Residencias encontradas', details: 'Cantidad: ${residencias.length}');
      
      return success(residencias);
      
    } catch (e) {
      logError('Buscar residencias por coordenadas', e);
      return handleError(e, customMessage: 'Error al buscar residencias por coordenadas');
    }
  }

  /// Eliminar residencia
  Future<DatabaseResult<void>> eliminarResidencia({
    required String residenciaId,
  }) async {
    try {
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Eliminando residencia', details: 'ID: $residenciaId');
      
      await client
          .from('residencia')
          .delete()
          .eq('id_residencia', int.parse(residenciaId));
      
      logSuccess('Residencia eliminada', details: 'ID: $residenciaId');
      
      return success(null, message: 'Residencia eliminada exitosamente');
      
    } catch (e) {
      logError('Eliminar residencia', e);
      return handleError(e, customMessage: 'Error al eliminar residencia');
    }
  }

  /// Obtener todas las residencias (para administración)
  Future<DatabaseResult<List<Residencia>>> obtenerTodasLasResidencias() async {
    try {
      logProgress('Obteniendo todas las residencias');
      
      final response = await client
          .from('residencia')
          .select()
          .order('created_at', ascending: false);
      
      final residencias = (response as List)
          .map((json) => Residencia.fromJson(json))
          .toList();
      
      logSuccess('Residencias obtenidas', details: 'Cantidad: ${residencias.length}');
      
      return success(residencias);
      
    } catch (e) {
      logError('Obtener todas las residencias', e);
      return handleError(e, customMessage: 'Error al obtener residencias');
    }
  }
}
