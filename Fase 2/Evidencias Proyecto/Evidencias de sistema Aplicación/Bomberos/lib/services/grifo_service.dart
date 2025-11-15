import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio para manejar operaciones CRUD de grifos
/// Incluye métodos seguros con try/catch para todas las operaciones
class GrifoService {
  static final GrifoService _instance = GrifoService._internal();
  factory GrifoService() => _instance;
  GrifoService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Insertar un nuevo grifo
  Future<ServiceResult<Grifo>> insertGrifo(Grifo grifo) async {
    try {
      debugPrint('🔧 Insertando grifo con cutCom: ${grifo.cutCom}');
      
      // Verificar estado de comunas primero
      await _verificarEstadoComunas();
      
      // Intentar insertar comunas básicas primero
      await _insertarComunasBasicas();
      
      // Verificar que la comuna existe antes de insertar
      final comunaExiste = await _verificarComunaExiste(grifo.cutCom);
      if (!comunaExiste) {
        debugPrint('❌ La comuna ${grifo.cutCom} no existe en la base de datos');
        
        // Intentar crear la comuna específica
        final comunaCreada = await _crearComunaEspecifica(grifo.cutCom);
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
      return ServiceResult.success(nuevoGrifo);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error PostgrestException al insertar grifo: ${e.message}');
      return ServiceResult.error('Error al insertar grifo: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al insertar grifo: $e');
      return ServiceResult.error('Error inesperado al insertar grifo: ${e.toString()}');
    }
  }

  /// Obtener grifo por ID
  Future<ServiceResult<Grifo>> getGrifoById(int idGrifo) async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('id_grifo', idGrifo)
          .single();

      final grifo = Grifo.fromJson(response);
      return ServiceResult.success(grifo);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifo: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos
  Future<ServiceResult<List<Grifo>>> getAllGrifos() async {
    try {
      final response = await _client
          .from('grifo')
          .select('*')
          .order('id_grifo', ascending: true);

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      return ServiceResult.success(grifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos de una comuna
  Future<ServiceResult<List<Grifo>>> getGrifosByComuna(String cutCom) async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*)
          ''')
          .eq('cut_com', cutCom);

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      return ServiceResult.success(grifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos con su información adicional
  Future<ServiceResult<List<Map<String, dynamic>>>> getGrifosConInfo() async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*),
            info_grifo(*)
          ''');

      return ServiceResult.success(response);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos con información: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos con información: ${e.toString()}');
    }
  }

  /// Obtener todos los grifos con información completa incluyendo bombero que reportó
  Future<ServiceResult<List<Map<String, dynamic>>>> getGrifosConInfoCompleta() async {
    try {
      final response = await _client
          .from('grifo')
          .select('''
            *,
            comunas!inner(*),
            info_grifo(
              *,
              bombero!inner(*)
            )
          ''');

      return ServiceResult.success(response);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grifos con información completa: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grifos con información completa: ${e.toString()}');
    }
  }

