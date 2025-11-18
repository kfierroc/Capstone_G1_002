import 'base_database_service.dart';
import 'database_common.dart';
import '../../models/models.dart';

/// Servicio especializado para operaciones de grupos familiares
class GrupoFamiliarService extends BaseDatabaseService {
  
  /// Crear grupo familiar
  Future<DatabaseResult<GrupoFamiliar>> crearGrupoFamiliar({
    required String userId,
    required RegistrationData data,
  }) async {
    try {
      logProgress('Creando grupo familiar', details: 'userId: $userId');
      
      // Validar datos requeridos
      if (data.rut == null || data.rut!.isEmpty) {
        return error('El RUT es requerido');
      }
      
      if (data.email == null || !isValidEmail(data.email)) {
        return error('El email es requerido y debe ser válido');
      }
      
      // Generar ID único para el grupo familiar
      final grupoId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final grupoData = {
        'id_grupof': grupoId,
        'rut_titular': data.rut!,
        'nomb_titular': data.fullName ?? '',
        'ape_p_titular': data.fullName?.split(' ').last ?? '',
        'telefono_titular': data.phoneNumber ?? data.mainPhone ?? '',
        'email': data.email!,
        'fecha_creacion': DateTime.now().toIso8601String().split('T')[0],
      };
      
      logProgress('Insertando grupo familiar', details: 'ID: $grupoId');
      
      final response = await client
          .from('grupofamiliar')
          .insert(grupoData)
          .select()
          .single();
      
      final grupo = GrupoFamiliar.fromJson(response);
      logSuccess('Grupo familiar creado', details: 'ID: ${grupo.idGrupof}');
      
      return success(grupo, message: 'Grupo familiar creado exitosamente');
      
    } catch (e) {
      logError('Crear grupo familiar', e);
      return handleError(e, customMessage: 'Error al crear grupo familiar');
    }
  }

  /// Obtener grupo familiar por email
  Future<DatabaseResult<GrupoFamiliar>> obtenerGrupoFamiliar({
    required String email,
  }) async {
    try {
      logProgress('Obteniendo grupo familiar', details: 'email: $email');
      
      final response = await client
          .from('grupofamiliar')
          .select()
          .eq('email', email.trim())
          .maybeSingle();
      
      if (response == null) {
        return error('Grupo familiar no encontrado para el email: $email');
      }
      
      final grupo = GrupoFamiliar.fromJson(response);
      logSuccess('Grupo familiar obtenido', details: 'ID: ${grupo.idGrupof}');
      
      return success(grupo);
      
    } catch (e) {
      logError('Obtener grupo familiar', e);
      return handleError(e, customMessage: 'Error al obtener grupo familiar');
    }
  }

  /// Obtener grupo familiar por ID
  Future<DatabaseResult<GrupoFamiliar>> obtenerGrupoFamiliarPorId({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Obteniendo grupo familiar por ID', details: 'ID: $grupoId');
      
      final response = await client
          .from('grupofamiliar')
          .select()
          .eq('id_grupof', int.parse(grupoId))
          .maybeSingle();
      
      if (response == null) {
        return error('Grupo familiar no encontrado con ID: $grupoId');
      }
      
      final grupo = GrupoFamiliar.fromJson(response);
      logSuccess('Grupo familiar obtenido por ID', details: 'ID: ${grupo.idGrupof}');
      
      return success(grupo);
      
    } catch (e) {
      logError('Obtener grupo familiar por ID', e);
      return handleError(e, customMessage: 'Error al obtener grupo familiar por ID');
    }
  }

  /// Actualizar grupo familiar
  Future<DatabaseResult<GrupoFamiliar>> actualizarGrupoFamiliar({
    required String grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Actualizando grupo familiar', details: 'ID: $grupoId, updates: $updates');
      
      // Validar email si está en los updates
      if (updates.containsKey('email') && !isValidEmail(updates['email'])) {
        return error('El email proporcionado no es válido');
      }
      
      final response = await client
          .from('grupofamiliar')
          .update(updates)
          .eq('id_grupof', int.parse(grupoId))
          .select()
          .single();
      
      final grupo = GrupoFamiliar.fromJson(response);
      logSuccess('Grupo familiar actualizado', details: 'ID: ${grupo.idGrupof}');
      
      return success(grupo, message: 'Grupo familiar actualizado exitosamente');
      
    } catch (e) {
      logError('Actualizar grupo familiar', e);
      return handleError(e, customMessage: 'Error al actualizar grupo familiar');
    }
  }

  /// Actualizar teléfono principal
  Future<DatabaseResult<void>> actualizarTelefonoPrincipal({
    required String grupoId,
    required String telefono,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Actualizando teléfono principal', details: 'ID: $grupoId, teléfono: $telefono');
      
      await client
          .from('grupofamiliar')
          .update({'telefono_titular': telefono})
          .eq('id_grupof', int.parse(grupoId));
      
      logSuccess('Teléfono principal actualizado', details: 'ID: $grupoId');
      
      return success(null, message: 'Teléfono principal actualizado exitosamente');
      
    } catch (e) {
      logError('Actualizar teléfono principal', e);
      return handleError(e, customMessage: 'Error al actualizar teléfono principal');
    }
  }

  /// Verificar si existe un grupo familiar por email
  Future<bool> existeGrupoFamiliar(String email) async {
    try {
      final response = await client
          .from('grupofamiliar')
          .select('id_grupof')
          .eq('email', email.trim())
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      logError('Verificar existencia de grupo familiar', e);
      return false;
    }
  }

  /// Eliminar grupo familiar
  Future<DatabaseResult<void>> eliminarGrupoFamiliar({
    required String grupoId,
  }) async {
    try {
      if (!isValidId(grupoId)) {
        return error('ID de grupo familiar inválido');
      }
      
      logProgress('Eliminando grupo familiar', details: 'ID: $grupoId');
      
      await client
          .from('grupofamiliar')
          .delete()
          .eq('id_grupof', int.parse(grupoId));
      
      logSuccess('Grupo familiar eliminado', details: 'ID: $grupoId');
      
      return success(null, message: 'Grupo familiar eliminado exitosamente');
      
    } catch (e) {
      logError('Eliminar grupo familiar', e);
      return handleError(e, customMessage: 'Error al eliminar grupo familiar');
    }
  }

  /// Obtener todos los grupos familiares (para administración)
  Future<DatabaseResult<List<GrupoFamiliar>>> obtenerTodosLosGruposFamiliares() async {
    try {
      logProgress('Obteniendo todos los grupos familiares');
      
      final response = await client
          .from('grupofamiliar')
          .select()
          .order('fecha_creacion', ascending: false);
      
      final grupos = (response as List)
          .map((json) => GrupoFamiliar.fromJson(json))
          .toList();
      
      logSuccess('Grupos familiares obtenidos', details: 'Cantidad: ${grupos.length}');
      
      return success(grupos);
      
    } catch (e) {
      logError('Obtener todos los grupos familiares', e);
      return handleError(e, customMessage: 'Error al obtener grupos familiares');
    }
  }
}
