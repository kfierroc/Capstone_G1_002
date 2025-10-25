import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/unified_auth_service.dart';
import '../../services/database_service.dart' as db;
import '../../utils/app_styles.dart';
import 'tabs/family_tab.dart';
import 'tabs/pets_tab.dart';
import 'tabs/residence_tab.dart';
import 'tabs/settings_tab.dart';

/// Pantalla principal de residente - Completamente refactorizada y optimizada
/// 
/// Mejoras implementadas:
/// - Lazy loading de tabs con AutomaticKeepAliveClientMixin
/// - Componentes modulares separados en archivos
/// - Estilos centralizados
/// - Estado optimizado
/// - Código limpio y mantenible
class ResidentHomeScreen extends StatefulWidget {
  final RegistrationData? registrationData;

  const ResidentHomeScreen({super.key, this.registrationData});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;
  late RegistrationData _registrationData;
  
  // Listas optimizadas con modelos tipados
  List<FamilyMember> _familyMembers = [];
  List<Mascota> _pets = [];
  
  bool _isLoading = true;
  bool _isLoadingData = false; // Bandera para evitar cargas duplicadas
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _registrationData = widget.registrationData ?? RegistrationData();
    
    // Verificar autenticación antes de cargar datos
    final authService = UnifiedAuthService();
    debugPrint('🔍 Verificando autenticación en initState:');
    debugPrint('   - Está autenticado: ${authService.isAuthenticated}');
    debugPrint('   - Usuario actual: ${authService.currentUser?.id}');
    debugPrint('   - Email: ${authService.userEmail}');
    
    if (authService.isAuthenticated) {
      _loadUserData();
    } else {
      debugPrint('❌ Usuario no autenticado en initState');
      if (mounted) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Limpiar cualquier operación pendiente
    super.dispose();
  }
  
