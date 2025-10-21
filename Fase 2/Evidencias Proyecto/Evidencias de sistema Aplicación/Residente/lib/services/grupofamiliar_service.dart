import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';
import 'residencia_service.dart';

/// Servicio para manejar operaciones CRUD de grupos familiares
/// Incluye métodos para insertar datos relacionados y consultas con joins
class GrupoFamiliarService {
  static final GrupoFamiliarService _instance = GrupoFamiliarService._internal();
  factory GrupoFamiliarService() => _instance;
  GrupoFamiliarService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Obtener grupo familiar completo con todos sus datos relacionados
  Future<ServiceResult<Map<String, dynamic>>> getGrupoFamiliarCompleto(int idGrupof) async {
    try {
      // Consulta con múltiples joins para obtener todos los datos relacionados
      final response = await _client
          .from('grupofamiliar')
          .select('''
            *,
            registro_v!inner(
              *,
              residencia!inner(
                *,
                comunas!inner(*)
              )
            ),
            integrante(
              *,
              info_integrante(*)
            ),
            mascota(*)
          ''')
          .eq('id_grupof', idGrupof)
          .single();

      return ServiceResult.success(response);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener grupo familiar: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener grupo familiar: ${e.toString()}');
    }
  }

  /// Insertar grupo familiar completo con todos sus datos relacionados
  Future<ServiceResult<Map<String, dynamic>>> insertGrupoFamiliarCompleto({
    required GrupoFamiliar grupoFamiliar,
    required Residencia residencia,
    required RegistroV registroV,
    List<Integrante>? integrantes,
    List<InfoIntegrante>? infoIntegrantes,
    List<Mascota>? mascotas,
  }) async {
    try {
      // Iniciar transacción
      final results = <String, dynamic>{};

      // Paso 1: Insertar residencia
      final residenciaResult = await ResidenciaService().insertResidencia(residencia);
      if (!residenciaResult.isSuccess) {
        return ServiceResult.error('Error al insertar residencia: ${residenciaResult.error}');
      }
      results['residencia'] = residenciaResult.data!;

      // Paso 2: Insertar grupo familiar
      final grupoFamiliarData = grupoFamiliar.toInsertData();
      final grupoFamiliarResponse = await _client
          .from('grupofamiliar')
          .insert(grupoFamiliarData)
          .select()
          .single();
      final grupoFamiliarInsertado = GrupoFamiliar.fromJson(grupoFamiliarResponse);
      results['grupoFamiliar'] = grupoFamiliarInsertado;

      // Paso 3: Insertar registro_v
      final registroVData = registroV.copyWith(
        idResidencia: residenciaResult.data!.idResidencia,
        idGrupof: grupoFamiliarInsertado.idGrupof,
      ).toInsertData();
      
      final registroVResponse = await _client
          .from('registro_v')
          .insert(registroVData)
          .select()
          .single();
      results['registroV'] = RegistroV.fromJson(registroVResponse);

      // Paso 4: Insertar integrantes si existen
      if (integrantes != null && integrantes.isNotEmpty) {
        final integrantesInsertados = <Integrante>[];
        for (int i = 0; i < integrantes.length; i++) {
          final integrante = integrantes[i];
          final integranteData = integrante.copyWith(
            idGrupof: grupoFamiliarInsertado.idGrupof,
          ).toInsertData();
          
          final integranteResponse = await _client
              .from('integrante')
              .insert(integranteData)
              .select()
              .single();
          
          final integranteInsertado = Integrante.fromJson(integranteResponse);
          integrantesInsertados.add(integranteInsertado);

          // Insertar info_integrante si existe
          if (infoIntegrantes != null && i < infoIntegrantes.length) {
            final infoIntegrante = infoIntegrantes[i];
            final infoIntegranteData = infoIntegrante.copyWith(
              idIntegrante: integranteInsertado.idIntegrante,
            ).toInsertData();
            
            await _client
                .from('info_integrante')
                .insert(infoIntegranteData);
          }
        }
        results['integrantes'] = integrantesInsertados;
      }

      // Paso 5: Insertar mascotas si existen
      if (mascotas != null && mascotas.isNotEmpty) {
        final mascotasInsertadas = <Mascota>[];
        for (final mascota in mascotas) {
          final mascotaData = mascota.copyWith(
            idGrupof: grupoFamiliarInsertado.idGrupof,
          ).toInsertData();
          
          final mascotaResponse = await _client
              .from('mascota')
              .insert(mascotaData)
              .select()
              .single();
          
          mascotasInsertadas.add(Mascota.fromJson(mascotaResponse));
        }
        results['mascotas'] = mascotasInsertadas;
      }

      return ServiceResult.success(results);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar grupo familiar: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar grupo familiar: ${e.toString()}');
    }
  }

