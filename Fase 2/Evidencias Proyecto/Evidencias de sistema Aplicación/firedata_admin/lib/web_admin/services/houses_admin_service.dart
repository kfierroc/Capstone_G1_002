import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/residencia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HousesAdminService {
  HousesAdminService._();

  static final HousesAdminService instance = HousesAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Residencia>> fetchHouses({
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Obtener residencias con información de registro_v y grupo familiar
      final data = await _client
          .from('residencia')
          .select('''
            id_residencia,
            direccion,
            lat,
            lon,
            cut_com,
            registro_v(
              id_registro,
              vigente,
              estado,
              material,
              tipo,
              pisos,
              fecha_ini_r,
              fecha_fin_r,
              id_grupof,
              instrucciones_especiales,
              grupofamiliar(
                rut_titular
              )
            )
          ''')
          .order('direccion')
          .range(offset, offset + limit - 1);

      final list = (data as List).cast<Map<String, dynamic>>();
      final houses = list.map((json) {
        // Procesar registro_v para obtener el primero vigente
        final registrosV = json['registro_v'];
        Map<String, dynamic>? registroVigente;
        
        // Debug: ver qué datos estamos recibiendo
        if (registrosV != null) {
          print('🔍 Procesando registro_v para residencia ${json['id_residencia']}: ${registrosV.runtimeType}');
        }
        
        if (registrosV != null) {
          if (registrosV is List) {
            final listaRegistros = registrosV as List<dynamic>;
            if (listaRegistros.isNotEmpty) {
              // Buscar el registro vigente más reciente (ordenar por fecha_ini_r)
              final registrosConFecha = listaRegistros
                  .where((r) => r is Map && r['fecha_ini_r'] != null)
                  .toList();
              
              if (registrosConFecha.isNotEmpty) {
                // Ordenar por fecha_ini_r descendente (más reciente primero)
                registrosConFecha.sort((a, b) {
                  final fechaA = DateTime.tryParse(a['fecha_ini_r'].toString());
                  final fechaB = DateTime.tryParse(b['fecha_ini_r'].toString());
                  if (fechaA == null || fechaB == null) return 0;
                  return fechaB.compareTo(fechaA); // Más reciente primero
                });
                
                // Priorizar registros vigentes, pero si no hay, tomar el más reciente
                final vigentes = registrosConFecha.where((r) => r['vigente'] == true).toList();
                if (vigentes.isNotEmpty) {
                  // Si hay vigentes, tomar el más reciente de los vigentes
                  registroVigente = vigentes.first as Map<String, dynamic>;
                } else {
                  // Si no hay vigentes, tomar el más reciente de todos
                  registroVigente = registrosConFecha.first as Map<String, dynamic>;
                }
              } else {
                // Si no hay fechas, priorizar vigentes pero tomar cualquier registro si existe
                final vigentes = listaRegistros.where((r) => r['vigente'] == true).toList();
                if (vigentes.isNotEmpty) {
                  registroVigente = vigentes.first as Map<String, dynamic>;
                } else if (listaRegistros.isNotEmpty) {
                  // Tomar cualquier registro si existe relación, aunque no esté vigente
                  registroVigente = listaRegistros.first as Map<String, dynamic>;
                }
              }
            }
          } else if (registrosV is Map) {
            registroVigente = registrosV as Map<String, dynamic>;
          }
        }
        
        // Procesar grupofamiliar si viene como lista
        if (registroVigente != null && registroVigente.containsKey('grupofamiliar')) {
          final grupoFamiliar = registroVigente['grupofamiliar'];
          print('🔍 Procesando grupofamiliar: ${grupoFamiliar.runtimeType}');
          if (grupoFamiliar is List && grupoFamiliar.isNotEmpty) {
            // Si es una lista, tomar el primer elemento
            registroVigente['grupofamiliar'] = grupoFamiliar.first;
            print('✅ grupofamiliar procesado desde lista: ${grupoFamiliar.first}');
          } else if (grupoFamiliar is Map) {
            print('✅ grupofamiliar es un Map: ${grupoFamiliar['rut_titular']}');
          }
        } else if (registroVigente != null) {
          print('⚠️ registro_v no contiene grupofamiliar');
        }
        
        // Construir JSON con registro_v anidado
        final processedJson = Map<String, dynamic>.from(json);
        if (registroVigente != null) {
          processedJson['registro_v'] = registroVigente;
        }
        
        return Residencia.fromJson(processedJson);
      }).toList();

      if (search != null && search.trim().isNotEmpty) {
        final term = search.trim().toLowerCase();
        return houses.where((house) {
          final instructions = house.instruccionesEspeciales ?? '';
          final rut = house.rutResidente ?? '';
          final estado = house.estado ?? '';
          final material = house.material ?? '';
          final tipo = house.tipo ?? '';
          return house.direccion.toLowerCase().contains(term) ||
              instructions.toLowerCase().contains(term) ||
              rut.toLowerCase().contains(term) ||
              estado.toLowerCase().contains(term) ||
              material.toLowerCase().contains(term) ||
              tipo.toLowerCase().contains(term);
        }).toList();
      }

      return houses;
    } catch (e) {
      // Si hay error con la consulta anidada, intentar sin relaciones
      try {
        final data = await _client
            .from('residencia')
            .select('id_residencia, direccion, lat, lon, cut_com')
            .order('direccion')
            .range(offset, offset + limit - 1);
        
        final list = (data as List).cast<Map<String, dynamic>>();
        return list.map((json) => Residencia.fromJson(json)).toList();
      } catch (e2) {
        rethrow;
      }
    }
  }

  Future<void> insertHouse(Residencia house) async {
    await _client.from('residencia').insert(house.toJson());
  }

  Future<void> updateHouse(Residencia house) async {
    await _client
        .from('residencia')
        .update(house.toJson())
        .eq('id_residencia', house.idResidencia);
  }

  Future<void> deleteHouse(int id) async {
    await _client.from('residencia').delete().eq('id_residencia', id);
  }
}




