import 'base_database_service.dart';
import 'database_common.dart';
import '../../models/models.dart';

/// Servicio especializado para operaciones de integrantes
class IntegranteService extends BaseDatabaseService {

  /// Crear integrante
  Future<DatabaseResult<Integrante>> crearIntegrante({
    required String grupoId,
    required String rut,
    required DateTime fechaIniI,
    DateTime? fechaFinI,
    bool activoI = true,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Creando integrante', details: 'grupoId: $grupoId, rut: $rut');
      
      final integranteId = DateTime.now().millisecondsSinceEpoch;
      
      final integranteData = {
        'id_integrante': integranteId,
        'id_grupof': int.parse(grupoId),
        'rut': rut,
        'fecha_ini_i': fechaIniI.toIso8601String().split('T')[0],
        'fecha_fin_i': fechaFinI?.toIso8601String().split('T')[0],
        'activo_i': activoI,
      };
      
      logProgress('Insertando integrante', details: 'Datos: $integranteData');
      
      final response = await client
          .from('integrante')
          .insert(integranteData)
          .select()
          .single();
      
      final integrante = Integrante.fromJson(response);
      logSuccess('Integrante creado', details: 'ID: ${integrante.idIntegrante}');
      
      return success(integrante, message: 'Integrante creado exitosamente');
      
    } catch (e) {
      logError('Crear integrante', e);
      return handleError(e, customMessage: 'Error al crear integrante');
    }
  }

