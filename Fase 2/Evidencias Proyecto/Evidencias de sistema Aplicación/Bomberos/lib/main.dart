import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login.dart';
import 'screens/home/home.dart';
import 'services/mock_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase (comentado temporalmente para pruebas)
  // await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Emergencias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      // Usar AuthChecker temporal para pruebas
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Verifica si el usuario ya está autenticado (versión temporal)
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  Widget build(BuildContext context) {
    final mockAuth = MockAuthService();

    if (mockAuth.isAuthenticated) {
      // Usuario autenticado -> Ir a Home
      return const HomeScreen();
    } else {
      // Usuario no autenticado -> Ir a Login
      return const LoginScreen();
    }
  }
}
