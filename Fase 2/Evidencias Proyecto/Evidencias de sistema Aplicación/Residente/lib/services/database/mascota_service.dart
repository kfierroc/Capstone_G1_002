import 'base_database_service.dart';
import 'database_common.dart';
import '../../models/models.dart';

/// Servicio especializado para operaciones de mascotas
class MascotaService extends BaseDatabaseService {

  /// Crear mascota
  Future<DatabaseResult<Mascota>> crearMascota({
    required String grupoId,
    required String nombreM,
    required String especie,
    required String tamanio,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Creando mascota', details: 'grupoId: $grupoId, nombre: $nombreM');
      
      final mascotaId = DateTime.now().millisecondsSinceEpoch;
      
      final mascotaData = {
        'id_mascota': mascotaId,
        'id_grupof': int.parse(grupoId),
        'nombre_m': nombreM,
        'especie': especie,
        'tamanio': tamanio,
        'fecha_reg_m': DateTime.now().toIso8601String().split('T')[0],
      };
      
      logProgress('Insertando mascota', details: 'Datos: $mascotaData');
      
      final response = await client
          .from('mascota')
          .insert(mascotaData)
          .select()
          .single();
      
      final mascota = Mascota.fromJson(response);
      logSuccess('Mascota creada', details: 'ID: ${mascota.idMascota}');
      
      return success(mascota, message: 'Mascota creada exitosamente');
      
    } catch (e) {
      logError('Crear mascota', e);
      return handleError(e, customMessage: 'Error al crear mascota');
    }
  }

  /// Obtener mascotas de un grupo familiar
  Future<DatabaseResult<List<Mascota>>> obtenerMascotas({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo mascotas', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('mascota')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .order('fecha_reg_m', ascending: false);
      
      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();
      
      logSuccess('Mascotas obtenidas', details: 'Cantidad: ${mascotas.length}');
      
      return success(mascotas);
      
    } catch (e) {
      logError('Obtener mascotas', e);
      return handleError(e, customMessage: 'Error al obtener mascotas');
    }
  }

  /// Obtener mascota por ID
  Future<DatabaseResult<Mascota>> obtenerMascota({
    required String mascotaId,
  }) async {
    try {
      if (!isValidId(mascotaId)) {
        return error('ID de mascota inválido');
      }
      
      logProgress('Obteniendo mascota', details: 'ID: $mascotaId');
      
      final response = await client
          .from('mascota')
          .select()
          .eq('id_mascota', int.parse(mascotaId))
          .maybeSingle();
      
      if (response == null) {
        return error('Mascota no encontrada con ID: $mascotaId');
      }
      
      final mascota = Mascota.fromJson(response);
      logSuccess('Mascota obtenida', details: 'ID: ${mascota.idMascota}');
      
      return success(mascota);
      
    } catch (e) {
      logError('Obtener mascota', e);
      return handleError(e, customMessage: 'Error al obtener mascota');
    }
  }

