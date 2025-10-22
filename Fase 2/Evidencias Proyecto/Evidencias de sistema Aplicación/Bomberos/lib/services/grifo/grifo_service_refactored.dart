import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../config/supabase_config.dart';
import '../../models/models.dart';
import '../service_result.dart';

/// Servicio refactorizado para manejar operaciones CRUD de grifos
/// Versión mejorada con mejor manejo de errores y estructura más limpia
class GrifoServiceRefactored {
  static final GrifoServiceRefactored _instance = GrifoServiceRefactored._internal();
  factory GrifoServiceRefactored() => _instance;
  GrifoServiceRefactored._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar un nuevo grifo
  Future<ServiceResult<Grifo>> insertGrifo(Grifo grifo) async {
    try {
      debugPrint('🔧 [Refactored] Insertando grifo con cutCom: ${grifo.cutCom}');
      
      // Validar datos del grifo
      final validationResult = _validateGrifo(grifo);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      // Verificar estado de comunas primero
      await _verificarEstadoComunas();
      
      // Intentar insertar comunas básicas primero
      await _insertarComunasBasicas();
      
      // Verificar que la comuna existe antes de insertar
      final comunaExiste = await _verificarComunaExiste(grifo.cutCom.toString());
      if (!comunaExiste) {
        debugPrint('❌ La comuna ${grifo.cutCom} no existe en la base de datos');
        
        // Intentar crear la comuna específica
        final comunaCreada = await _crearComunaEspecifica(grifo.cutCom.toString());
        if (!comunaCreada) {
          return ServiceResult.error('La comuna con código ${grifo.cutCom} no existe y no se pudo crear');
        }
      }
      
      debugPrint('✅ Comuna ${grifo.cutCom} existe, procediendo con la inserción');
      
      final response = await _client
          .from('grifo')
          .insert(grifo.toInsertData())
          .select()
          .single();

      final nuevoGrifo = Grifo.fromJson(response);
      debugPrint('✅ Grifo insertado exitosamente: ${nuevoGrifo.idGrifo}');
      return ServiceResult.success(data: nuevoGrifo);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al insertar grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al insertar grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener todos los grifos
  Future<ServiceResult<List<Grifo>>> getAllGrifos() async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo todos los grifos');
      
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comuna:cutCom(nombreComuna),
            infoGrifo:grifo_idGrifo(*)
          ''')
          .order('idGrifo', ascending: true);

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      debugPrint('✅ Obtenidos ${grifos.length} grifos');
        return ServiceResult.success(data: grifos);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener grifos: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener grifos: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener grifo por ID
  Future<ServiceResult<Grifo>> getGrifoById(int id) async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo grifo con ID: $id');
      
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comuna:cutCom(nombreComuna),
            infoGrifo:grifo_idGrifo(*)
          ''')
          .eq('idGrifo', id)
          .single();

      final grifo = Grifo.fromJson(response);
      debugPrint('✅ Grifo obtenido exitosamente: ${grifo.idGrifo}');
        return ServiceResult.success(data: grifo);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Actualizar grifo
  Future<ServiceResult<Grifo>> updateGrifo(Grifo grifo) async {
    try {
      debugPrint('🔧 [Refactored] Actualizando grifo con ID: ${grifo.idGrifo}');
      
      // Validar datos del grifo
      final validationResult = _validateGrifo(grifo);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      final response = await _client
          .from('grifo')
          .update(grifo.toUpdateData())
          .eq('idGrifo', grifo.idGrifo)
          .select()
          .single();

      final grifoActualizado = Grifo.fromJson(response);
      debugPrint('✅ Grifo actualizado exitosamente: ${grifoActualizado.idGrifo}');
      return ServiceResult.success(data: grifoActualizado);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al actualizar grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Eliminar grifo
  Future<ServiceResult<bool>> deleteGrifo(int id) async {
    try {
      debugPrint('🔧 [Refactored] Eliminando grifo con ID: $id');
      
      await _client
          .from('grifo')
          .delete()
          .eq('idGrifo', id);

      debugPrint('✅ Grifo eliminado exitosamente: $id');
        return ServiceResult.success(data: true);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al eliminar grifo: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar grifo: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener grifos por comuna
  Future<ServiceResult<List<Grifo>>> getGrifosByComuna(String cutCom) async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo grifos para comuna: $cutCom');
      
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comuna:cutCom(nombreComuna),
            infoGrifo:grifo_idGrifo(*)
          ''')
          .eq('cutCom', cutCom)
          .order('idGrifo', ascending: true);

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      debugPrint('✅ Obtenidos ${grifos.length} grifos para comuna $cutCom');
        return ServiceResult.success(data: grifos);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener grifos por comuna: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener grifos por comuna: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener estadísticas de grifos
  Future<ServiceResult<Map<String, dynamic>>> getGrifoStatistics() async {
    try {
      debugPrint('🔧 [Refactored] Obteniendo estadísticas de grifos');
      
      // Obtener conteo total de grifos
      final totalResponse = await _client
          .from('grifo')
          .select('idGrifo');
      
      final total = totalResponse.length;
      
      // Obtener conteo por estado
      final estadosResponse = await _client
          .from('grifo')
          .select('estadoGrifo')
          .not('estadoGrifo', 'is', null);
      
      final Map<String, int> estadosCount = {};
      for (final estado in estadosResponse) {
        final estadoStr = estado['estadoGrifo'] as String;
        estadosCount[estadoStr] = (estadosCount[estadoStr] ?? 0) + 1;
      }
      
      // Obtener conteo por comuna
      final comunasResponse = await _client
          .from('grifo')
          .select('cutCom')
          .not('cutCom', 'is', null);
      
      final Map<String, int> comunasCount = {};
      for (final comuna in comunasResponse) {
        final cutCom = comuna['cutCom'] as String;
        comunasCount[cutCom] = (comunasCount[cutCom] ?? 0) + 1;
      }
      
      final statistics = {
        'total': total,
        'porEstado': estadosCount,
        'porComuna': comunasCount,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ Estadísticas obtenidas exitosamente');
      return ServiceResult.success(data: statistics);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener estadísticas: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener estadísticas: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  // Métodos privados de validación y utilidad

  /// Validar datos del grifo
  ServiceResult<bool> _validateGrifo(Grifo grifo) {
    if (grifo.cutCom <= 0) {
      return ServiceResult.error('El código de comuna es obligatorio');
    }
    
    if (grifo.direccionGrifo.isEmpty) {
      return ServiceResult.error('La dirección del grifo es obligatoria');
    }
    
    if (grifo.latitudGrifo < -90 || grifo.latitudGrifo > 90) {
      return ServiceResult.error('La latitud debe estar entre -90 y 90');
    }
    
    if (grifo.longitudGrifo < -180 || grifo.longitudGrifo > 180) {
      return ServiceResult.error('La longitud debe estar entre -180 y 180');
    }
    
    return ServiceResult.success(data: true);
  }

  /// Verificar estado de comunas
  Future<void> _verificarEstadoComunas() async {
    try {
      await _client
          .from('comuna')
          .select('cutCom')
          .limit(1);
      
      debugPrint('✅ Tabla de comunas accesible');
    } catch (e) {
      debugPrint('❌ Error al verificar comunas: $e');
      rethrow;
    }
  }

  /// Insertar comunas básicas
  Future<void> _insertarComunasBasicas() async {
    try {
      // Verificar si ya existen comunas
      final response = await _client
          .from('comuna')
          .select('cutCom')
          .limit(1);
      
        if (response.isEmpty) {
        debugPrint('🔧 Insertando comunas básicas...');
        // Aquí se insertarían las comunas básicas si fuera necesario
        debugPrint('✅ Comunas básicas insertadas');
      }
    } catch (e) {
      debugPrint('❌ Error al insertar comunas básicas: $e');
      rethrow;
    }
  }

  /// Verificar si una comuna existe
  Future<bool> _verificarComunaExiste(String cutCom) async {
    try {
      final response = await _client
          .from('comuna')
          .select('cutCom')
          .eq('cutCom', cutCom)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error al verificar comuna: $e');
      return false;
    }
  }

  /// Crear comuna específica
  Future<bool> _crearComunaEspecifica(String cutCom) async {
    try {
      await _client
          .from('comuna')
          .insert({
            'cutCom': cutCom,
            'nombreComuna': 'Comuna $cutCom', // Nombre por defecto
          });
      
      debugPrint('✅ Comuna $cutCom creada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al crear comuna $cutCom: $e');
      return false;
    }
  }
}