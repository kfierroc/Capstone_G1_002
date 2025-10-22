import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'controllers/family_controller.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_body.dart';
import 'widgets/home_bottom_nav.dart';

/// Pantalla principal de residente refactorizada siguiendo principios SOLID
/// 
/// Responsabilidades:
/// - Orquestar la navegación entre tabs
/// - Coordinar los controladores
/// - Manejar el estado de la aplicación
/// 
/// Principios aplicados:
/// - Single Responsibility: Solo maneja navegación y coordinación
/// - Dependency Inversion: Depende de abstracciones (controladores)
/// - Open/Closed: Extensible sin modificar código existente
class ResidentHomeScreen extends StatefulWidget {
  final RegistrationData? registrationData;

  const ResidentHomeScreen({super.key, this.registrationData});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;
  
  // Controladores inyectados
  late final FamilyController _familyController;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  @override
  void dispose() {
    _familyController.dispose();
    super.dispose();
  }

  /// Inicializa los controladores
  void _initializeControllers() {
    _familyController = FamilyController();
  }

  /// Carga los datos del usuario
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Cargar datos usando el controlador disponible
      await _familyController.loadFamilyMembers();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja el cambio de tab
  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Maneja el logout
  Future<void> _logout() async {
    final shouldLogout = await _showLogoutDialog();
    if (!shouldLogout) return;

    try {
      await _familyController.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al cerrar sesión: ${e.toString()}');
      }
    }
  }

  /// Muestra diálogo de confirmación de logout
  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Muestra mensaje de error
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onLogoutPressed: _logout,
        isLoading: _isLoading,
      ),
      body: HomeBody(
        currentIndex: _currentIndex,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        familyController: _familyController,
        onRetry: _loadUserData,
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}
