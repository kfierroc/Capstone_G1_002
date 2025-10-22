import 'package:flutter/foundation.dart';
import '../../models/info_grifo.dart';
import '../service_result.dart';
import '../grifo/grifo_service_refactored.dart';
import '../info_grifo/info_grifo_service_refactored.dart';
import '../comuna/comuna_service.dart';

/// Servicio para manejar estadísticas del sistema
/// Aplicando Single Responsibility Principle
class EstadisticasService {
  static final EstadisticasService _instance = EstadisticasService._internal();
  factory EstadisticasService() => _instance;
  EstadisticasService._internal();

  final GrifoServiceRefactored _grifoService = GrifoServiceRefactored();
  final InfoGrifoServiceRefactored _infoGrifoService = InfoGrifoServiceRefactored();
  final ComunaService _comunaService = ComunaService();

  /// Obtener estadísticas generales del sistema
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasGenerales() async {
    try {
      debugPrint('📊 Obteniendo estadísticas generales...');
      
      // Obtener estadísticas de grifos
      final grifosResult = await _grifoService.getGrifoStatistics();
      if (!grifosResult.isSuccess) {
        return ServiceResult.error('Error al obtener grifos: ${grifosResult.error}');
      }

      // Obtener estadísticas de información de grifos
      final infoGrifosResult = await _infoGrifoService.getAllInfoGrifos();
      if (!infoGrifosResult.isSuccess) {
        return ServiceResult.error('Error al obtener información de grifos: ${infoGrifosResult.error}');
      }

      // Obtener estadísticas de comunas
      final comunasResult = await _comunaService.getComunaStatistics();
      if (!comunasResult.isSuccess) {
        return ServiceResult.error('Error al obtener estadísticas de comunas: ${comunasResult.error}');
      }

      // Calcular estadísticas de estados
      final estadosStats = _calcularEstadisticasEstados(infoGrifosResult.data!);
      
      // Usar estadísticas de comunas del servicio de grifos
      final comunasStats = grifosResult.data!['por_comuna'] as Map<String, int>? ?? {};

      final estadisticas = {
        'total_grifos': grifosResult.data!['total_grifos'],
        'total_inspecciones': infoGrifosResult.data!.length,
        'total_comunas': comunasResult.data!['total_comunas'],
        'estados_grifos': estadosStats,
        'grifos_por_comuna': comunasStats,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ Estadísticas generales obtenidas exitosamente');
      return ServiceResult.success(data: estadisticas);
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas generales: $e');
      return ServiceResult.error('Error inesperado al obtener estadísticas: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de un bombero específico
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasBombero(int rutNum) async {
    try {
      debugPrint('📊 Obteniendo estadísticas del bombero: $rutNum');
      
      // Obtener inspecciones del bombero
      final inspeccionesResult = await _infoGrifoService.getInfoGrifoStatistics();
      if (!inspeccionesResult.isSuccess) {
        return ServiceResult.error('Error al obtener inspecciones: ${inspeccionesResult.error}');
      }

      // Obtener información detallada de grifos inspeccionados
      final infoGrifosResult = await _infoGrifoService.getAllInfoGrifos();
      if (!infoGrifosResult.isSuccess) {
        return ServiceResult.error('Error al obtener información de grifos: ${infoGrifosResult.error}');
      }

      // Calcular estadísticas adicionales
      final estadisticas = {
        'rut_num': rutNum,
        'total_inspecciones': inspeccionesResult.data!['total_inspecciones'],
        'inspecciones_por_estado': inspeccionesResult.data!['por_estado'],
        'grifos_inspeccionados': infoGrifosResult.data!.length,
        'fecha_ultima_inspeccion': _obtenerFechaUltimaInspeccion(infoGrifosResult.data!),
        'comunas_atendidas': _obtenerComunasAtendidas(infoGrifosResult.data!),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ Estadísticas del bombero obtenidas exitosamente');
      return ServiceResult.success(data: estadisticas);
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas del bombero: $e');
      return ServiceResult.error('Error inesperado al obtener estadísticas del bombero: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de una comuna específica
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasComuna(int cutCom) async {
    try {
      debugPrint('📊 Obteniendo estadísticas de la comuna: $cutCom');
      
      // Obtener grifos de la comuna
      final grifosResult = await _grifoService.getGrifosByComuna(cutCom.toString());
      if (!grifosResult.isSuccess) {
        return ServiceResult.error('Error al obtener grifos de la comuna: ${grifosResult.error}');
      }

      // Obtener nombre de la comuna
      final nombreComunaResult = await _comunaService.obtenerCutComPorNombre(cutCom.toString());
      if (!nombreComunaResult.isSuccess) {
        return ServiceResult.error('Error al obtener nombre de la comuna: ${nombreComunaResult.error}');
      }

      // Obtener información de grifos
      final infoGrifosResult = await _infoGrifoService.getAllInfoGrifos();
      if (!infoGrifosResult.isSuccess) {
        return ServiceResult.error('Error al obtener información de grifos: ${infoGrifosResult.error}');
      }

      // Filtrar información de grifos de esta comuna
      final infoGrifosComuna = infoGrifosResult.data!.where((info) {
        return grifosResult.data!.any((grifo) => grifo.idGrifo == info.idGrifo);
      }).toList();

      // Calcular estadísticas
      final estadosStats = _calcularEstadisticasEstados(infoGrifosComuna);
      
      final estadisticas = {
        'cut_com': cutCom,
        'nombre_comuna': nombreComunaResult.data!,
        'total_grifos': grifosResult.data!.length,
        'total_inspecciones': infoGrifosComuna.length,
        'estados_grifos': estadosStats,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ Estadísticas de la comuna obtenidas exitosamente');
      return ServiceResult.success(data: estadisticas);
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas de la comuna: $e');
      return ServiceResult.error('Error inesperado al obtener estadísticas de la comuna: ${e.toString()}');
    }
  }

  /// Calcular estadísticas de estados de grifos
  Map<String, int> _calcularEstadisticasEstados(List<InfoGrifo> infoGrifos) {
    final Map<String, int> estadisticas = {
      'operativo': 0,
      'dañado': 0,
      'mantenimiento': 0,
      'sin_verificar': 0,
    };

    for (final info in infoGrifos) {
      switch (info.estado.toLowerCase()) {
        case 'operativo':
          estadisticas['operativo'] = (estadisticas['operativo'] ?? 0) + 1;
          break;
        case 'dañado':
          estadisticas['dañado'] = (estadisticas['dañado'] ?? 0) + 1;
          break;
        case 'mantenimiento':
          estadisticas['mantenimiento'] = (estadisticas['mantenimiento'] ?? 0) + 1;
          break;
        case 'sin verificar':
          estadisticas['sin_verificar'] = (estadisticas['sin_verificar'] ?? 0) + 1;
          break;
      }
    }

    return estadisticas;
  }


  /// Obtener fecha de la última inspección
  String? _obtenerFechaUltimaInspeccion(List<InfoGrifo> infoGrifos) {
    if (infoGrifos.isEmpty) return null;
    
    final ultimaInspeccion = infoGrifos.reduce((a, b) => 
        a.fechaRegistro.isAfter(b.fechaRegistro) ? a : b);
    
    return ultimaInspeccion.fechaRegistro.toIso8601String();
  }

  /// Obtener comunas atendidas por un bombero
  List<String> _obtenerComunasAtendidas(List<InfoGrifo> infoGrifos) {
    final comunas = <String>{};
    
    for (final info in infoGrifos) {
      // Aquí podrías obtener el nombre de la comuna si tienes acceso a la información del grifo
      comunas.add('Comuna ${info.idGrifo}'); // Placeholder
    }

    return comunas.toList();
  }

  /// Obtener resumen ejecutivo del sistema
  Future<ServiceResult<Map<String, dynamic>>> getResumenEjecutivo() async {
    try {
      debugPrint('📊 Generando resumen ejecutivo...');
      
      final estadisticasResult = await getEstadisticasGenerales();
      if (!estadisticasResult.isSuccess) {
        return ServiceResult.error('Error al obtener estadísticas: ${estadisticasResult.error}');
      }

      final estadisticas = estadisticasResult.data!;
      
      // Calcular métricas clave
      final totalGrifos = estadisticas['total_grifos'] as int;
      final estadosStats = estadisticas['estados_grifos'] as Map<String, int>;
      
      final grifosOperativos = estadosStats['operativo'] ?? 0;
      final grifosDanados = estadosStats['dañado'] ?? 0;
      final grifosMantenimiento = estadosStats['mantenimiento'] ?? 0;
      final grifosSinVerificar = estadosStats['sin_verificar'] ?? 0;
      
      final porcentajeOperativos = totalGrifos > 0 ? (grifosOperativos / totalGrifos * 100).round() : 0;
      final porcentajeDanados = totalGrifos > 0 ? (grifosDanados / totalGrifos * 100).round() : 0;

      final resumen = {
        'total_grifos': totalGrifos,
        'grifos_operativos': grifosOperativos,
        'grifos_danados': grifosDanados,
        'grifos_mantenimiento': grifosMantenimiento,
        'grifos_sin_verificar': grifosSinVerificar,
        'porcentaje_operativos': porcentajeOperativos,
        'porcentaje_danados': porcentajeDanados,
        'estado_general': _determinarEstadoGeneral(porcentajeOperativos, porcentajeDanados),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ Resumen ejecutivo generado exitosamente');
      return ServiceResult.success(data: resumen);
    } catch (e) {
      debugPrint('❌ Error al generar resumen ejecutivo: $e');
      return ServiceResult.error('Error inesperado al generar resumen ejecutivo: ${e.toString()}');
    }
  }

  /// Determinar el estado general del sistema
  String _determinarEstadoGeneral(int porcentajeOperativos, int porcentajeDanados) {
    if (porcentajeOperativos >= 80) {
      return 'Excelente';
    } else if (porcentajeOperativos >= 60) {
      return 'Bueno';
    } else if (porcentajeOperativos >= 40) {
      return 'Regular';
    } else if (porcentajeDanados >= 30) {
      return 'Crítico';
    } else {
      return 'Requiere Atención';
    }
  }
}
