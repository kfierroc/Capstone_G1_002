import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login.dart';
import 'screens/home/resident_home.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación y UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Supabase
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    print('Error al inicializar Supabase: $e');
    // Continuar la ejecución incluso si falla
    // (útil durante desarrollo antes de configurar credenciales)
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Residentes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        // Optimización: Reducir animaciones innecesarias
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
        ),
      ),
      home: _AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const ResidentHomeScreen(),
      },
    );
  }
}

// Verifica si el usuario ya está autenticado
class _AuthChecker extends StatelessWidget {
  const _AuthChecker();

  @override
  Widget build(BuildContext context) {
    // Usar StreamBuilder para escuchar cambios de autenticación
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Mientras carga, mostrar splash screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Si hay sesión activa, ir a home
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return const ResidentHomeScreen();
        }
        
        // Si no hay sesión, mostrar login
        return const LoginScreen();
      },
    );
  }
}
