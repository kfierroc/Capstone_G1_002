import 'base_database_service.dart';
import 'database_common.dart';
import 'grupo_familiar_service.dart';
import 'residencia_service.dart';
import 'integrante_service.dart';
import 'mascota_service.dart';
import 'comuna_service.dart';
import 'registro_v_service.dart';
import '../../models/models.dart';

/// Servicio coordinador para cargar toda la información del usuario
/// 
/// Este servicio orquesta las llamadas a otros servicios especializados
/// para cargar la información completa del usuario de manera eficiente.
class UserDataService extends BaseDatabaseService {
  
  // Servicios especializados
  final GrupoFamiliarService _grupoService = GrupoFamiliarService();
  final ResidenciaService _residenciaService = ResidenciaService();
  final IntegranteService _integranteService = IntegranteService();
  final MascotaService _mascotaService = MascotaService();
  final ComunaService _comunaService = ComunaService();
  final RegistroVService _registroVService = RegistroVService();

  /// Cargar toda la información del usuario (grupo familiar + residencia + integrantes + mascotas)
  Future<DatabaseResult<Map<String, dynamic>>> cargarInformacionCompletaUsuario({
    required String email,
  }) async {
    try {
      logProgress('Cargando información completa del usuario', details: 'email: $email');
      
      // 1. Obtener grupo familiar
      final grupoResult = await _grupoService.obtenerGrupoFamiliar(email: email);
      if (!grupoResult.isSuccess) {
        logError('Cargar información completa', 'Grupo familiar no encontrado');
        return error('Usuario no encontrado. Por favor, regístrate primero.');
      }
      
      final grupo = grupoResult.data!;
      logSuccess('Grupo familiar cargado', details: 'ID: ${grupo.idGrupof}');
      
      // 2. Obtener residencia
      final residenciaResult = await _obtenerResidenciaPorGrupo(grupo.idGrupof.toString());
      final residencia = residenciaResult.isSuccess ? residenciaResult.data : null;
      
      // 3. Obtener integrantes
      final integrantesResult = await _integranteService.obtenerIntegrantes(
        grupoId: grupo.idGrupof.toString(),
      );
      final integrantes = integrantesResult.isSuccess ? integrantesResult.data ?? [] : [];
      
      // 4. Obtener mascotas
      final mascotasResult = await _mascotaService.obtenerMascotas(
        grupoId: grupo.idGrupof.toString(),
      );
      final mascotas = mascotasResult.isSuccess ? mascotasResult.data ?? [] : [];
      
      // 5. Obtener datos de registro_v para material, tipo, estado, pisos
      final registroVResult = await _registroVService.obtenerRegistroVVigente(
        grupoId: grupo.idGrupof.toString(),
      );
      
      String? materialVivienda;
      String? tipoVivienda;
      String? estadoVivienda;
      int? pisosVivienda;
      
      if (registroVResult.isSuccess && registroVResult.data != null) {
        final registroV = registroVResult.data!;
        materialVivienda = registroV['material'] as String?;
        tipoVivienda = registroV['tipo'] as String?;
        estadoVivienda = registroV['estado'] as String?;
        pisosVivienda = registroV['pisos'] as int?;
      }
      
      // 6. Campo instrucciones especiales eliminado del sistema
      
      // 7. Obtener comuna si hay residencia
      Comuna? comuna;
      if (residencia != null) {
        final comunaResult = await _comunaService.obtenerComuna(
          cutCom: residencia.cutCom.toString(),
        );
        if (comunaResult.isSuccess) {
          comuna = comunaResult.data;
        }
      }
      
      // 8. Construir RegistrationData con la información obtenida
      final integranteTitular = integrantes.isNotEmpty ? integrantes.first : null;
      
      final registrationData = RegistrationData(
        // Datos personales del titular
        rut: grupo.rutTitular,
        fullName: 'Usuario', // Nombre por defecto ya que no se almacena nombre/apellido
        email: grupo.email,
        phoneNumber: grupo.telefonoTitular,
        mainPhone: grupo.telefonoTitular,
        
        // Datos de residencia
        address: residencia?.direccion,
        latitude: residencia?.lat,
        longitude: residencia?.lon,
        // commune: comuna?.comuna, // No disponible en RegistrationData
        
        // Datos de vivienda
        housingType: tipoVivienda,
        numberOfFloors: pisosVivienda,
        constructionMaterial: materialVivienda,
        housingCondition: estadoVivienda,
        
        // Datos de familia - No disponibles en RegistrationData
        // familyMembers: integrantes.map((i) => i.toFamilyMember()).where((f) => f != null).cast<FamilyMember>().toList(),
        // pets: mascotas.map((m) => m.toPet()).toList(),
        
        // Condiciones médicas del titular
        medicalConditions: integranteTitular?.padecimiento != null 
            ? parseMedicalConditions(integranteTitular!.padecimiento)
            : [],
      );
      
      // 9. Construir resultado final
      final result = {
        'grupo_familiar': grupo,
        'residencia': residencia,
        'comuna': comuna,
        'integrantes': integrantes,
        'mascotas': mascotas,
        'registration_data': registrationData,
        'material_vivienda': materialVivienda,
        'tipo_vivienda': tipoVivienda,
        'estado_vivienda': estadoVivienda,
        'pisos_vivienda': pisosVivienda,
      };
      
      logSuccess('Información completa cargada', details: 'Usuario: ${grupo.email}');
      
      return success(result, message: 'Información del usuario cargada exitosamente');
      
    } catch (e) {
      logError('Cargar información completa del usuario', e);
      return handleError(e, customMessage: 'Error al cargar información del usuario');
    }
  }

