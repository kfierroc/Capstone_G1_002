import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../models/family_member.dart';
import '../../models/pet.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
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
  List<Pet> _pets = [];
  
  bool _isLoading = true;
  bool _isLoadingData = false; // Bandera para evitar cargas duplicadas
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _registrationData = widget.registrationData ?? RegistrationData();
    
    // Verificar autenticación antes de cargar datos
    final authService = AuthService();
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
      
      final authService = AuthService();
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
      
      final databaseService = DatabaseService();
      final result = await databaseService.cargarInformacionCompletaUsuario(email: userEmail);
      
      if (result.isSuccess) {
        final data = result.data!;
        final registrationData = data['registrationData'] as RegistrationData;
        final integrantes = (data['integrantes'] as List<dynamic>).cast<Integrante>();
        final mascotas = (data['mascotas'] as List<dynamic>).cast<Mascota>();
        
        if (mounted) {
          setState(() {
            _registrationData = registrationData;
            _familyMembers = integrantes.map((i) => i.toFamilyMember()).toList();
            _pets = mascotas.map((m) => m.toPet()).toList();
            _isLoading = false;
          });
        }
        _isLoadingData = false;
        
        debugPrint('✅ Datos del usuario cargados exitosamente');
        debugPrint('   - RUT: ${_registrationData.rut}');
        debugPrint('   - Dirección: ${_registrationData.address}');
        debugPrint('   - Teléfono: ${_registrationData.phoneNumber}');
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
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      final integranteResult = await databaseService.agregarIntegrante(
        grupoId: grupo.idGrupoF.toString(),
        rut: member.rut,
        edad: member.age,
        anioNac: member.birthYear,
        padecimiento: member.conditions.isNotEmpty ? member.conditions.join(', ') : null,
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
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final integrantesResult = await databaseService.obtenerIntegrantes(grupoId: grupoResult.data!.idGrupoF.toString());
      if (!integrantesResult.isSuccess || integrantesResult.data == null || index >= integrantesResult.data!.length) {
        debugPrint('❌ No se pudo obtener el integrante a editar');
        return;
      }
      
      final integrante = integrantesResult.data![index];
      final updates = {
        'rut': member.rut,
        'edad': member.age,
        'anio_nac': member.birthYear,
        'padecimiento': member.conditions.isNotEmpty ? member.conditions.join(', ') : null,
      };
      
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
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
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
  
  Future<void> _addPet(Pet pet) async {
    try {
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      final mascotaResult = await databaseService.agregarMascota(
        grupoId: grupo.idGrupoF.toString(),
        nombre: pet.name,
        especie: pet.species,
        tamanio: pet.size,
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

  Future<void> _editPet(int index, Pet pet) async {
    try {
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
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
        'nombre_m': pet.name,
        'especie': pet.species,
        'tamanio': pet.size,
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
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
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
      final authService = AuthService();
      final userEmail = authService.userEmail;
      
      if (userEmail == null) {
        debugPrint('❌ No se pudo obtener el email del usuario');
        return;
      }
      
      final databaseService = DatabaseService();
      final grupoResult = await databaseService.obtenerGrupoFamiliar(email: userEmail);
      
      if (!grupoResult.isSuccess) {
        debugPrint('❌ No se pudo obtener el grupo familiar');
        return;
      }
      
      final grupo = grupoResult.data!;
      
      // Actualizar información del grupo familiar si es necesario
      if (newData.rut != _registrationData.rut) {
        final grupoUpdates = {
          'rut_titular': newData.rut,
        };
        await databaseService.actualizarGrupoFamiliar(
          grupoId: grupo.idGrupoF.toString(),
          updates: grupoUpdates,
        );
      }
      
      // Actualizar información de residencia
      final residenciaResult = await databaseService.obtenerResidencia(grupoId: grupo.idGrupoF.toString());
      
      if (residenciaResult.isSuccess && residenciaResult.data != null) {
        // Residencia existe, actualizar
        final residenciaUpdates = {
          if (newData.address != null) 'direccion': newData.address,
          // Solo actualizar coordenadas si son válidas y no causan overflow
          if (newData.latitude != null && newData.latitude! != 0.0) 
            'lat': double.parse(newData.latitude!.toStringAsFixed(1)), // Limitar a 1 decimal
          if (newData.longitude != null && newData.longitude! != 0.0) 
            'lon': double.parse(newData.longitude!.toStringAsFixed(1)), // Limitar a 1 decimal
          // Solo incluir campos que existen en la BD real
          if (newData.mainPhone != null) 'telefono_principal': newData.mainPhone,
          if (newData.alternatePhone != null) 'telefono_alternativo': newData.alternatePhone,
          if (newData.housingType != null) 'tipo_vivienda': newData.housingType,
          if (newData.numberOfFloors != null) 'numero_pisos': newData.numberOfFloors,
          if (newData.constructionMaterial != null) 'material_construccion': newData.constructionMaterial,
          if (newData.specialInstructions != null) 'instrucciones_especiales': newData.specialInstructions,
          // Comentar campos que no existen en la BD real
          // if (newData.housingCondition != null) 'estado_vivienda': newData.housingCondition,
        };
        
        if (residenciaUpdates.isNotEmpty) {
        await databaseService.actualizarResidencia(
          grupoId: grupo.idGrupoF.toString(),
          updates: residenciaUpdates,
        );
        }
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
      
      if (mounted) {
        setState(() => _registrationData = newData);
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
      final authService = AuthService();
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
      appBar: _buildAppBar(isTablet),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(isTablet),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi Información Familiar',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          Text(
            'Gestiona la información de tu domicilio',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _logout,
          icon: Icon(
            Icons.logout,
            size: isTablet ? 26 : 24,
          ),
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Mostrar indicador de carga mientras se cargan los datos
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando información del usuario...'),
          ],
        ),
      );
    }
    
    // Mostrar error si hubo problemas al cargar los datos
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Reintentar'),
            ),
          ],
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
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      selectedFontSize: isTablet ? 14 : 12,
      unselectedFontSize: isTablet ? 12 : 10,
      iconSize: isTablet ? 28 : 24,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Familia',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Domicilio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}
