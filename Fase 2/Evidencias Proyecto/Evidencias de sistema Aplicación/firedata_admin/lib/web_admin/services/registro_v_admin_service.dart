import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firedata_admin/config/supabase_config.dart';
import 'package:firedata_admin/models/registro_v.dart';

/// Servicio para gestionar registros de vivienda (registro_v)
class RegistroVAdminService {
  RegistroVAdminService._();

  static final RegistroVAdminService instance = RegistroVAdminService._();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Obtener registro_v por id_residencia
  Future<RegistroV?> fetchRegistroVByResidencia(int idResidencia) async {
    final data = await _client
        .from('registro_v')
        .select()
        .eq('id_residencia', idResidencia)
        .eq('vigente', true)
        .order('fecha_ini_r', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return RegistroV.fromJson(data as Map<String, dynamic>);
  }

  /// Crear registro_v
  Future<RegistroV> insertRegistroV(RegistroV registro) async {
    final data = registro.toInsertData();
    final idRegistro = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    data['id_registro'] = idRegistro;

    await _client.from('registro_v').insert(data);

    final response = await _client
        .from('registro_v')
        .select()
        .eq('id_registro', idRegistro)
        .single();

    return RegistroV.fromJson(response as Map<String, dynamic>);
  }

  /// Actualizar registro_v
  Future<void> updateRegistroV(RegistroV registro) async {
    await _client
        .from('registro_v')
        .update(registro.toUpdateData())
        .eq('id_registro', registro.idRegistro);
  }

  /// Eliminar registro_v
  Future<void> deleteRegistroV(int idRegistro) async {
    await _client
        .from('registro_v')
        .delete()
        .eq('id_registro', idRegistro);
  }
}

