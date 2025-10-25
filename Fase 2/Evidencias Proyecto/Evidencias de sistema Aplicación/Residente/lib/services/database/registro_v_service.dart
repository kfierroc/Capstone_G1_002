import 'base_database_service.dart';
import 'database_common.dart';

/// Servicio especializado para operaciones de registro_v
class RegistroVService extends BaseDatabaseService {

  /// Crear registro_v
  Future<DatabaseResult<Map<String, dynamic>>> crearRegistroV({
    required String grupoId,
    required String residenciaId,
    required String material,
    required String tipo,
    required int pisos,
    required String estado,
    DateTime? fechaIniR,
    DateTime? fechaFinR,
    bool vigente = true,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      if (!isValidId(residenciaId)) {
        return error('ID de residencia inválido');
      }
      
      logProgress('Creando registro_v', details: 'grupoId: $grupoId, residenciaId: $residenciaId');
      
      final idRegistro = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final registroData = {
        'id_registro': idRegistro,
        'vigente': vigente,
        'estado': estado,
        'material': material,
        'tipo': tipo,
        'pisos': pisos,
        'fecha_ini_r': (fechaIniR ?? DateTime.now()).toIso8601String().split('T')[0],
        'fecha_fin_r': fechaFinR?.toIso8601String().split('T')[0],
        'id_residencia': int.parse(residenciaId),
        'id_grupof': int.parse(grupoId),
      };
      
      logProgress('Insertando registro_v', details: 'Datos: $registroData');
      
      final response = await client
          .from('registro_v')
          .insert(registroData)
          .select()
          .single();
      
      logSuccess('Registro_v creado', details: 'ID: ${response['id_registro']}');
      
      return success(response, message: 'Registro_v creado exitosamente');
      
    } catch (e) {
      logError('Crear registro_v', e);
      return handleError(e, customMessage: 'Error al crear registro_v');
    }
  }

  /// Obtener registro_v por ID
  Future<DatabaseResult<Map<String, dynamic>>> obtenerRegistroV({
    required String registroId,
  }) async {
    try {
      if (!isValidId(registroId)) {
        return error('ID de registro_v inválido');
      }
      
      logProgress('Obteniendo registro_v', details: 'ID: $registroId');
      
      final response = await client
          .from('registro_v')
          .select()
          .eq('id_registro', int.parse(registroId))
          .maybeSingle();
      
      if (response == null) {
        return error('Registro_v no encontrado con ID: $registroId');
      }
      
      logSuccess('Registro_v obtenido', details: 'ID: ${response['id_registro']}');
      
      return success(response);
      
    } catch (e) {
      logError('Obtener registro_v', e);
      return handleError(e, customMessage: 'Error al obtener registro_v');
    }
  }

  /// Obtener registro_v vigente por grupo familiar
  Future<DatabaseResult<Map<String, dynamic>?>> obtenerRegistroVVigente({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo registro_v vigente', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('registro_v')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true)
          .order('fecha_ini_r', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) {
        logProgress('No se encontró registro_v vigente', details: 'grupoId: $grupoId');
        return success(null);
      }
      
      logSuccess('Registro_v vigente obtenido', details: 'ID: ${response['id_registro']}');
      
      return success(response);
      
    } catch (e) {
      logError('Obtener registro_v vigente', e);
      return handleError(e, customMessage: 'Error al obtener registro_v vigente');
    }
  }

  /// Obtener todos los registros_v de un grupo familiar
  Future<DatabaseResult<List<Map<String, dynamic>>>> obtenerRegistrosV({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo registros_v', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('registro_v')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .order('fecha_ini_r', ascending: false);
      
      final registros = (response as List).cast<Map<String, dynamic>>();
      
      logSuccess('Registros_v obtenidos', details: 'Cantidad: ${registros.length}');
      
      return success(registros);
      
    } catch (e) {
      logError('Obtener registros_v', e);
      return handleError(e, customMessage: 'Error al obtener registros_v');
    }
  }

