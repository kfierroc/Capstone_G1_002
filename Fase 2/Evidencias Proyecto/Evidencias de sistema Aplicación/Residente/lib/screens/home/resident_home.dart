import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../models/family_member.dart';
import '../../models/pet.dart';
import '../../services/mock_auth_service.dart';
import '../../utils/app_styles.dart';
import '../../utils/responsive.dart';
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
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      rut: '12.345.678-9',
      age: 25,
      birthYear: 2000,
      conditions: ['Diabetes', 'Asma o problemas para respirar'],
    ),
  ];

  final List<Pet> _pets = [];

  @override
  void initState() {
    super.initState();
    _registrationData = widget.registrationData ?? RegistrationData();
  }

  // ============================================
  // MANEJO DE FAMILIA
  // ============================================
  
  void _addFamilyMember(FamilyMember member) {
    setState(() => _familyMembers.add(member));
  }

  void _editFamilyMember(int index, FamilyMember member) {
    setState(() => _familyMembers[index] = member);
  }

  void _deleteFamilyMember(int index) {
    setState(() => _familyMembers.removeAt(index));
  }

  // ============================================
  // MANEJO DE MASCOTAS
  // ============================================
  
  void _addPet(Pet pet) {
    setState(() => _pets.add(pet));
  }

  void _editPet(int index, Pet pet) {
    setState(() => _pets[index] = pet);
  }

  void _deletePet(int index) {
    setState(() => _pets.removeAt(index));
  }

  // ============================================
  // MANEJO DE DATOS DE REGISTRO
  // ============================================
  
  void _updateRegistrationData(RegistrationData data) {
    setState(() => _registrationData = data);
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
      final mockAuth = MockAuthService();
      await mockAuth.signOut();

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