  /// Buscar grifos cercanos a coordenadas (radio aproximado)
  Future<ServiceResult<List<Grifo>>> getGrifosNearby({
    required double lat,
    required double lon,
    required double radiusKm,
  }) async {
    try {
      // Usar una consulta SQL personalizada para búsqueda por radio
      final response = await _client
          .rpc('get_grifos_nearby', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      final grifos = (response as List)
          .map((json) => Grifo.fromJson(json))
          .toList();

      return ServiceResult.success(grifos);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al buscar grifos cercanos: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al buscar grifos cercanos: ${e.toString()}');
    }
  }

  /// Obtener estadísticas de grifos por comuna
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasGrifos() async {
    try {
      final response = await _client
          .from('grifo')
          .select('cut_com, comunas!inner(comuna)');

      final Map<String, int> estadisticas = {};
      
      for (final item in response as List) {
        final comuna = item['comunas']['comuna'] as String;
        estadisticas[comuna] = (estadisticas[comuna] ?? 0) + 1;
      }

      return ServiceResult.success({
        'total_grifos': estadisticas.values.fold(0, (sum, count) => sum + count),
        'por_comuna': estadisticas,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas: ${e.toString()}');
    }
  }

  /// Actualizar grifo
  Future<ServiceResult<Grifo>> updateGrifo(Grifo grifo) async {
    try {
      final response = await _client
          .from('grifo')
          .update(grifo.toJson())
          .eq('id_grifo', grifo.idGrifo)
          .select()
          .single();

      final grifoActualizado = Grifo.fromJson(response);
      return ServiceResult.success(grifoActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar grifo: ${e.toString()}');
    }
  }

  /// Eliminar grifo
  Future<ServiceResult<void>> deleteGrifo(int idGrifo) async {
    try {
      await _client
          .from('grifo')
          .delete()
          .eq('id_grifo', idGrifo);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar grifo: ${e.toString()}');
    }
  }

  /// Verificar si existe un grifo en las mismas coordenadas
  Future<ServiceResult<bool>> existeGrifoEnCoordenadas(double lat, double lon) async {
    try {
      final response = await _client
          .from('grifo')
          .select('id_grifo')
          .eq('lat', lat)
          .eq('lon', lon)
          .limit(1);

      return ServiceResult.success((response as List).isNotEmpty);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al verificar grifo: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al verificar grifo: ${e.toString()}');
    }
  }

  /// Obtener nombre de comuna por código CUT
  Future<ServiceResult<String>> obtenerNombreComunaPorCutCom(int cutCom) async {
    try {
      debugPrint('🔍 Buscando nombre de comuna para código: $cutCom');
      
      final response = await _client
          .from('comunas')
          .select('comuna')
          .eq('cut_com', cutCom)
          .limit(1);
      
      if (response.isNotEmpty) {
        final nombreComuna = response.first['comuna'] as String;
        debugPrint('✅ Comuna encontrada: $nombreComuna');
        return ServiceResult.success(nombreComuna);
      } else {
        debugPrint('⚠️ No se encontró comuna para código: $cutCom');
        return ServiceResult.success('Comuna $cutCom'); // Fallback
      }
    } catch (e) {
      debugPrint('❌ Error al obtener nombre de comuna: $e');
      return ServiceResult.error('Error al obtener nombre de comuna: ${e.toString()}');
    }
  }

  /// Obtener código CUT de una comuna por nombre
  Future<ServiceResult<int>> obtenerCutComPorNombre(String nombreComuna) async {
    try {
      final nombreLimpio = nombreComuna.trim();
      
      debugPrint('🔍 Buscando comuna: "$nombreLimpio"');
      
      // Primero verificar qué comunas existen en la base de datos
      final comunasExistentes = await _client
          .from('comunas')
          .select('cut_com, comuna')
          .limit(10);
      
      debugPrint('📋 Comunas existentes en BD: $comunasExistentes');
      
      // Si no hay comunas, insertar comunas básicas
      if (comunasExistentes.isEmpty) {
        debugPrint('⚠️ No hay comunas en la BD, insertando comunas básicas...');
        await _insertarComunasBasicas();
      }
      
      // Primero buscar coincidencia exacta (case insensitive)
      var response = await _client
          .from('comunas')
          .select('cut_com')
          .ilike('comuna', nombreLimpio)
          .limit(1);
      
      debugPrint('🎯 Búsqueda exacta para "$nombreLimpio": $response');
      
      if (response.isNotEmpty) {
        final cutCom = response.first['cut_com'] as int;
        debugPrint('✅ Comuna encontrada (exacta): $cutCom');
        return ServiceResult.success(cutCom);
      }
      
      // Si no hay coincidencia exacta, buscar coincidencia parcial
      response = await _client
          .from('comunas')
          .select('cut_com')
          .ilike('comuna', '%$nombreLimpio%')
          .limit(1);
      
      debugPrint('🔍 Búsqueda parcial para "$nombreLimpio": $response');
      
      if (response.isNotEmpty) {
        final cutCom = response.first['cut_com'] as int;
        debugPrint('✅ Comuna encontrada (parcial): $cutCom');
        return ServiceResult.success(cutCom);
      }
      
      // Si no se encuentra, usar Santiago por defecto
      const cutComDefault = 13101; // Santiago
      debugPrint('⚠️ No se encontró comuna, usando Santiago por defecto: $cutComDefault');
      
      // Intentar crear la comuna si no existe
      try {
        await _client.from('comunas').insert({
          'cut_com': cutComDefault,
          'comuna': 'Santiago',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 641.4,
          'geometry': 'POINT(-70.6693 -33.4489)',
        });
        debugPrint('✅ Comuna Santiago creada exitosamente');
      } catch (e) {
        debugPrint('⚠️ Error al crear comuna Santiago: $e');
        // Si ya existe, no hay problema
      }
      
      return ServiceResult.success(cutComDefault);
    } on PostgrestException catch (e) {
      debugPrint('❌ Error PostgrestException: ${e.message}');
      return ServiceResult.error('Error al obtener código de comuna: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado: $e');
      return ServiceResult.error('Error inesperado al obtener código de comuna: ${e.toString()}');
    }
  }

  /// Verificar si una comuna existe en la base de datos
  Future<bool> _verificarComunaExiste(int cutCom) async {
    try {
      debugPrint('🔍 Verificando si existe comuna con cutCom: $cutCom');
      
      final response = await _client
          .from('comunas')
          .select('cut_com')
          .eq('cut_com', cutCom)
          .limit(1);
      
      final existe = response.isNotEmpty;
      debugPrint('📊 Resultado verificación comuna $cutCom: $existe');
      
      return existe;
    } catch (e) {
      debugPrint('❌ Error al verificar comuna $cutCom: $e');
      return false;
    }
  }

  /// Crear una comuna específica si no existe
  Future<bool> _crearComunaEspecifica(int cutCom) async {
    try {
      debugPrint('🏗️ Intentando crear comuna específica: $cutCom');
      
      // Mapeo de comunas comunes con sus datos
      final comunasComunes = {
        13101: {
          'comuna': 'Santiago',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 641.4,
          'geometry': 'MULTIPOLYGON(((-70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489)))',
        },
        13102: {
          'comuna': 'Providencia',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 14.4,
          'geometry': 'MULTIPOLYGON(((-70.6167 -33.4255, -70.6167 -33.4255, -70.6167 -33.4255, -70.6167 -33.4255)))',
        },
        13103: {
          'comuna': 'Las Condes',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 99.4,
          'geometry': 'MULTIPOLYGON(((-70.5500 -33.4000, -70.5500 -33.4000, -70.5500 -33.4000, -70.5500 -33.4000)))',
        },
        13104: {
          'comuna': 'Ñuñoa',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 16.9,
          'geometry': 'MULTIPOLYGON(((-70.6000 -33.4500, -70.6000 -33.4500, -70.6000 -33.4500, -70.6000 -33.4500)))',
        },
        13105: {
          'comuna': 'Maipú',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 133.0,
          'geometry': 'MULTIPOLYGON(((-70.7500 -33.5000, -70.7500 -33.5000, -70.7500 -33.5000, -70.7500 -33.5000)))',
        },
      };
      
      // Si tenemos datos para esta comuna, crearla
      if (comunasComunes.containsKey(cutCom)) {
        final datosComuna = comunasComunes[cutCom]!;
        final comunaData = {
          'cut_com': cutCom,
          ...datosComuna,
        };
        
        await _client.from('comunas').insert(comunaData);
        debugPrint('✅ Comuna $cutCom creada exitosamente');
        return true;
      } else {
        // Si no tenemos datos específicos, crear una comuna genérica
        final comunaGenerica = {
          'cut_com': cutCom,
          'comuna': 'Comuna $cutCom',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 100.0,
          'geometry': 'MULTIPOLYGON(((-70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489)))',
        };
        
        await _client.from('comunas').insert(comunaGenerica);
        debugPrint('✅ Comuna genérica $cutCom creada exitosamente');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Error al crear comuna $cutCom: $e');
      return false;
    }
  }

  /// Verificar estado de la base de datos de comunas
  Future<void> _verificarEstadoComunas() async {
    try {
      debugPrint('🔍 Verificando estado de comunas en la base de datos...');
      
      // Contar total de comunas
      final totalComunas = await _client
          .from('comunas')
          .select('cut_com');
      
      debugPrint('📊 Total de comunas en BD: ${totalComunas.length}');
      
      // Listar las primeras 10 comunas
      final comunas = await _client
          .from('comunas')
          .select('cut_com, comuna')
          .limit(10);
      
      debugPrint('📋 Primeras comunas:');
      for (final comuna in comunas) {
        debugPrint('  - ${comuna['comuna']} (${comuna['cut_com']})');
      }
      
      // Verificar específicamente Santiago
      final santiago = await _client
          .from('comunas')
          .select('cut_com, comuna')
          .eq('cut_com', 13101)
          .limit(1);
      
      if (santiago.isNotEmpty) {
        debugPrint('✅ Santiago (13101) existe en la BD');
      } else {
        debugPrint('❌ Santiago (13101) NO existe en la BD');
      }
      
    } catch (e) {
      debugPrint('❌ Error al verificar estado de comunas: $e');
    }
  }
  /// Insertar comunas básicas si no existen
  Future<void> _insertarComunasBasicas() async {
    try {
      debugPrint('🏙️ Insertando comunas básicas...');
      
      final comunasBasicas = [
        {
          'cut_com': 13101,
          'comuna': 'Santiago',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 641.4,
          'geometry': 'MULTIPOLYGON(((-70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489, -70.6693 -33.4489)))',
        },
        {
          'cut_com': 13102,
          'comuna': 'Providencia',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 14.4,
          'geometry': 'MULTIPOLYGON(((-70.6167 -33.4255, -70.6167 -33.4255, -70.6167 -33.4255, -70.6167 -33.4255)))',
        },
        {
          'cut_com': 13103,
          'comuna': 'Las Condes',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 99.4,
          'geometry': 'MULTIPOLYGON(((-70.5500 -33.4000, -70.5500 -33.4000, -70.5500 -33.4000, -70.5500 -33.4000)))',
        },
        {
          'cut_com': 13104,
          'comuna': 'Ñuñoa',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 16.9,
          'geometry': 'MULTIPOLYGON(((-70.6000 -33.4500, -70.6000 -33.4500, -70.6000 -33.4500, -70.6000 -33.4500)))',
        },
        {
          'cut_com': 13105,
          'comuna': 'Maipú',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 133.0,
          'geometry': 'MULTIPOLYGON(((-70.7500 -33.5000, -70.7500 -33.5000, -70.7500 -33.5000, -70.7500 -33.5000)))',
        },
      ];

      int insertadas = 0;
      for (final comuna in comunasBasicas) {
        try {
          await _client.from('comunas').insert(comuna);
          debugPrint('✅ Comuna insertada: ${comuna['comuna']} (${comuna['cut_com']})');
          insertadas++;
        } catch (e) {
          debugPrint('⚠️ Comuna ${comuna['comuna']} ya existe o error: $e');
        }
      }
      
      debugPrint('🏙️ Comunas básicas procesadas: $insertadas insertadas');
    } catch (e) {
      debugPrint('❌ Error al insertar comunas básicas: $e');
    }
  }
}

/// Servicio para manejar operaciones CRUD de info_grifo
class InfoGrifoService {
  static final InfoGrifoService _instance = InfoGrifoService._internal();
  factory InfoGrifoService() => _instance;
  InfoGrifoService._internal();

  // Obtener cliente de Supabase
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
      return ServiceResult.success(nuevaInfoGrifo);
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

      return ServiceResult.success(infoGrifos);
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

      return ServiceResult.success(infoGrifos);
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

      return ServiceResult.success(infoGrifos);
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
      return ServiceResult.success(infoGrifoActualizado);
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

      return ServiceResult.success(null);
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

      return ServiceResult.success({
        'total_inspecciones': estadisticas.values.fold(0, (sum, count) => sum + count),
        'por_estado': estadisticas,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas de inspecciones: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas de inspecciones: ${e.toString()}');
    }
  }
}

/// Clase para representar el resultado de operaciones de servicio
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ServiceResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ServiceResult.success(T data) => ServiceResult._(
    isSuccess: true,
    data: data,
  );

  factory ServiceResult.error(String error) => ServiceResult._(
    isSuccess: false,
    error: error,
  );
}