  /// Actualizar registro_v
  Future<DatabaseResult<Map<String, dynamic>>> actualizarRegistroV({
    required String registroId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(registroId)) {
        return error('ID de registro_v inválido');
      }
      
      logProgress('Actualizando registro_v', details: 'ID: $registroId, updates: $updates');
      
      final response = await client
          .from('registro_v')
          .update(updates)
          .eq('id_registro', int.parse(registroId))
          .select()
          .single();
      
      logSuccess('Registro_v actualizado', details: 'ID: ${response['id_registro']}');
      
      return success(response, message: 'Registro_v actualizado exitosamente');
      
    } catch (e) {
      logError('Actualizar registro_v', e);
      return handleError(e, customMessage: 'Error al actualizar registro_v');
    }
  }

  /// Desactivar registros antiguos de un grupo familiar
  Future<DatabaseResult<void>> desactivarRegistrosAntiguos({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Desactivando registros antiguos', details: 'grupoId: $grupoId');
      
      await client
          .from('registro_v')
          .update({
            'vigente': false,
            'fecha_fin_r': DateTime.now().toIso8601String().split('T')[0],
          })
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true);
      
      logSuccess('Registros antiguos desactivados', details: 'grupoId: $grupoId');
      
      return success(null, message: 'Registros antiguos desactivados exitosamente');
      
    } catch (e) {
      logError('Desactivar registros antiguos', e);
      return handleError(e, customMessage: 'Error al desactivar registros antiguos');
    }
  }

  /// Eliminar registro_v
  Future<DatabaseResult<void>> eliminarRegistroV({
    required String registroId,
  }) async {
    try {
      if (!isValidId(registroId)) {
        return error('ID de registro_v inválido');
      }
      
      logProgress('Eliminando registro_v', details: 'ID: $registroId');
      
      await client
          .from('registro_v')
          .delete()
          .eq('id_registro', int.parse(registroId));
      
      logSuccess('Registro_v eliminado', details: 'ID: $registroId');
      
      return success(null, message: 'Registro_v eliminado exitosamente');
      
    } catch (e) {
      logError('Eliminar registro_v', e);
      return handleError(e, customMessage: 'Error al eliminar registro_v');
    }
  }

  /// Obtener estadísticas de registros_v
  Future<DatabaseResult<Map<String, dynamic>>> obtenerEstadisticasRegistrosV({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo estadísticas de registros_v', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('registro_v')
          .select('vigente, estado, material, tipo, pisos, fecha_ini_r, fecha_fin_r')
          .eq('id_grupof', int.parse(grupoId));
      
      final registros = (response as List).cast<Map<String, dynamic>>();
      
      // Calcular estadísticas
      final totalRegistros = registros.length;
      final registrosVigentes = registros.where((r) => r['vigente'] == true).length;
      final registrosInactivos = totalRegistros - registrosVigentes;
      
      final estados = <String, int>{};
      final materiales = <String, int>{};
      final tipos = <String, int>{};
      final pisos = <int, int>{};
      
      for (final registro in registros) {
        final estado = registro['estado'] as String? ?? 'No especificado';
        final material = registro['material'] as String? ?? 'No especificado';
        final tipo = registro['tipo'] as String? ?? 'No especificado';
        final piso = registro['pisos'] as int? ?? 0;
        
        estados[estado] = (estados[estado] ?? 0) + 1;
        materiales[material] = (materiales[material] ?? 0) + 1;
        tipos[tipo] = (tipos[tipo] ?? 0) + 1;
        pisos[piso] = (pisos[piso] ?? 0) + 1;
      }
      
      final estadisticas = {
        'total_registros': totalRegistros,
        'registros_vigentes': registrosVigentes,
        'registros_inactivos': registrosInactivos,
        'estados': estados,
        'materiales': materiales,
        'tipos': tipos,
        'pisos': pisos,
        'estado_mas_comun': estados.isNotEmpty 
            ? estados.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'material_mas_comun': materiales.isNotEmpty 
            ? materiales.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'tipo_mas_comun': tipos.isNotEmpty 
            ? tipos.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
        'piso_mas_comun': pisos.isNotEmpty 
            ? pisos.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : null,
      };
      
      logSuccess('Estadísticas de registros_v obtenidas', details: 'Total: $totalRegistros');
      
      return success(estadisticas);
      
    } catch (e) {
      logError('Obtener estadísticas de registros_v', e);
      return handleError(e, customMessage: 'Error al obtener estadísticas de registros_v');
    }
  }

  /// Verificar si existe un registro_v vigente
  Future<bool> existeRegistroVVigente(String grupoId) async {
    try {
      if (!isValidId(grupoId)) {
        return false;
      }
      
      final response = await client
          .from('registro_v')
          .select('id_registro')
          .eq('id_grupof', int.parse(grupoId))
          .eq('vigente', true)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      logError('Verificar existencia de registro_v vigente', e);
      return false;
    }
  }
}