  /// Actualizar mascota
  Future<DatabaseResult<Mascota>> actualizarMascota({
    required String mascotaId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(mascotaId)) {
        return error('ID de mascota inválido');
      }
      
      logProgress('Actualizando mascota', details: 'ID: $mascotaId, updates: $updates');
      
      final response = await client
          .from('mascota')
          .update(updates)
          .eq('id_mascota', int.parse(mascotaId))
          .select()
          .single();
      
      final mascota = Mascota.fromJson(response);
      logSuccess('Mascota actualizada', details: 'ID: ${mascota.idMascota}');
      
      return success(mascota, message: 'Mascota actualizada exitosamente');
      
    } catch (e) {
      logError('Actualizar mascota', e);
      return handleError(e, customMessage: 'Error al actualizar mascota');
    }
  }

  /// Eliminar mascota
  Future<DatabaseResult<void>> eliminarMascota({
    required String mascotaId,
  }) async {
    try {
      if (!isValidId(mascotaId)) {
        return error('ID de mascota inválido');
      }
      
      logProgress('Eliminando mascota', details: 'ID: $mascotaId');
      
      await client
          .from('mascota')
          .delete()
          .eq('id_mascota', int.parse(mascotaId));
      
      logSuccess('Mascota eliminada', details: 'ID: $mascotaId');
      
      return success(null, message: 'Mascota eliminada exitosamente');
      
    } catch (e) {
      logError('Eliminar mascota', e);
      return handleError(e, customMessage: 'Error al eliminar mascota');
    }
  }

  /// Obtener todas las mascotas (para administración)
  Future<DatabaseResult<List<Mascota>>> obtenerTodasLasMascotas() async {
    try {
      logProgress('Obteniendo todas las mascotas');
      
      final response = await client
          .from('mascota')
          .select()
          .order('fecha_reg_m', ascending: false);
      
      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();
      
      logSuccess('Mascotas obtenidas', details: 'Cantidad: ${mascotas.length}');
      
      return success(mascotas);
      
    } catch (e) {
      logError('Obtener todas las mascotas', e);
      return handleError(e, customMessage: 'Error al obtener mascotas');
    }
  }

  /// Buscar mascotas por especie
  Future<DatabaseResult<List<Mascota>>> buscarMascotasPorEspecie({
    required String especie,
  }) async {
    try {
      logProgress('Buscando mascotas por especie', details: 'Especie: $especie');
      
      final response = await client
          .from('mascota')
          .select()
          .ilike('especie', '%$especie%')
          .order('fecha_reg_m', ascending: false);
      
      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();
      
      logSuccess('Mascotas encontradas por especie', details: 'Cantidad: ${mascotas.length}');
      
      return success(mascotas);
      
    } catch (e) {
      logError('Buscar mascotas por especie', e);
      return handleError(e, customMessage: 'Error al buscar mascotas por especie');
    }
  }

  /// Buscar mascotas por tamaño
  Future<DatabaseResult<List<Mascota>>> buscarMascotasPorTamanio({
    required String tamanio,
  }) async {
    try {
      logProgress('Buscando mascotas por tamaño', details: 'Tamaño: $tamanio');
      
      final response = await client
          .from('mascota')
          .select()
          .eq('tamanio', tamanio)
          .order('fecha_reg_m', ascending: false);
      
      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();
      
      logSuccess('Mascotas encontradas por tamaño', details: 'Cantidad: ${mascotas.length}');
      
      return success(mascotas);
      
    } catch (e) {
      logError('Buscar mascotas por tamaño', e);
      return handleError(e, customMessage: 'Error al buscar mascotas por tamaño');
    }
  }

  /// Obtener estadísticas de mascotas por grupo familiar
  Future<DatabaseResult<Map<String, dynamic>>> obtenerEstadisticasMascotas({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo estadísticas de mascotas', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('mascota')
          .select('especie, tamanio')
          .eq('id_grupof', int.parse(grupoId));
      
      final mascotas = (response as List).cast<Map<String, dynamic>>();
      
      // Calcular estadísticas
      final totalMascotas = mascotas.length;
      final especies = <String, int>{};
      final tamanios = <String, int>{};
      
      for (final mascota in mascotas) {
        final especie = mascota['especie'] as String? ?? 'No especificada';
        final tamanio = mascota['tamanio'] as String? ?? 'No especificado';
        
        especies[especie] = (especies[especie] ?? 0) + 1;
        tamanios[tamanio] = (tamanios[tamanio] ?? 0) + 1;
      }
      
      final estadisticas = {
        'total_mascotas': totalMascotas,
        'especies': especies,
        'tamanios': tamanios,
        'especie_mas_comun': especies.isNotEmpty 
            ? especies.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'tamanio_mas_comun': tamanios.isNotEmpty 
            ? tamanios.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
      };
      
      logSuccess('Estadísticas de mascotas obtenidas', details: 'Total: $totalMascotas');
      
      return success(estadisticas);
      
    } catch (e) {
      logError('Obtener estadísticas de mascotas', e);
      return handleError(e, customMessage: 'Error al obtener estadísticas de mascotas');
    }
  }
}