  /// Cargar información del usuario desde la base de datos
  Future<void> _loadUserData() async {
    // Evitar cargas duplicadas
    if (_isLoadingData) {
      debugPrint('⚠️ Ya se está cargando información del usuario, ignorando llamada duplicada');
      return;
    }
    
    try {
      _isLoadingData = true;
      
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
      
      final authService = UnifiedAuthService();
      final currentUser = authService.currentUser;
      final userEmail = authService.userEmail;
      
      debugPrint('🔍 Estado de autenticación:');
      debugPrint('   - Usuario actual: ${currentUser?.id}');
      debugPrint('   - Email del usuario: $userEmail');
      debugPrint('   - Está autenticado: ${authService.isAuthenticated}');
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        if (mounted) {
          setState(() {
            _errorMessage = 'No se pudo obtener el email del usuario';
            _isLoading = false;
          });
        }
        _isLoadingData = false;
        return;
      }
      
      debugPrint('✅ Email obtenido exitosamente: $userEmail');
      
      final databaseService = db.DatabaseService();
      final result = await databaseService.cargarInformacionCompletaUsuario(email: userEmail);
      
      if (result.isSuccess) {
        final data = result.data!;
        final registrationData = data['registrationData'] as RegistrationData;
        final integrantes = (data['integrantes'] as List<dynamic>).cast<Integrante>();
        final mascotas = (data['mascotas'] as List<dynamic>).cast<Mascota>();
        
        if (mounted) {
          setState(() {
            _registrationData = registrationData;
            _familyMembers = integrantes.map((i) => i.toFamilyMember()).where((member) => member != null).cast<FamilyMember>().toList();
            _pets = mascotas.map((m) => m).toList();
            _isLoading = false;
          });
        }
        _isLoadingData = false;
        
        debugPrint('✅ Datos del usuario cargados exitosamente');
        debugPrint('   - RUT: ${_registrationData.rut}');
        debugPrint('   - Dirección: ${_registrationData.address}');
        debugPrint('   - Teléfono: ${_registrationData.mainPhone ?? _registrationData.phoneNumber}');
        debugPrint('   - Integrantes: ${_familyMembers.length}');
        debugPrint('   - Mascotas: ${_pets.length}');
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result.error ?? 'Error al cargar información del usuario';
            _isLoading = false;
          });
        }
        _isLoadingData = false;
        debugPrint('❌ Error al cargar datos: ${result.error}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error inesperado: ${e.toString()}';
          _isLoading = false;
        });
      }
      _isLoadingData = false;
      debugPrint('❌ Error inesperado al cargar datos: $e');
    }
  }

  // ============================================
  // MANEJO DE FAMILIA
  // ============================================
  
  Future<void> _addFamilyMember(FamilyMember member) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      final integranteResult = await databaseService.agregarIntegrante(
        grupoId: grupo.idGrupoF.toString(),
        rut: member.rut, // Se pasa pero no se usa en la BD real
        edad: member.age, // Se pasa pero no se usa en la BD real
        anioNac: member.birthYear, // Este SÍ se guarda en info_integrante
        padecimiento: member.conditions.isNotEmpty ? member.conditions.join(', ') : null, // Este SÍ se guarda en info_integrante
      );
      
      if (integranteResult.isSuccess) {
        // Recargar datos desde la base de datos
        await _loadUserData();
        debugPrint('✅ Integrante agregado exitosamente');
      } else {
        debugPrint('❌ Error al agregar integrante: ${integranteResult.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al agregar integrante: $e');
    }
  }

  Future<void> _editFamilyMember(int index, FamilyMember member) async {
    try {
      debugPrint('🔧 Iniciando edición de miembro de familia en índice: $index');
      debugPrint('🔧 Datos del miembro: ${member.toString()}');
      
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar: ${grupoResult.error}');
        return;
      }
      
      debugPrint('✅ Grupo familiar obtenido: ${grupoResult.data!.idGrupoF}');
      
      final integrantesResult = await databaseService.obtenerIntegrantes(grupoId: grupoResult.data!.idGrupoF.toString());
      if (!integrantesResult.isSuccess || integrantesResult.data == null || index >= integrantesResult.data!.length) {
        debugPrint('❌ No se pudo obtener el integrante a editar');
        debugPrint('   - Resultado exitoso: ${integrantesResult.isSuccess}');
        debugPrint('   - Datos nulos: ${integrantesResult.data == null}');
        debugPrint('   - Índice: $index, Total integrantes: ${integrantesResult.data?.length ?? 0}');
        return;
      }
      
      final integrante = integrantesResult.data![index];
      debugPrint('✅ Integrante encontrado: ${integrante.idIntegrante}');
      
      final updates = {
        // Solo campos que existen en las tablas reales
        'anio_nac': member.birthYear, // Tabla info_integrante
        'padecimiento': member.conditions.isNotEmpty ? member.conditions.join(', ') : null, // Tabla info_integrante
      };
      
      debugPrint('🔧 Datos a actualizar: $updates');
      
      final result = await databaseService.actualizarIntegrante(
        integranteId: integrante.idIntegrante.toString(),
        updates: updates,
      );
      
      if (result.isSuccess) {
        // Recargar datos desde la base de datos
        await _loadUserData();
        debugPrint('✅ Integrante actualizado exitosamente');
      } else {
        debugPrint('❌ Error al actualizar integrante: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar integrante: $e');
    }
  }

  Future<void> _deleteFamilyMember(int index) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final integrantesResult = await databaseService.obtenerIntegrantes(grupoId: grupoResult.data!.idGrupoF.toString());
      if (!integrantesResult.isSuccess || integrantesResult.data == null || index >= integrantesResult.data!.length) {
        debugPrint('❌ No se pudo obtener el integrante a eliminar');
        return;
      }
      
      final integrante = integrantesResult.data![index];
      final result = await databaseService.eliminarIntegrante(integranteId: integrante.idIntegrante.toString());
      
      if (result.isSuccess) {
        // Recargar datos desde la base de datos
        await _loadUserData();
        debugPrint('✅ Integrante eliminado exitosamente');
      } else {
        debugPrint('❌ Error al eliminar integrante: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar integrante: $e');
    }
  }

  // ============================================
  // MANEJO DE MASCOTAS
  // ============================================
  
  Future<void> _addPet(Mascota pet) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      final mascotaResult = await databaseService.agregarMascota(
        grupoId: grupo.idGrupoF.toString(),
        nombre: pet.nombreM,
        especie: pet.especie,
        tamanio: pet.tamanio,
      );
      
      if (mascotaResult.isSuccess) {
        // Recargar datos desde la base de datos
        await _loadUserData();
        debugPrint('✅ Mascota agregada exitosamente');
      } else {
        debugPrint('❌ Error al agregar mascota: ${mascotaResult.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al agregar mascota: $e');
    }
  }

  Future<void> _editPet(int index, Mascota pet) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final mascotasResult = await databaseService.obtenerMascotas(grupoId: grupoResult.data!.idGrupoF.toString());
      if (!mascotasResult.isSuccess || mascotasResult.data == null || index >= mascotasResult.data!.length) {
        debugPrint('❌ No se pudo obtener la mascota a editar');
        return;
      }
      
      final mascota = mascotasResult.data![index];
      final updates = {
        'nombre_m': pet.nombreM,
        'especie': pet.especie,
        'tamanio': pet.tamanio,
      };
      
      final result = await databaseService.actualizarMascota(
        mascotaId: mascota.idMascota.toString(),
        updates: updates,
      );
      
      if (result.isSuccess) {
        if (mounted) {
          setState(() => _pets[index] = pet);
        }
        debugPrint('✅ Mascota actualizada exitosamente');
      } else {
        debugPrint('❌ Error al actualizar mascota: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar mascota: $e');
    }
  }

  Future<void> _deletePet(int index) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final mascotasResult = await databaseService.obtenerMascotas(grupoId: grupoResult.data!.idGrupoF.toString());
      if (!mascotasResult.isSuccess || mascotasResult.data == null || index >= mascotasResult.data!.length) {
        debugPrint('❌ No se pudo obtener la mascota a eliminar');
        return;
      }
      
      final mascota = mascotasResult.data![index];
      final result = await databaseService.eliminarMascota(mascotaId: mascota.idMascota.toString());
      
      if (result.isSuccess) {
        if (mounted) {
          setState(() => _pets.removeAt(index));
        }
        debugPrint('✅ Mascota eliminada exitosamente');
      } else {
        debugPrint('❌ Error al eliminar mascota: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar mascota: $e');
    }
  }

  // ============================================
  // MANEJO DE DATOS DE REGISTRO
  // ============================================
  
  Future<void> _updateRegistrationData(RegistrationData newData) async {
    try {
      final authService = UnifiedAuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = db.DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      
      // Actualizar información del grupo familiar si es necesario
      final grupoUpdates = <String, dynamic>{};
      
      debugPrint('🔍 Verificando cambios en grupo familiar:');
      debugPrint('   - RUT actual: ${_registrationData.rut}');
      debugPrint('   - RUT nuevo: ${newData.rut}');
      debugPrint('   - Teléfono actual: ${_registrationData.phoneNumber}');
      debugPrint('   - Teléfono nuevo: ${newData.phoneNumber}');
      
      if (newData.rut != null && newData.rut != _registrationData.rut) {
        grupoUpdates['rut_titular'] = newData.rut;
        debugPrint('📝 RUT cambió: ${_registrationData.rut} -> ${newData.rut}');
      }
      if (newData.phoneNumber != null && newData.phoneNumber != _registrationData.phoneNumber) {
        grupoUpdates['telefono_titular'] = newData.phoneNumber;
        debugPrint('📝 Teléfono cambió: ${_registrationData.phoneNumber} -> ${newData.phoneNumber}');
      }
      
      // También actualizar mainPhone si cambió (ambos representan el mismo teléfono)
      if (newData.mainPhone != null && newData.mainPhone != _registrationData.mainPhone) {
        grupoUpdates['telefono_titular'] = newData.mainPhone;
        debugPrint('📝 Teléfono principal cambió: ${_registrationData.mainPhone} -> ${newData.mainPhone}');
      }
      
      if (grupoUpdates.isNotEmpty) {
        debugPrint('📝 Actualizando grupo familiar con: $grupoUpdates');
        await databaseService.actualizarGrupoFamiliar(
          grupoId: grupo.idGrupoF.toString(),
          updates: grupoUpdates,
        );
        debugPrint('✅ Grupo familiar actualizado exitosamente');
      }
      
      // Actualizar condiciones médicas del integrante titular si han cambiado
      debugPrint('🔍 Verificando cambios en condiciones médicas:');
      debugPrint('   - Condiciones actuales: ${_registrationData.medicalConditions}');
      debugPrint('   - Condiciones nuevas: ${newData.medicalConditions}');
      
      if (newData.medicalConditions.isNotEmpty && newData.medicalConditions != _registrationData.medicalConditions) {
        final integrantesResult = await databaseService.obtenerIntegrantes(grupoId: grupo.idGrupoF.toString());
        if (integrantesResult.isSuccess && integrantesResult.data != null) {
          // Buscar el integrante titular (primer integrante activo)
          final integranteTitular = integrantesResult.data!.firstWhere(
            (i) => i.activoI == true,
            orElse: () => integrantesResult.data!.first,
          );
          
          final integranteUpdates = {
            'padecimiento': newData.medicalConditions.isNotEmpty 
                ? newData.medicalConditions.join(', ') 
                : null,
          };
          
          debugPrint('📝 Actualizando condiciones médicas del integrante titular: $integranteUpdates');
          await databaseService.actualizarIntegrante(
            integranteId: integranteTitular.idIntegrante.toString(),
            updates: integranteUpdates,
          );
          debugPrint('✅ Condiciones médicas actualizadas exitosamente');
        }
      }
      
      // Actualizar información de residencia
      final residenciaResult = await databaseService.obtenerResidencia(grupoId: grupo.idGrupoF.toString());
      
      if (residenciaResult.isSuccess && residenciaResult.data != null) {
        // Residencia existe, actualizar
        final residenciaUpdates = <String, dynamic>{};
        
        // Actualizar dirección si hay una nueva o si la actual es "Dirección no especificada"
        if (newData.address != null && newData.address!.isNotEmpty && newData.address != residenciaResult.data!.direccion) {
          residenciaUpdates['direccion'] = newData.address;
          debugPrint('📝 Dirección cambió: ${residenciaResult.data!.direccion} -> ${newData.address}');
        } else if (residenciaResult.data!.direccion == 'Dirección no especificada' && newData.address != null && newData.address!.isNotEmpty) {
          residenciaUpdates['direccion'] = newData.address;
          debugPrint('📝 Reemplazando "Dirección no especificada" con: ${newData.address}');
        }
        
        // Solo actualizar coordenadas si son válidas y no causan overflow
        if (newData.latitude != null && newData.latitude! != 0.0) {
          residenciaUpdates['lat'] = double.parse(newData.latitude!.toStringAsFixed(6));
        }
        if (newData.longitude != null && newData.longitude! != 0.0) {
          residenciaUpdates['lon'] = double.parse(newData.longitude!.toStringAsFixed(6));
        }
        
        // Los campos telefonoPrincipal se manejan en otras tablas
        // telefonoPrincipal -> grupofamiliar.telefono_titular
        
        if (residenciaUpdates.isNotEmpty) {
          await databaseService.actualizarResidencia(
            grupoId: grupo.idGrupoF.toString(),
            updates: residenciaUpdates,
          );
        }
        
        // Actualizar también el registro_v si hay cambios en material, tipo, estado, pisos
        if (newData.constructionMaterial != _registrationData.constructionMaterial || 
            newData.housingType != _registrationData.housingType || 
            newData.housingCondition != _registrationData.housingCondition || 
            newData.numberOfFloors != _registrationData.numberOfFloors) {
          
          final registroVUpdates = <String, dynamic>{};
          
          // Actualizar material si cambió
          if (newData.constructionMaterial != _registrationData.constructionMaterial) {
            registroVUpdates['constructionMaterial'] = newData.constructionMaterial;
            debugPrint('📝 Material cambió: ${_registrationData.constructionMaterial} -> ${newData.constructionMaterial}');
          }
          
          // Actualizar tipo si cambió
          if (newData.housingType != _registrationData.housingType) {
            registroVUpdates['housingType'] = newData.housingType;
            debugPrint('📝 Tipo vivienda cambió: ${_registrationData.housingType} -> ${newData.housingType}');
          }
          
          // Actualizar estado si cambió
          if (newData.housingCondition != _registrationData.housingCondition) {
            registroVUpdates['housingCondition'] = newData.housingCondition;
            debugPrint('📝 Estado cambió: ${_registrationData.housingCondition} -> ${newData.housingCondition}');
          }
          
          // Actualizar pisos si cambió
          if (newData.numberOfFloors != _registrationData.numberOfFloors) {
            registroVUpdates['numberOfFloors'] = newData.numberOfFloors;
            debugPrint('📝 Pisos cambiaron: ${_registrationData.numberOfFloors} -> ${newData.numberOfFloors}');
          }
          
          if (registroVUpdates.isNotEmpty) {
            debugPrint('📝 Actualizando registro_v con: $registroVUpdates');
            await databaseService.actualizarRegistroV(
              grupoId: grupo.idGrupoF.toString(),
              updates: registroVUpdates,
            );
            debugPrint('✅ Registro_v actualizado exitosamente');
          }
        }
        
        // Campo eliminado - no hacer nada
        // if (newData.specialInstructions != _registrationData.specialInstructions) {
        //   debugPrint('📝 Instrucciones especiales cambiaron: ${_registrationData.specialInstructions} -> ${newData.specialInstructions}');
        //   
        //   final residenciaInstruccionesUpdates = <String, dynamic>{
        //     'specialInstructions': newData.specialInstructions,
        //   };
        //   
        //   debugPrint('📝 Actualizando instrucciones especiales en residencia con: $residenciaInstruccionesUpdates');
        //   await databaseService.actualizarResidencia(
        //     grupoId: grupo.idGrupoF.toString(),
        //     updates: residenciaInstruccionesUpdates,
        //   );
        //   debugPrint('✅ Instrucciones especiales actualizadas en residencia');
        // }
      } else {
        // Residencia no existe, crear una nueva
        debugPrint('🔍 Residencia no existe, creando nueva...');
        
        try {
          // Usar el método público para crear residencia
          await databaseService.crearResidencia(
            grupoId: grupo.idGrupoF.toString(),
            data: newData,
          );
          debugPrint('✅ Residencia creada exitosamente');
        } catch (e) {
          debugPrint('❌ Error al crear residencia: $e');
        }
      }
      
      // Actualizar datos localmente para reflejar cambios inmediatamente
      if (mounted) {
        setState(() {
          _registrationData = newData;
        });
      }
      
      // Recargar datos desde la base de datos para asegurar consistencia
      await _loadUserData();
      
      if (mounted) {
        debugPrint('✅ UI actualizada con datos recargados desde la base de datos');
        debugPrint('   - Dirección: ${_registrationData.address ?? "No especificada"}');
        debugPrint('   - Teléfono: ${_registrationData.phoneNumber ?? "No especificado"}');
        debugPrint('   - Teléfono principal: ${_registrationData.mainPhone ?? "No especificado"}');
        debugPrint('   - Tipo vivienda: ${_registrationData.housingType ?? "No especificado"}');
        debugPrint('   - Condiciones médicas: ${_registrationData.medicalConditions.length} condiciones');
        debugPrint('   - Instrucciones especiales: Campo eliminado');
      }
      debugPrint('✅ Datos de registro actualizados exitosamente');
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar datos de registro: $e');
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final authService = UnifiedAuthService();
      await authService.signOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final isTablet = width >= 600;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(isTablet),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(isTablet),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return PreferredSize(
      preferredSize: Size.fromHeight(isTablet ? 120 : 100),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icono de la app con fondo circular
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.home_work,
                    color: Colors.white,
                    size: isTablet ? 32 : 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mi Información Familiar',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona la información de tu domicilio',
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de logout modernizado
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _logout,
                    icon: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: isTablet ? 26 : 24,
                    ),
                    tooltip: 'Cerrar sesión',
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Mostrar indicador de carga mientras se cargan los datos
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando información del usuario...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    // Mostrar error si hubo problemas al cargar los datos
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadUserData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // IndexedStack con lazy loading
    // Solo construye el tab actual, optimizando recursos
    return IndexedStack(
      index: _currentIndex,
      children: [
        FamilyTab(
          familyMembers: _familyMembers,
          onAdd: _addFamilyMember,
          onEdit: _editFamilyMember,
          onDelete: _deleteFamilyMember,
        ),
        PetsTab(
          pets: _pets,
          onAdd: _addPet,
          onEdit: _editPet,
          onDelete: _deletePet,
        ),
        ResidenceTab(
          registrationData: _registrationData,
          onUpdate: _updateRegistrationData,
        ),
        SettingsTab(
          registrationData: _registrationData,
          onUpdate: _updateRegistrationData,
          onLogout: _logout,
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isTablet) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: _getSelectedColor(),
      unselectedItemColor: AppColors.textTertiary,
      selectedFontSize: isTablet ? 14 : 12,
      unselectedFontSize: isTablet ? 12 : 10,
      iconSize: isTablet ? 28 : 24,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.familyAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people, color: AppColors.familyPrimary),
          ),
          label: 'Familia',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.petsAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.pets, color: AppColors.petsPrimary),
          ),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.residenceAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.home, color: AppColors.residencePrimary),
          ),
          label: 'Domicilio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.settingsAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings, color: AppColors.settingsPrimary),
          ),
          label: 'Configuración',
        ),
      ],
    );
  }

  Color _getSelectedColor() {
    switch (_currentIndex) {
      case 0:
        return AppColors.familyPrimary;
      case 1:
        return AppColors.petsPrimary;
      case 2:
        return AppColors.residencePrimary;
      case 3:
        return AppColors.settingsPrimary;
      default:
        return AppColors.primary;
    }
  }
}
