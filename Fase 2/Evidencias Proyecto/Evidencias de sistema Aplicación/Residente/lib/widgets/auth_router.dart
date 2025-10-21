import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login.dart';
import '../screens/home/resident_home.dart';
import '../services/unified_auth_service.dart';

/// Widget que maneja las rutas de autenticación usando el servicio unificado
///
/// Este componente asegura que el estado de autenticación esté sincronizado
/// en toda la aplicación y maneja correctamente los cambios de estado.
class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  final UnifiedAuthService _authService = UnifiedAuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Inicializar el estado de autenticación
  Future<void> _initializeAuth() async {
    try {
      debugPrint('🔐 AuthRouter - Inicializando estado de autenticación...');

      // Solo verificar si hay una sesión válida, sin refrescar automáticamente
      final isValid = await _authService.isSessionValid();
      debugPrint(
        '✅ Estado de sesión verificado: ${isValid ? "Válida" : "Inválida"}',
      );

      setState(() {
        _isInitialized = true;
      });

      debugPrint('✅ AuthRouter inicializado');
    } catch (e) {
      debugPrint('❌ Error al inicializar AuthRouter: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando aplicación...'),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<AuthState>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando autenticación...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ Error en AuthRouter: ${snapshot.error}');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error de autenticación'),
                  SizedBox(height: 8),
                  Text('Por favor, reinicia la aplicación'),
                ],
              ),
            ),
          );
        }

        final authState = snapshot.data;
        final session = authState?.session;
        final event = authState?.event;

        // Solo mostrar logs para eventos importantes
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.signedOut) {
          debugPrint('🔐 AuthRouter - Evento: $event');
          debugPrint('   - Sesión: ${session != null ? "Activa" : "Inactiva"}');
          debugPrint('   - Usuario: ${session?.user.id ?? "Ninguno"}');
        }

        // Manejar eventos específicos
        if (event == AuthChangeEvent.passwordRecovery) {
          debugPrint('🔄 Redirigiendo a reset password...');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/reset-password');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay sesión activa, mostrar home
        if (session != null && _authService.isAuthenticated) {
          debugPrint('✅ Usuario autenticado, mostrando home');
          return const ResidentHomeScreen();
        }

        // Si no hay sesión, mostrar login
        debugPrint('❌ Usuario no autenticado, mostrando login');
        return const LoginScreen();
      },
    );
  }
}
