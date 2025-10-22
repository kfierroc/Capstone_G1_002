import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../config/supabase_config.dart';
import '../../models/models.dart';
import '../service_result.dart';

/// Servicio refactorizado para manejar operaciones CRUD de información de grifos
/// Versión mejorada con mejor manejo de errores y estructura más limpia
class InfoGrifoServiceRefactored {
  static final InfoGrifoServiceRefactored _instance = InfoGrifoServiceRefactored._internal();
  factory InfoGrifoServiceRefactored() => _instance;
  InfoGrifoServiceRefactored._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar nueva información de grifo
  Future<ServiceResult<InfoGrifo>> insertInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      debugPrint('🔧 [Refactored] Insertando información de grifo para grifo ID: ${infoGrifo.grifoIdGrifo}');
      
      // Validar datos de la información del grifo
      final validationResult = _validateInfoGrifo(infoGrifo);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      // Verificar que el grifo existe
      final grifoExiste = await _verificarGrifoExiste(infoGrifo.grifoIdGrifo);
      if (!grifoExiste) {
        return ServiceResult.error('El grifo con ID ${infoGrifo.grifoIdGrifo} no existe');
      }
      
      final response = await _client
          .from('infoGrifo')
          .insert(infoGrifo.toInsertData())
          .select()
          .single();

      final nuevaInfoGrifo = InfoGrifo.fromJson(response);
      debugPrint('✅ Información de grifo insertada exitosamente: ${nuevaInfoGrifo.idInfoGrifo}');
        return ServiceResult.success(data: nuevaInfoGrifo);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al insertar información de grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al insertar información de grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener toda la información de grifos
  Future<ServiceResult<List<InfoGrifo>>> getAllInfoGrifos() async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo toda la información de grifos');
      
      final response = await _client
          .from('infoGrifo')
          .select('''
            *,
            grifo:grifo_idGrifo(*)
          ''')
          .order('idInfoGrifo', ascending: true);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      debugPrint('✅ Obtenida información de ${infoGrifos.length} grifos');
        return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener información de grifos: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener información de grifos: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener información de grifo por ID
  Future<ServiceResult<InfoGrifo>> getInfoGrifoById(int id) async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo información de grifo con ID: $id');
      
      final response = await _client
          .from('infoGrifo')
          .select('''
            *,
            grifo:grifo_idGrifo(*)
          ''')
          .eq('idInfoGrifo', id)
          .single();

      final infoGrifo = InfoGrifo.fromJson(response);
      debugPrint('✅ Información de grifo obtenida exitosamente: ${infoGrifo.idInfoGrifo}');
      return ServiceResult.success(data: infoGrifo);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener información de grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener información de grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener información de grifo por ID del grifo
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifoByGrifoId(int grifoId) async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo información de grifo para grifo ID: $grifoId');
      
      final response = await _client
          .from('infoGrifo')
          .select('''
            *,
            grifo:grifo_idGrifo(*)
          ''')
          .eq('grifo_idGrifo', grifoId)
          .order('fechaInspeccion', ascending: false);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      debugPrint('✅ Obtenida información de ${infoGrifos.length} inspecciones para grifo $grifoId');
        return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener información de grifo por ID: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener información de grifo por ID: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Actualizar información de grifo
  Future<ServiceResult<InfoGrifo>> updateInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      debugPrint('🔧 [Refactored] Actualizando información de grifo con ID: ${infoGrifo.idInfoGrifo}');
      
      // Validar datos de la información del grifo
      final validationResult = _validateInfoGrifo(infoGrifo);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      final response = await _client
          .from('infoGrifo')
          .update(infoGrifo.toUpdateData())
          .eq('idInfoGrifo', infoGrifo.idInfoGrifo)
          .select()
          .single();

