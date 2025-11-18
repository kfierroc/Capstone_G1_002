import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/integrante.dart';
import 'package:firedata_admin/models/info_integrante.dart';

/// Servicio para gestionar integrantes del grupo familiar
class IntegrantesAdminService {
  IntegrantesAdminService._();

  static final IntegrantesAdminService instance = IntegrantesAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Obtener todos los integrantes de un grupo familiar
  Future<List<Map<String, dynamic>>> fetchIntegrantes(int idGrupof) async {
    final data = await _client
        .from('integrante')
        .select('''
          id_integrante,
          activo_i,
          fecha_ini_i,
          fecha_fin_i,
          id_grupof,
          info_integrante(
            id_integrante,
            fecha_reg_ii,
            anio_nac,
            padecimiento
          )
        ''')
        .eq('id_grupof', idGrupof)
        .order('fecha_ini_i', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  /// Crear integrante con su información
  Future<Map<String, dynamic>> insertIntegrante({
    required int idGrupof,
    required int anioNac,
    String? padecimiento,
    bool activoI = true,
  }) async {
    final idIntegrante = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Crear integrante
    await _client.from('integrante').insert({
      'id_integrante': idIntegrante,
      'activo_i': activoI,
      'fecha_ini_i': DateTime.now().toIso8601String().split('T')[0],
      'id_grupof': idGrupof,
    });

    // Crear info_integrante
    await _client.from('info_integrante').insert({
      'id_integrante': idIntegrante,
      'fecha_reg_ii': DateTime.now().toIso8601String().split('T')[0],
      'anio_nac': anioNac,
      'padecimiento': padecimiento,
    });

    final response = await _client
        .from('integrante')
        .select('''
          id_integrante,
          activo_i,
          fecha_ini_i,
          fecha_fin_i,
          id_grupof,
          info_integrante(
            id_integrante,
            fecha_reg_ii,
            anio_nac,
            padecimiento
          )
        ''')
        .eq('id_integrante', idIntegrante)
        .single();

    return response as Map<String, dynamic>;
  }

  /// Actualizar información de integrante
  Future<void> updateIntegranteInfo({
    required int idIntegrante,
    required int anioNac,
    String? padecimiento,
  }) async {
    await _client
        .from('info_integrante')
        .update({
          'anio_nac': anioNac,
          'padecimiento': padecimiento,
        })
        .eq('id_integrante', idIntegrante);
  }

  /// Eliminar integrante
  Future<void> deleteIntegrante(int idIntegrante) async {
    // Primero eliminar info_integrante (FK)
    await _client
        .from('info_integrante')
        .delete()
        .eq('id_integrante', idIntegrante);
    
    // Luego eliminar integrante
    await _client
        .from('integrante')
        .delete()
        .eq('id_integrante', idIntegrante);
  }
}

