import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Servicio de búsqueda para bomberos que conecta con datos de residentes
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Buscar direcciones y obtener información de residentes
  Future<ServiceResult<List<Map<String, dynamic>>>> searchAddresses(String query) async {
    try {
      debugPrint('🔍 SearchService - Buscando direcciones: $query');
      
      // Buscar residencias que coincidan con la dirección
      final response = await _client
          .from('residencia')
          .select('''
            *,
            registro_v!inner(
              *,
              grupofamiliar!inner(
                *,
                integrante(
                  *,
                  info_integrante(*)
                ),
                mascota(*)
              )
            )
          ''')
          .ilike('direccion', '%$query%')
          .eq('registro_v.vigente', true);

      debugPrint('📦 Respuesta de búsqueda: ${response.length} resultados');

      final results = <Map<String, dynamic>>[];
      
      for (final residencia in response) {
        // registro_v puede ser una lista o un mapa, dependiendo de la consulta
        final registroVData = residencia['registro_v'];
        Map<String, dynamic>? registroV;
        
        if (registroVData is List) {
          // Si es una lista, tomar el primer elemento
          registroV = registroVData.isNotEmpty ? registroVData.first as Map<String, dynamic>? : null;
        } else if (registroVData is Map<String, dynamic>) {
          registroV = registroVData;
        }
        
        if (registroV == null) continue;
        
        // grupofamiliar también puede ser una lista o un mapa
        final grupoFamiliarData = registroV['grupofamiliar'];
        Map<String, dynamic>? grupoFamiliar;
        
        if (grupoFamiliarData is List) {
          // Si es una lista, tomar el primer elemento
          grupoFamiliar = grupoFamiliarData.isNotEmpty ? grupoFamiliarData.first as Map<String, dynamic>? : null;
        } else if (grupoFamiliarData is Map<String, dynamic>) {
          grupoFamiliar = grupoFamiliarData;
        }
        
        if (grupoFamiliar == null) continue;

        final integrantes = grupoFamiliar['integrante'] as List<dynamic>? ?? [];
        final mascotas = grupoFamiliar['mascota'] as List<dynamic>? ?? [];

        // Construir información del resultado
        final result = {
          'id_residencia': residencia['id_residencia'],
          'address': residencia['direccion'],
          'lat': residencia['lat'],
          'lon': residencia['lon'],
          'cut_com': residencia['cut_com'],
          'grupo_familiar': {
            'id_grupof': grupoFamiliar['id_grupof'],
            'rut_titular': grupoFamiliar['rut_titular'],
            'nomb_titular': grupoFamiliar['nomb_titular'],
            'ape_p_titular': grupoFamiliar['ape_p_titular'],
            'telefono_titular': grupoFamiliar['telefono_titular'],
            'email': grupoFamiliar['email'],
            'fecha_creacion': grupoFamiliar['fecha_creacion'],
          },
          'integrantes': integrantes.where((i) => i['activo_i'] == true).map((i) {
            final infoIntegrante = i['info_integrante'] as Map<String, dynamic>?;
            return {
              'id_integrante': i['id_integrante'],
              'activo_i': i['activo_i'],
              'fecha_ini_i': i['fecha_ini_i'],
              'edad': infoIntegrante?['anio_nac'] != null 
                  ? DateTime.now().year - (infoIntegrante!['anio_nac'] as int)
                  : null,
              'anio_nacimiento': infoIntegrante?['anio_nac'],
              'padecimientos': infoIntegrante?['padecimiento']?.toString().split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList() ?? [],
            };
          }).toList(),
          'mascotas': mascotas.map((m) => {
            'id_mascota': m['id_mascota'],
            'nombre_m': m['nombre_m'],
            'especie': m['especie'],
            'tamanio': m['tamanio'],
            'fecha_reg_m': m['fecha_reg_m'],
          }).toList(),
          'registro_v': {
            'material': registroV['material'],
            'tipo': registroV['tipo'],
            'estado': registroV['estado'],
            'pisos': registroV['pisos'],
            'instrucciones_especiales': registroV['instrucciones_especiales'],
            'fecha_ini_r': registroV['fecha_ini_r'],
          },
          'last_updated': DateTime.now().toIso8601String(),
        };

        results.add(result);
      }

      debugPrint('✅ Búsqueda completada: ${results.length} resultados encontrados');
      
      return ServiceResult.success(results);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de Supabase en búsqueda: ${e.message}');
      return ServiceResult.error('Error al buscar direcciones: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado en búsqueda: $e');
      return ServiceResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Buscar por coordenadas (radio aproximado)
  Future<ServiceResult<List<Map<String, dynamic>>>> searchByCoordinates({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    try {
      debugPrint('📍 SearchService - Buscando por coordenadas: $lat, $lon (radio: ${radiusKm}km)');
      
      // Usar función SQL personalizada para búsqueda por radio
      final response = await _client
          .rpc('search_residencias_nearby', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      final results = <Map<String, dynamic>>[];
      
      for (final item in response) {
        results.add({
          'id_residencia': item['id_residencia'],
          'address': item['direccion'],
          'lat': item['lat'],
          'lon': item['lon'],
          'distance_km': item['distance_km'],
          'grupo_familiar': item['grupo_familiar'],
          'integrantes': item['integrantes'],
          'mascotas': item['mascotas'],
          'registro_v': item['registro_v'],
          'last_updated': DateTime.now().toIso8601String(),
        });
      }

      debugPrint('✅ Búsqueda por coordenadas completada: ${results.length} resultados');
      
      return ServiceResult.success(results);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de Supabase en búsqueda por coordenadas: ${e.message}');
      return ServiceResult.error('Error al buscar por coordenadas: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado en búsqueda por coordenadas: $e');
      return ServiceResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Validar si la consulta de búsqueda es válida
  bool isValidSearchQuery(String query) {
    return query.trim().length >= 3;
  }

  /// Obtener información detallada de una residencia específica
  Future<ServiceResult<Map<String, dynamic>>> getResidenceDetails(int residenciaId) async {
    try {
      debugPrint('🔍 SearchService - Obteniendo detalles de residencia: $residenciaId');
      
      final response = await _client
          .from('residencia')
          .select('''
            *,
            registro_v!inner(
              *,
              grupofamiliar!inner(
                *,
                integrante(
                  *,
                  info_integrante(*)
                ),
                mascota(*)
              )
            )
          ''')
          .eq('id_residencia', residenciaId)
          .eq('registro_v.vigente', true)
          .single();

      // registro_v puede ser una lista o un mapa, dependiendo de la consulta
      final registroVData = response['registro_v'];
      Map<String, dynamic>? registroV;
      
      if (registroVData is List) {
        // Si es una lista, tomar el primer elemento
        registroV = registroVData.isNotEmpty ? registroVData.first as Map<String, dynamic>? : null;
      } else if (registroVData is Map<String, dynamic>) {
        registroV = registroVData;
      }
      
      if (registroV == null) {
        return ServiceResult.error('No se encontró información del registro');
      }

      // grupofamiliar también puede ser una lista o un mapa
      final grupoFamiliarData = registroV['grupofamiliar'];
      Map<String, dynamic>? grupoFamiliar;
      
      if (grupoFamiliarData is List) {
        // Si es una lista, tomar el primer elemento
        grupoFamiliar = grupoFamiliarData.isNotEmpty ? grupoFamiliarData.first as Map<String, dynamic>? : null;
      } else if (grupoFamiliarData is Map<String, dynamic>) {
        grupoFamiliar = grupoFamiliarData;
      }
      
      if (grupoFamiliar == null) {
        return ServiceResult.error('No se encontró información del grupo familiar');
      }

      final integrantes = grupoFamiliar['integrante'] as List<dynamic>? ?? [];
      final mascotas = grupoFamiliar['mascota'] as List<dynamic>? ?? [];

      final details = {
        'id_residencia': response['id_residencia'],
        'address': response['direccion'],
        'lat': response['lat'],
        'lon': response['lon'],
        'cut_com': response['cut_com'],
        'grupo_familiar': {
          'id_grupof': grupoFamiliar['id_grupof'],
          'rut_titular': grupoFamiliar['rut_titular'],
          'nomb_titular': grupoFamiliar['nomb_titular'],
          'ape_p_titular': grupoFamiliar['ape_p_titular'],
          'telefono_titular': grupoFamiliar['telefono_titular'],
          'email': grupoFamiliar['email'],
          'fecha_creacion': grupoFamiliar['fecha_creacion'],
        },
        'integrantes': integrantes.where((i) => i['activo_i'] == true).map((i) {
          final infoIntegrante = i['info_integrante'] as Map<String, dynamic>?;
          return {
            'id_integrante': i['id_integrante'],
            'activo_i': i['activo_i'],
            'fecha_ini_i': i['fecha_ini_i'],
            'edad': infoIntegrante?['anio_nac'] != null 
                ? DateTime.now().year - (infoIntegrante!['anio_nac'] as int)
                : null,
            'anio_nacimiento': infoIntegrante?['anio_nac'],
            'padecimientos': infoIntegrante?['padecimiento']?.toString().split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList() ?? [],
          };
        }).toList(),
        'mascotas': mascotas.map((m) => {
          'id_mascota': m['id_mascota'],
          'nombre_m': m['nombre_m'],
          'especie': m['especie'],
          'tamanio': m['tamanio'],
          'fecha_reg_m': m['fecha_reg_m'],
        }).toList(),
        'registro_v': {
          'material': registroV['material'],
          'tipo': registroV['tipo'],
          'estado': registroV['estado'],
          'pisos': registroV['pisos'],
          'instrucciones_especiales': registroV['instrucciones_especiales'],
          'fecha_ini_r': registroV['fecha_ini_r'],
        },
        'last_updated': DateTime.now().toIso8601String(),
      };

      debugPrint('✅ Detalles de residencia obtenidos exitosamente');
      
      return ServiceResult.success(details);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error de Supabase al obtener detalles: ${e.message}');
      return ServiceResult.error('Error al obtener detalles: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener detalles: $e');
      return ServiceResult.error('Error inesperado: ${e.toString()}');
    }
  }
}

/// Resultado de operación del servicio
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ServiceResult._(this.isSuccess, this.data, this.error);

  factory ServiceResult.success(T data) => ServiceResult._(true, data, null);
  factory ServiceResult.error(String error) => ServiceResult._(false, null, error);
}