  /// Obtener integrantes de un grupo familiar
  Future<DatabaseResult<List<Integrante>>> obtenerIntegrantes({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo integrantes', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_grupof', int.parse(grupoId))
          .order('fecha_ini_i', ascending: false);
      
      final integrantes = (response as List)
          .map((json) => _crearIntegranteDesdeJoin(json))
          .where((integrante) => integrante != null)
          .cast<Integrante>()
          .toList();
      
      logSuccess('Integrantes obtenidos', details: 'Cantidad: ${integrantes.length}');
      
      return success(integrantes);
      
    } catch (e) {
      logError('Obtener integrantes', e);
      return handleError(e, customMessage: 'Error al obtener integrantes');
    }
  }

  /// Obtener integrante por ID
  Future<DatabaseResult<Integrante>> obtenerIntegrante({
    required String integranteId,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Obteniendo integrante', details: 'ID: $integranteId');
      
      final response = await client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_integrante', int.parse(integranteId))
          .maybeSingle();
      
      if (response == null) {
        return error('Integrante no encontrado con ID: $integranteId');
      }
      
      final integrante = _crearIntegranteDesdeJoin(response);
      if (integrante == null) {
        return error('Error al procesar datos del integrante');
      }
      
      logSuccess('Integrante obtenido', details: 'ID: ${integrante.idIntegrante}');
      
      return success(integrante);
      
    } catch (e) {
      logError('Obtener integrante', e);
      return handleError(e, customMessage: 'Error al obtener integrante');
    }
  }

  /// Actualizar integrante
  Future<DatabaseResult<Integrante>> actualizarIntegrante({
    required String integranteId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Actualizando integrante', details: 'ID: $integranteId, updates: $updates');
      
      final response = await client
          .from('integrante')
          .update(updates)
          .eq('id_integrante', int.parse(integranteId))
          .select()
          .single();
      
      final integrante = Integrante.fromJson(response);
      logSuccess('Integrante actualizado', details: 'ID: ${integrante.idIntegrante}');
      
      return success(integrante, message: 'Integrante actualizado exitosamente');
      
    } catch (e) {
      logError('Actualizar integrante', e);
      return handleError(e, customMessage: 'Error al actualizar integrante');
    }
  }

  /// Desactivar integrante
  Future<DatabaseResult<void>> desactivarIntegrante({
    required String integranteId,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Desactivando integrante', details: 'ID: $integranteId');
      
      await client
          .from('integrante')
          .update({
            'activo_i': false,
            'fecha_fin_i': DateTime.now().toIso8601String().split('T')[0],
          })
          .eq('id_integrante', int.parse(integranteId));
      
      logSuccess('Integrante desactivado', details: 'ID: $integranteId');
      
      return success(null, message: 'Integrante desactivado exitosamente');
      
    } catch (e) {
      logError('Desactivar integrante', e);
      return handleError(e, customMessage: 'Error al desactivar integrante');
    }
  }

  /// Eliminar integrante
  Future<DatabaseResult<void>> eliminarIntegrante({
    required String integranteId,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Eliminando integrante', details: 'ID: $integranteId');
      
      // Primero eliminar info_integrante si existe
      await client
          .from('info_integrante')
          .delete()
          .eq('id_integrante', int.parse(integranteId));
      
      // Luego eliminar el integrante
      await client
          .from('integrante')
          .delete()
          .eq('id_integrante', int.parse(integranteId));
      
      logSuccess('Integrante eliminado', details: 'ID: $integranteId');
      
      return success(null, message: 'Integrante eliminado exitosamente');
      
    } catch (e) {
      logError('Eliminar integrante', e);
      return handleError(e, customMessage: 'Error al eliminar integrante');
    }
  }

  /// Crear información de integrante
  Future<DatabaseResult<void>> crearInfoIntegrante({
    required String integranteId,
    required int anioNac,
    String? padecimiento,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Creando información de integrante', details: 'ID: $integranteId');
      
      final infoData = {
        'id_integrante': int.parse(integranteId),
        'anio_nac': anioNac,
        'padecimiento': padecimiento,
      };
      
      await client
          .from('info_integrante')
          .insert(infoData);
      
      logSuccess('Información de integrante creada', details: 'ID: $integranteId');
      
      return success(null, message: 'Información de integrante creada exitosamente');
      
    } catch (e) {
      logError('Crear información de integrante', e);
      return handleError(e, customMessage: 'Error al crear información de integrante');
    }
  }

  /// Actualizar información de integrante
  Future<DatabaseResult<void>> actualizarInfoIntegrante({
    required String integranteId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(integranteId)) {
        return error('ID de integrante inválido');
      }
      
      logProgress('Actualizando información de integrante', details: 'ID: $integranteId');
      
      await client
          .from('info_integrante')
          .update(updates)
          .eq('id_integrante', int.parse(integranteId));
      
      logSuccess('Información de integrante actualizada', details: 'ID: $integranteId');
      
      return success(null, message: 'Información de integrante actualizada exitosamente');
      
    } catch (e) {
      logError('Actualizar información de integrante', e);
      return handleError(e, customMessage: 'Error al actualizar información de integrante');
    }
  }

  /// Crear integrante desde join con info_integrante
  Integrante? _crearIntegranteDesdeJoin(Map<String, dynamic> json) {
    try {
      final infoIntegrante = json['info_integrante'] as Map<String, dynamic>?;
      
      return Integrante(
        idIntegrante: json['id_integrante'] as int,
        idGrupof: json['id_grupof'] as int,
        rut: json['rut'] as String? ?? '',
        fechaIniI: DateTime.parse(json['fecha_ini_i'] as String),
        fechaFinI: json['fecha_fin_i'] != null 
            ? DateTime.parse(json['fecha_fin_i'] as String)
            : null,
        activoI: json['activo_i'] as bool? ?? true,
        edad: infoIntegrante != null ? _calcularEdad(infoIntegrante['anio_nac'] as int?) : 0,
        anioNac: infoIntegrante?['anio_nac'] as int? ?? 0,
        padecimiento: infoIntegrante?['padecimiento'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      logError('Crear integrante desde join', e);
      return null;
    }
  }

  /// Calcular edad basada en año de nacimiento
  int _calcularEdad(int? anioNac) {
    if (anioNac == null) return 0;
    return DateTime.now().year - anioNac;
  }

  /// Obtener integrantes activos de un grupo familiar
  Future<DatabaseResult<List<Integrante>>> obtenerIntegrantesActivos({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo integrantes activos', details: 'grupoId: $grupoId');
      
      final response = await client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_grupof', int.parse(grupoId))
          .eq('activo_i', true)
          .order('fecha_ini_i', ascending: false);
      
      final integrantes = (response as List)
          .map((json) => _crearIntegranteDesdeJoin(json))
          .where((integrante) => integrante != null)
          .cast<Integrante>()
          .toList();
      
      logSuccess('Integrantes activos obtenidos', details: 'Cantidad: ${integrantes.length}');
      
      return success(integrantes);
      
    } catch (e) {
      logError('Obtener integrantes activos', e);
      return handleError(e, customMessage: 'Error al obtener integrantes activos');
    }
  }
}
