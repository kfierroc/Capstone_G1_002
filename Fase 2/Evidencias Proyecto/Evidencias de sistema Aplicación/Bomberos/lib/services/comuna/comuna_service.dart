import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../config/supabase_config.dart';
import '../../models/models.dart';
import '../service_result.dart';

/// Servicio para manejar operaciones CRUD de comunas
/// Incluye métodos para gestión completa de comunas
class ComunaService {
  static final ComunaService _instance = ComunaService._internal();
  factory ComunaService() => _instance;
  ComunaService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar una nueva comuna
  Future<ServiceResult<Comuna>> insertComuna(Comuna comuna) async {
    try {
      debugPrint('🔧 Insertando comuna con cutCom: ${comuna.cutCom}');
      
      // Validar datos de la comuna
      final validationResult = _validateComuna(comuna);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      // Verificar que la comuna no existe ya
      final comunaExiste = await _verificarComunaExiste(comuna.cutCom.toString());
      if (comunaExiste) {
        return ServiceResult.error('La comuna con código ${comuna.cutCom} ya existe');
      }
      
      final response = await _client
          .from('comuna')
          .insert(comuna.toInsertData())
          .select()
          .single();

      final nuevaComuna = Comuna.fromJson(response);
      debugPrint('✅ Comuna insertada exitosamente: ${nuevaComuna.cutCom}');
      return ServiceResult.success(data: nuevaComuna);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al insertar comuna: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al insertar comuna: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener todas las comunas
  Future<ServiceResult<List<Comuna>>> getAllComunas() async {
    try {
      debugPrint('🔧 Obteniendo todas las comunas');
      
      final response = await _client
          .from('comuna')
          .select('*')
          .order('nombreComuna', ascending: true);

      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();

      debugPrint('✅ Obtenidas ${comunas.length} comunas');
      return ServiceResult.success(data:comunas);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener comunas: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener comunas: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener comuna por nombre
  Future<ServiceResult<Comuna>> obtenerCutComPorNombre(String nombre) async {
    try {
      debugPrint('🔧 Obteniendo comuna por nombre: $nombre');
      
      final response = await _client
          .from('comuna')
          .select()
          .eq('nombre', nombre)
          .limit(1);
      
      if (response.isNotEmpty) {
        final comuna = Comuna.fromJson(response.first);
        debugPrint('✅ Comuna obtenida exitosamente: ${comuna.nombre}');
        return ServiceResult.success(data:comuna);
      } else {
        debugPrint('⚠️ Comuna no encontrada: $nombre');
        return ServiceResult.error('Comuna no encontrada');
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener comuna por nombre: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener comuna por nombre: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener comuna por código
  Future<ServiceResult<Comuna>> getComunaByCutCom(String cutCom) async {
    try {
      debugPrint('🔧 Obteniendo comuna con cutCom: $cutCom');
      
      final response = await _client
          .from('comuna')
          .select('*')
          .eq('cutCom', cutCom)
          .single();

      final comuna = Comuna.fromJson(response);
      debugPrint('✅ Comuna obtenida exitosamente: ${comuna.cutCom}');
      return ServiceResult.success(data:comuna);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener comuna: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener comuna: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Buscar comunas por nombre
  Future<ServiceResult<List<Comuna>>> searchComunasByName(String searchTerm) async {
    try {
      debugPrint('🔧 Buscando comunas con término: $searchTerm');
      
      final response = await _client
          .from('comuna')
          .select('*')
          .ilike('nombreComuna', '%$searchTerm%')
          .order('nombreComuna', ascending: true);

      final comunas = (response as List)
          .map((json) => Comuna.fromJson(json))
          .toList();

      debugPrint('✅ Encontradas ${comunas.length} comunas');
      return ServiceResult.success(data:comunas);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al buscar comunas: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al buscar comunas: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Actualizar comuna
  Future<ServiceResult<Comuna>> updateComuna(Comuna comuna) async {
    try {
      debugPrint('🔧 Actualizando comuna con cutCom: ${comuna.cutCom}');
      
      // Validar datos de la comuna
      final validationResult = _validateComuna(comuna);
      if (!validationResult.isSuccess) {
        return ServiceResult.error(validationResult.errorMessage ?? 'Error de validación');
      }
      
      final response = await _client
          .from('comuna')
          .update(comuna.toUpdateData())
          .eq('cutCom', comuna.cutCom)
          .select()
          .single();

      final comunaActualizada = Comuna.fromJson(response);
      debugPrint('✅ Comuna actualizada exitosamente: ${comunaActualizada.cutCom}');
      return ServiceResult.success(data:comunaActualizada);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al actualizar comuna: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar comuna: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Eliminar comuna
  Future<ServiceResult<bool>> deleteComuna(String cutCom) async {
    try {
      debugPrint('🔧 Eliminando comuna con cutCom: $cutCom');
      
      // Verificar que no hay grifos asociados a esta comuna
      final grifosAsociados = await _verificarGrifosAsociados(cutCom);
      if (grifosAsociados) {
        return ServiceResult.error('No se puede eliminar la comuna porque tiene grifos asociados');
      }
      
      await _client
          .from('comuna')
          .delete()
          .eq('cutCom', cutCom);

      debugPrint('✅ Comuna eliminada exitosamente: $cutCom');
      return ServiceResult.success(data:true);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al eliminar comuna: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar comuna: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Obtener estadísticas de comunas
  Future<ServiceResult<Map<String, dynamic>>> getComunaStatistics() async {
    try {
      debugPrint('🔧 Obteniendo estadísticas de comunas');
      
      // Obtener conteo total de comunas
      final totalResponse = await _client
          .from('comuna')
          .select('cutCom');
      
      final total = totalResponse.length;
      
      // Obtener conteo de grifos por comuna
      final grifosResponse = await _client
          .from('grifo')
          .select('cutCom')
          .not('cutCom', 'is', null);
      
      final Map<String, int> grifosPorComuna = {};
      for (final grifo in grifosResponse) {
        final cutCom = grifo['cutCom'] as String;
        grifosPorComuna[cutCom] = (grifosPorComuna[cutCom] ?? 0) + 1;
      }
      
      // Obtener comunas con más grifos
      final comunasConMasGrifos = grifosPorComuna.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(5);
      
      final statistics = {
        'totalComunas': total,
        'totalGrifos': grifosPorComuna.values.fold(0, (sum, count) => sum + count),
        'grifosPorComuna': grifosPorComuna,
        'comunasConMasGrifos': comunasConMasGrifos.map((e) => {
          'cutCom': e.key,
          'cantidadGrifos': e.value,
        }).toList(),
        'fechaActualizacion': DateTime.now().toIso8601String(),
      };
      
      debugPrint('✅ Estadísticas de comunas obtenidas exitosamente');
      return ServiceResult.success(data:statistics);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al obtener estadísticas de comunas: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener estadísticas de comunas: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  /// Insertar comunas básicas
  Future<ServiceResult<bool>> insertComunasBasicas() async {
    try {
      debugPrint('🔧 Insertando comunas básicas');
      
      // Verificar si ya existen comunas
      final response = await _client
          .from('comuna')
          .select('cutCom')
          .limit(1);
      
      if (response.isNotEmpty) {
        debugPrint('✅ Las comunas básicas ya existen');
        return ServiceResult.success(data:true);
      }
      
      // Lista de comunas básicas (ejemplo)
      final comunasBasicas = [
        {'cutCom': '13101', 'nombreComuna': 'Santiago'},
        {'cutCom': '13102', 'nombreComuna': 'Providencia'},
        {'cutCom': '13103', 'nombreComuna': 'Las Condes'},
        {'cutCom': '13104', 'nombreComuna': 'Vitacura'},
        {'cutCom': '13105', 'nombreComuna': 'Lo Barnechea'},
      ];
      
      await _client
          .from('comuna')
          .insert(comunasBasicas);
      
      debugPrint('✅ Comunas básicas insertadas exitosamente');
      return ServiceResult.success(data:true);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de PostgreSQL al insertar comunas básicas: ${e.message}');
      return ServiceResult.error('Error de base de datos: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al insertar comunas básicas: $e');
      return ServiceResult.error('Error inesperado: $e');
    }
  }

  // Métodos privados de validación y utilidad

  /// Validar datos de la comuna
  ServiceResult<bool> _validateComuna(Comuna comuna) {
    if (comuna.cutCom <= 0) {
      return ServiceResult.error('El código de comuna es obligatorio');
    }
    
    if (comuna.nombreComuna.isEmpty) {
      return ServiceResult.error('El nombre de la comuna es obligatorio');
    }
    
    // Validar formato del código de comuna (debe ser numérico)
    final cutComStr = comuna.cutCom.toString();
    if (!RegExp(r'^[0-9]+$').hasMatch(cutComStr)) {
      return ServiceResult.error('El código de comuna debe ser numérico');
    }
    
    // Validar longitud del código de comuna
    if (cutComStr.length != 5) {
      return ServiceResult.error('El código de comuna debe tener 5 dígitos');
    }
    
    return ServiceResult.success(data:true);
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

  /// Verificar si hay grifos asociados a una comuna
  Future<bool> _verificarGrifosAsociados(String cutCom) async {
    try {
      final response = await _client
          .from('grifo')
          .select('idGrifo')
          .eq('cutCom', cutCom)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error al verificar grifos asociados: $e');
      return false;
    }
  }
}