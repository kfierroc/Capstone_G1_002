import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login.dart';
import '../screens/home/resident_home.dart';

/// Widget que maneja las rutas de autenticación de Supabase
/// Incluye manejo de deep links para reset password
class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  @override
  void initState() {
    super.initState();
    _handleInitialRoute();
  }

  /// Maneja la ruta inicial cuando la app se abre
  void _handleInitialRoute() {
    // Escuchar cambios en la URL para manejar deep links
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        // Usuario viene del link de reset password
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/reset-password');
        }
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        // Usuario autenticado exitosamente
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Usuario cerró sesión
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final authState = snapshot.data;
        final session = authState?.session;

        // Si hay sesión activa, mostrar home
        if (session != null) {
          return const ResidentHomeScreen();
        }

        // Si no hay sesión, mostrar login
        return const LoginScreen();
      },
    );
  }
}