  /// Insertar integrante con su información
  Future<ServiceResult<Map<String, dynamic>>> insertIntegranteCompleto({
    required Integrante integrante,
    required InfoIntegrante infoIntegrante,
    required int idGrupof,
  }) async {
    try {
      // Paso 1: Insertar integrante
      final integranteData = integrante.copyWith(idGrupof: idGrupof).toInsertData();
      final integranteResponse = await _client
          .from('integrante')
          .insert(integranteData)
          .select()
          .single();
      
      final integranteInsertado = Integrante.fromJson(integranteResponse);

      // Paso 2: Insertar info_integrante
      final infoIntegranteData = infoIntegrante.copyWith(
        idIntegrante: integranteInsertado.idIntegrante,
      ).toInsertData();
      
      final infoIntegranteResponse = await _client
          .from('info_integrante')
          .insert(infoIntegranteData)
          .select()
          .single();

      return ServiceResult.success({
        'integrante': integranteInsertado,
        'infoIntegrante': InfoIntegrante.fromJson(infoIntegranteResponse),
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar integrante: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar integrante: ${e.toString()}');
    }
  }

  /// Insertar mascota
  Future<ServiceResult<Mascota>> insertMascota(Mascota mascota, int idGrupof) async {
    try {
      final mascotaData = mascota.copyWith(idGrupof: idGrupof).toInsertData();
      final response = await _client
          .from('mascota')
          .insert(mascotaData)
          .select()
          .single();

      final mascotaInsertada = Mascota.fromJson(response);
      return ServiceResult.success(mascotaInsertada);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al insertar mascota: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al insertar mascota: ${e.toString()}');
    }
  }

  /// Obtener integrantes de un grupo familiar
  Future<ServiceResult<List<Map<String, dynamic>>>> getIntegrantes(int idGrupof) async {
    try {
      final response = await _client
          .from('integrante')
          .select('''
            *,
            info_integrante(*)
          ''')
          .eq('id_grupof', idGrupof);

      return ServiceResult.success(response);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener integrantes: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener integrantes: ${e.toString()}');
    }
  }

  /// Obtener mascotas de un grupo familiar
  Future<ServiceResult<List<Mascota>>> getMascotas(int idGrupof) async {
    try {
      final response = await _client
          .from('mascota')
          .select('*')
          .eq('id_grupof', idGrupof);

      final mascotas = (response as List)
          .map((json) => Mascota.fromJson(json))
          .toList();

      return ServiceResult.success(mascotas);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener mascotas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener mascotas: ${e.toString()}');
    }
  }

  /// Obtener registro_v de un grupo familiar
  Future<ServiceResult<List<RegistroV>>> getRegistrosV(int idGrupof) async {
    try {
      final response = await _client
          .from('registro_v')
          .select('''
            *,
            residencia!inner(
              *,
              comunas!inner(*)
            )
          ''')
          .eq('id_grupof', idGrupof);

      final registros = (response as List)
          .map((json) => RegistroV.fromJson(json))
          .toList();

      return ServiceResult.success(registros);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener registros: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener registros: ${e.toString()}');
    }
  }

  /// Actualizar integrante
  Future<ServiceResult<Integrante>> updateIntegrante(Integrante integrante) async {
    try {
      final response = await _client
          .from('integrante')
          .update(integrante.toUpdateData())
          .eq('id_integrante', integrante.idIntegrante)
          .select()
          .single();

      final integranteActualizado = Integrante.fromJson(response);
      return ServiceResult.success(integranteActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar integrante: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar integrante: ${e.toString()}');
    }
  }

  /// Actualizar info_integrante
  Future<ServiceResult<InfoIntegrante>> updateInfoIntegrante(InfoIntegrante infoIntegrante) async {
    try {
      final response = await _client
          .from('info_integrante')
          .update(infoIntegrante.toUpdateData())
          .eq('id_integrante', infoIntegrante.idIntegrante)
          .select()
          .single();

      final infoIntegranteActualizado = InfoIntegrante.fromJson(response);
      return ServiceResult.success(infoIntegranteActualizado);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar info integrante: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar info integrante: ${e.toString()}');
    }
  }

  /// Actualizar mascota
  Future<ServiceResult<Mascota>> updateMascota(Mascota mascota) async {
    try {
      final response = await _client
          .from('mascota')
          .update(mascota.toUpdateData())
          .eq('id_mascota', mascota.idMascota)
          .select()
          .single();

      final mascotaActualizada = Mascota.fromJson(response);
      return ServiceResult.success(mascotaActualizada);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al actualizar mascota: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al actualizar mascota: ${e.toString()}');
    }
  }

  /// Eliminar integrante (marca como inactivo)
  Future<ServiceResult<void>> desactivarIntegrante(int idIntegrante) async {
    try {
      await _client
          .from('integrante')
          .update({
            'activo_i': false,
            'fecha_fin_i': DateTime.now().toIso8601String(),
          })
          .eq('id_integrante', idIntegrante);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al desactivar integrante: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al desactivar integrante: ${e.toString()}');
    }
  }

  /// Eliminar mascota
  Future<ServiceResult<void>> deleteMascota(int idMascota) async {
    try {
      await _client
          .from('mascota')
          .delete()
          .eq('id_mascota', idMascota);

      return ServiceResult.success(null);
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al eliminar mascota: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al eliminar mascota: ${e.toString()}');
    }
  }

  /// Obtener estadísticas del grupo familiar
  Future<ServiceResult<Map<String, dynamic>>> getEstadisticasGrupoFamiliar(int idGrupof) async {
    try {
      // Obtener conteos de diferentes entidades
      final integrantesCount = await _client
          .from('integrante')
          .select('id_integrante')
          .eq('id_grupof', idGrupof)
          .eq('activo_i', true);

      final mascotasCount = await _client
          .from('mascota')
          .select('id_mascota')
          .eq('id_grupof', idGrupof);

      final registrosCount = await _client
          .from('registro_v')
          .select('id_registro')
          .eq('id_grupof', idGrupof)
          .eq('vigente', true);

      return ServiceResult.success({
        'integrantes_activos': integrantesCount.length,
        'mascotas': mascotasCount.length,
        'registros_vigentes': registrosCount.length,
      });
    } on PostgrestException catch (e) {
      return ServiceResult.error('Error al obtener estadísticas: ${e.message}');
    } catch (e) {
      return ServiceResult.error('Error inesperado al obtener estadísticas: ${e.toString()}');
    }
  }
}
