import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../../models/info_grifo.dart';
import '../service_result.dart';

/// Servicio para manejar operaciones de información de grifos
/// Aplicando Single Responsibility Principle
class InfoGrifoService {
  static final InfoGrifoService _instance = InfoGrifoService._internal();
  factory InfoGrifoService() => _instance;
  InfoGrifoService._internal();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar información de grifo
  Future<ServiceResult<InfoGrifo>> insertInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .insert(infoGrifo.toInsertData())
          .select()
          .single();

      final nuevaInfoGrifo = InfoGrifo.fromJson(response);
      return ServiceResult.success(data: nuevaInfoGrifo);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar información de grifo: ${e.toString()}');
    }
  }

  /// Obtener toda la información de grifos
  Future<ServiceResult<List<InfoGrifo>>> getAllInfoGrifos() async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('*')
          .order('fecha_registro', ascending: false);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información de grifos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información de grifos: ${e.toString()}');
    }
  }

  /// Obtener información de grifo por ID de grifo
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifoByGrifoId(int idGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('''
            *,
            bombero!inner(*)
          ''')
          .eq('id_grifo', idGrifo);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información de grifo: ${e.toString()}');
    }
  }

  /// Obtener información de grifo por RUT de bombero
  Future<ServiceResult<List<InfoGrifo>>> getInfoGrifoByBomberoRut(int rutNum) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('''
            *,
            grifo!inner(
              *,
              comunas!inner(*)
            ),
            bombero!inner(*)
          ''')
          .eq('rut_num', rutNum);

      final infoGrifos = (response as List)
          .map((json) => InfoGrifo.fromJson(json))
          .toList();

      return ServiceResult.success(data: infoGrifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información de grifo por bombero: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información de grifo por bombero: ${e.toString()}');
    }
  }

  /// Actualizar información de grifo
  Future<ServiceResult<InfoGrifo>> updateInfoGrifo(InfoGrifo infoGrifo) async {
    try {
      final response = await _client
          .from('info_grifo')
          .update(infoGrifo.toUpdateData())
          .eq('id_reg_grifo', infoGrifo.idRegGrifo)
          .select()
          .single();

      final infoGrifoActualizado = InfoGrifo.fromJson(response);
      return ServiceResult.success(data: infoGrifoActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar información de grifo: ${e.toString()}');
    }
  }

  /// Eliminar información de grifo
  Future<ServiceResult<void>> deleteInfoGrifo(int idRegGrifo) async {
    try {
      await _client
          .from('info_grifo')
          .delete()
          .eq('id_reg_grifo', idRegGrifo);

      return ServiceResult.success(data: null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar información de grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar información de grifo: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de inspecciones por bombero
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasInspecciones(int rutNum) async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('estado')
          .eq('rut_num', rutNum);

      final Map<String, int> estadisticas = {};
      
      for (final item in response as List) {
        final estado = item['estado'] as String;
        estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
      }

      return ServiceResult.success(data: {
        'total_inspecciones': estadisticas.values.fold(0, (sum, count) => sum + count),
        'por_estado': estadisticas,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas de inspecciones: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas de inspecciones: ${e.toString()}');
    }
  }

  /// Obtener información más reciente de cada grifo
  Future<ServiceResult<Map<int, InfoGrifo>>> getInfoGrifosMasRecientes() async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('*')
          .order('fecha_registro', ascending: false);

      final Map<int, InfoGrifo> infoMap = {};
      
      for (final item in response as List) {
        final info = InfoGrifo.fromJson(item);
        // Mantener solo la información más reciente de cada grifo
        if (!infoMap.containsKey(info.idGrifo) || 
            info.fechaRegistro.isAfter(infoMap[info.idGrifo]!.fechaRegistro)) {
          infoMap[info.idGrifo] = info;
        }
      }

      return ServiceResult.success(data: infoMap);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener información más reciente: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener información más reciente: ${e.toString()}');
    }
  }

  /// Obtener estadísticas generales de estados de grifos
  Future<ServiceResult<Map<String, int>>> getEstadisticasEstados() async {
    try {
      final response = await _client
          .from('info_grifo')
          .select('estado');

      final Map<String, int> estadisticas = {
        'operativo': 0,
        'dañado': 0,
        'mantenimiento': 0,
        'sin_verificar': 0,
      };
      
      for (final item in response as List) {
        final estado = item['estado'] as String;
        final estadoKey = estado.toLowerCase().replaceAll(' ', '_');
        if (estadisticas.containsKey(estadoKey)) {
          estadisticas[estadoKey] = (estadisticas[estadoKey] ?? 0) + 1;
        }
      }

      return ServiceResult.success(data: estadisticas);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas de estados: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas de estados: ${e.toString()}');
    }
  }
}