  /// Obtener residencia por grupo familiar
  Future<DatabaseResult<Residencia?>> _obtenerResidenciaPorGrupo(String grupoId) async {
    try {
      // Buscar residencia a través de registro_v
      final registroVResult = await _registroVService.obtenerRegistroVVigente(grupoId: grupoId);
      
      if (!registroVResult.isSuccess || registroVResult.data == null) {
        return success(null);
      }
      
      final registroV = registroVResult.data!;
      final residenciaId = registroV['id_residencia'] as int;
      
      final residenciaResult = await _residenciaService.obtenerResidencia(
        residenciaId: residenciaId.toString(),
      );
      
      if (residenciaResult.isSuccess) {
        return success(residenciaResult.data);
      } else {
        return success(null);
      }
      
    } catch (e) {
      logError('Obtener residencia por grupo', e);
      return success(null); // No fallar si no hay residencia
    }
  }

  /// Crear grupo familiar completo (grupo + residencia + registro_v)
  Future<DatabaseResult<Map<String, dynamic>>> crearGrupoFamiliarCompleto({
    required String userId,
    required RegistrationData data,
  }) async {
    try {
      logProgress('Creando grupo familiar completo', details: 'userId: $userId');
      
      // 1. Crear grupo familiar
      final grupoResult = await _grupoService.crearGrupoFamiliar(
        userId: userId,
        data: data,
      );
      
      if (!grupoResult.isSuccess) {
        return error(grupoResult.error ?? 'Error al crear grupo familiar');
      }
      
      final grupo = grupoResult.data!;
      logSuccess('Grupo familiar creado', details: 'ID: ${grupo.idGrupof}');
      
      // 2. Crear residencia si hay datos de dirección
      Residencia? residencia;
      if (data.address != null && data.address!.isNotEmpty) {
        final residenciaId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        
        // Obtener comuna
        int cutCom = 13101; // Santiago por defecto
        if (data.address != null) {
          final comunaResult = await _comunaService.buscarComunas(query: data.address!);
          if (comunaResult.isSuccess && comunaResult.data!.isNotEmpty) {
            cutCom = int.parse(comunaResult.data!.first.cutCom.toString());
          }
        }
        
        final residenciaResult = await _residenciaService.crearResidencia(
          idResidencia: residenciaId,
          direccion: data.address!,
          lat: data.latitude ?? 0.0,
          lon: data.longitude ?? 0.0,
          cutCom: cutCom,
          numeroPisos: data.numberOfFloors,
          instruccionesEspeciales: null, // Campo eliminado
        );
        
        if (residenciaResult.isSuccess) {
          residencia = residenciaResult.data;
          logSuccess('Residencia creada', details: 'ID: ${residencia!.idResidencia}');
        }
      }
      
      // 3. Crear registro_v si hay residencia
      if (residencia != null) {
        final registroVResult = await _registroVService.crearRegistroV(
          grupoId: grupo.idGrupof.toString(),
          residenciaId: residencia.idResidencia.toString(),
          material: data.constructionMaterial ?? 'No especificado',
          tipo: data.housingType ?? 'No especificado',
          pisos: data.numberOfFloors ?? 1,
          estado: data.housingCondition ?? 'No especificado',
        );
        
        if (registroVResult.isSuccess) {
          logSuccess('Registro_v creado', details: 'ID: ${registroVResult.data!['id_registro']}');
        }
      }
      
      // 4. Crear integrantes si hay familia - Comentado porque familyMembers no existe en RegistrationData
      // if (data.familyMembers.isNotEmpty) {
      //   for (final member in data.familyMembers) {
      //     final integranteResult = await _integranteService.crearIntegrante(
      //       grupoId: grupo.idGrupof.toString(),
      //       rut: member.rut,
      //       fechaIniI: member.createdAt,
      //     );
      //     
      //     if (integranteResult.isSuccess) {
      //       // Crear info_integrante
      //       await _integranteService.crearInfoIntegrante(
      //         integranteId: integranteResult.data!.idIntegrante.toString(),
      //         anioNac: member.birthYear,
      //         padecimiento: member.conditions.isNotEmpty ? member.conditions.join(', ') : null,
      //       );
      //       
      //       logSuccess('Integrante creado', details: 'RUT: ${member.rut}');
      //     }
      //   }
      // }
      
      // 5. Crear mascotas si hay - Comentado porque pets no existe en RegistrationData
      // if (data.pets.isNotEmpty) {
      //   for (final pet in data.pets) {
      //     final mascotaResult = await _mascotaService.crearMascota(
      //       grupoId: grupo.idGrupof.toString(),
      //       nombreM: pet.name,
      //       especie: pet.species,
      //       tamanio: pet.size,
      //     );
      //     
      //     if (mascotaResult.isSuccess) {
      //       logSuccess('Mascota creada', details: 'Nombre: ${pet.name}');
      //     }
      //   }
      // }
      
      final result = {
        'grupo_familiar': grupo,
        'residencia': residencia,
        'success': true,
      };
      
      logSuccess('Grupo familiar completo creado', details: 'ID: ${grupo.idGrupof}');
      
      return success(result, message: 'Grupo familiar completo creado exitosamente');
      
    } catch (e) {
      logError('Crear grupo familiar completo', e);
      return handleError(e, customMessage: 'Error al crear grupo familiar completo');
    }
  }

