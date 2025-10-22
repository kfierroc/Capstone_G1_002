import 'package:flutter/material.dart';
import '../../app.dart';
import '../auth/login.dart';
import 'search_results_refactored.dart';
import '../grifos/grifos_home_screen.dart';

/// Pantalla principal del sistema de emergencias - Versión definitiva
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    // Usar WidgetsBinding para asegurar que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Extrae el nombre del email de forma más inteligente
  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'Usuario';
    
    // Remover el dominio del email
    final emailPart = email.split('@').first;
    
    // Si contiene puntos, tomar la primera parte como nombre
    if (emailPart.contains('.')) {
      final parts = emailPart.split('.');
      // Tomar la primera parte y capitalizarla
      return parts.first.isNotEmpty 
          ? '${parts.first[0].toUpperCase()}${parts.first.substring(1).toLowerCase()}'
          : 'Usuario';
    }
    
    // Si no contiene puntos, usar todo el texto antes del @
    return emailPart.isNotEmpty 
        ? '${emailPart[0].toUpperCase()}${emailPart.substring(1).toLowerCase()}'
        : 'Usuario';
  }

  /// Carga el perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      final authService = SupabaseAuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        // Obtener información del bombero desde la base de datos
        final bombero = await authService.getCurrentUserBombero();
        
         final profile = <String, dynamic>{
           'email': currentUser.email ?? 'usuario@ejemplo.com',
           'name': _extractNameFromEmail(currentUser.email ?? ''),
           'cargo': 'Voluntario',
           'rut': bombero?.rutCompleto ?? 'Sin RUT',
         };
        
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoadingProfile = false;
          });
        }
      } else {
        // Si no hay usuario autenticado, redirigir al login
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
        // Usar un delay más largo para asegurar que el contexto esté disponible
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showErrorSnackBar('Error al cargar perfil: ${e.toString()}');
          }
        });
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
      final authService = SupabaseAuthService();
      await authService.signOut();
      
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

  /// Muestra mensaje de error de forma segura
  void _showErrorSnackBar(String message) {
    // Verificar que el widget esté montado y el contexto sea válido
    if (!mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      // Si hay error con ScaffoldMessenger, usar un enfoque alternativo
      debugPrint('Error al mostrar SnackBar: $e');
      // Podríamos usar un diálogo o simplemente loggear el error
    }
  }

  /// Muestra mensaje de éxito de forma segura
  void _showSuccessSnackBar(String message) {
    // Verificar que el widget esté montado y el contexto sea válido
    if (!mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      // Si hay error con ScaffoldMessenger, usar un enfoque alternativo
      debugPrint('Error al mostrar SnackBar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmergencyAppBar(
        subtitle: _isLoadingProfile 
            ? null 
            : 'Bienvenido, ${_userProfile?['cargo'] ?? 'Usuario'} ${_userProfile?['name'] ?? 'Usuario'}',
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
