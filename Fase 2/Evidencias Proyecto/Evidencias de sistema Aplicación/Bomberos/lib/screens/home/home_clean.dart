import 'package:flutter/material.dart';
import '../../app.dart';
import '../auth/login.dart';
import 'search_results_refactored.dart';
import '../grifos/grifos_home_screen.dart';

/// Pantalla principal del sistema de emergencias - Versión limpia
class HomeScreenClean extends StatefulWidget {
  const HomeScreenClean({super.key});

  @override
  State<HomeScreenClean> createState() => _HomeScreenCleanState();
}

class _HomeScreenCleanState extends State<HomeScreenClean> {
  final TextEditingController _searchController = TextEditingController();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga el perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      // Carga de perfil desde Supabase
      final profile = <String, dynamic>{
        'email': 'usuario@ejemplo.com',
        'name': 'Usuario Bombero',
      };
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
        _showErrorSnackBar('Error al cargar perfil: ${e.toString()}');
      }
    }
  }

  /// Realiza búsqueda de domicilio
  void _searchAddress() {
    if (_searchController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingresa un domicilio');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          searchQuery: _searchController.text.trim(),
        ),
      ),
    );
  }

  /// Limpia el campo de búsqueda
  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  /// Navega al módulo de grifos
  void _navigateToGrifos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GrifosHomeScreen(),
      ),
    );
  }

  /// Cierra la sesión del usuario
  Future<void> _logout() async {
    final shouldLogout = await _showLogoutDialog();
    if (!shouldLogout) return;

    try {
      // Cierre de sesión con Supabase
      if (mounted) {
        _showSuccessSnackBar('Cerrando sesión...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Muestra mensaje de éxito
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmergencyAppBar(
        subtitle: _isLoadingProfile 
            ? null 
            : 'Bienvenido, ${_userProfile?['name'] ?? 'Usuario'}',
        isLoading: _isLoadingProfile,
        onLogoutPressed: _logout,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const EmergencyAlertBanner(),
              SearchSection(
                controller: _searchController,
                onSearch: _searchAddress,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 16),
              GrifosButton(
                onPressed: _navigateToGrifos,
              ),
              const SizedBox(height: 16),
              const QuickGuideSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