      final infoGrifoActualizado = InfoGrifo.fromJson(response);
      debugPrint('✅ Información de grifo actualizada exitosamente: ${infoGrifoActualizado.idInfoGrifo}');
      return ServiceResult.success(data: infoGrifoActualizado);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al actualizar información de grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar información de grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Eliminar información de grifo
  Future<ServiceResult<bool>> deleteInfoGrifo(int id) async {
    try {
      debugPrint('🔧 [Refactored] Eliminando información de grifo con ID: $id');
      
      await _client
          .from('infoGrifo')
          .delete()
          .eq('idInfoGrifo', id);

      debugPrint('✅ Información de grifo eliminada exitosamente: $id');
        return ServiceResult.success(data: true);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al eliminar información de grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar información de grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener información de grifos por rango de fechas
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifosByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo información de grifos entre ${startDate.toIso8601String()} y ${endDate.toIso8601String()}');
      
      final response = await _client
          .from('infoGrifo')
          .select('''
            *,
            grifo:grifo_idGrifo(*)
          ''')
          .gte('fechaInspeccion', startDate.toIso8601String())
          .lte('fechaInspeccion', endDate.toIso8601String())
          .order('fechaInspeccion', ascending: false);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      debugPrint('✅ Obtenida información de ${infoGrifos.length} grifos en el rango de fechas');
        return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener información de grifos por fecha: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener información de grifos por fecha: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener estadísticas de información de grifos
  Future<ServiceResult<Map<String, dynamic>>> getInfoGrifoStatistics() async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo estadísticas de información de grifos');
      
      // Obtener conteo total de inspecciones
      final totalResponse = await _client
          .from('infoGrifo')
          .select('idInfoGrifo');
      
      final total = totalResponse.length;
      
      // Obtener conteo por estado de funcionamiento
      final estadosResponse = await _client
          .from('infoGrifo')
          .select('estadoFuncionamiento')
          .not('estadoFuncionamiento', 'is', null);
      
      final Map<String, int> estadosCount = {};
      for (final estado in estadosResponse) {
        final estadoStr = estado['estadoFuncionamiento'] as String;
        estadosCount[estadoStr] = (estadosCount[estadoStr] ?? 0) + 1;
      }
      
      // Obtener conteo por tipo de grifo
      final tiposResponse = await _client
          .from('infoGrifo')
          .select('tipoGrifo')
          .not('tipoGrifo', 'is', null);
      
      final Map<String, int> tiposCount = {};
      for (final tipo in tiposResponse) {
        final tipoStr = tipo['tipoGrifo'] as String;
        tiposCount[tipoStr] = (tiposCount[tipoStr] ?? 0) + 1;
      }
      
      // Obtener fecha de la última inspección
      final ultimaInspeccionResponse = await _client
          .from('infoGrifo')
          .select('fechaInspeccion')
          .order('fechaInspeccion', ascending: false)
          .limit(1);
      
      String? ultimaInspeccion;
      if (ultimaInspeccionResponse.isNotEmpty) {
        ultimaInspeccion = ultimaInspeccionResponse.first['fechaInspeccion'] as String?;
      }
      
      final statistics = {
        'totalInspecciones': total,
        'porEstadoFuncionamiento': estadosCount,
        'porTipoGrifo': tiposCount,
        'ultimaInspeccion': ultimaInspeccion,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ Estadísticas de información de grifos obtenidas exitosamente');
      return ServiceResult.success(data: statistics);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener estadísticas de información: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener estadísticas de información: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  // Métodos privados de validación y utilidad

  /// Validar datos de la información del grifo
  ServiceResult<bool> _validateInfoGrifo(InfoGrifo infoGrifo) {
    if (infoGrifo.grifoIdGrifo <= 0) {
      return ServiceResult.error('El ID del grifo es obligatorio');
    }
    
    if (infoGrifo.estadoFuncionamiento.isEmpty) {
      return ServiceResult.error('El estado de funcionamiento es obligatorio');
    }
    
    if (infoGrifo.tipoGrifo.isEmpty) {
      return ServiceResult.error('El tipo de grifo es obligatorio');
    }
    
    // Validar que la fecha de inspección no sea futura
    if (infoGrifo.fechaInspeccion.isAfter(DateTime.now())) {
      return ServiceResult.error('La fecha de inspección no puede ser futura');
    }
    
        return ServiceResult.success(data: true);
  }

  /// Verificar si un grifo existe
  Future<bool> _verificarGrifoExiste(int grifoId) async {
    try {
      final response = await _client
          .from('grifo')
          .select('idGrifo')
          .eq('idGrifo', grifoId)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error al verificar grifo: $e');
      return false;
    }
  }
}