  /// Actualizar información completa del usuario
  Future<DatabaseResult<void>> actualizarInformacionCompleta({
    required String grupoId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      logProgress('Actualizando información completa', details: 'grupoId: $grupoId');
      
      // Actualizar grupo familiar si hay cambios
      if (updates.containsKey('grupo_familiar')) {
        final grupoUpdates = updates['grupo_familiar'] as Map<String, dynamic>;
        await _grupoService.actualizarGrupoFamiliar(
          grupoId: grupoId,
          updates: grupoUpdates,
        );
      }
      
      // Actualizar residencia si hay cambios
      if (updates.containsKey('residencia')) {
        final residenciaUpdates = updates['residencia'] as Map<String, dynamic>;
        // Obtener residencia actual
        final residenciaResult = await _obtenerResidenciaPorGrupo(grupoId);
        if (residenciaResult.isSuccess && residenciaResult.data != null) {
          await _residenciaService.actualizarResidencia(
            residenciaId: residenciaResult.data!.idResidencia.toString(),
            updates: residenciaUpdates,
          );
        }
      }
      
      // Actualizar registro_v si hay cambios
      if (updates.containsKey('registro_v')) {
        final registroVUpdates = updates['registro_v'] as Map<String, dynamic>;
        final registroVResult = await _registroVService.obtenerRegistroVVigente(grupoId: grupoId);
        if (registroVResult.isSuccess && registroVResult.data != null) {
          await _registroVService.actualizarRegistroV(
            registroId: registroVResult.data!['id_registro'].toString(),
            updates: registroVUpdates,
          );
        }
      }
      
      logSuccess('Información completa actualizada', details: 'grupoId: $grupoId');
      
      return success(null, message: 'Información actualizada exitosamente');
      
    } catch (e) {
      logError('Actualizar información completa', e);
      return handleError(e, customMessage: 'Error al actualizar información');
    }
  }
}
