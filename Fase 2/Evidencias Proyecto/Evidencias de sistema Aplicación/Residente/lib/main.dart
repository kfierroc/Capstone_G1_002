import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/login.dart';
import 'screens/home/resident_home.dart';
import 'services/mock_auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimización: Configurar orientación y UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Emergencias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        // Optimización: Reducir animaciones innecesarias
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
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

// Verifica si el usuario ya está autenticado (optimizado)
class _AuthChecker extends StatelessWidget {
  const _AuthChecker();

  @override
  Widget build(BuildContext context) {
    final mockAuth = MockAuthService();
    return mockAuth.isAuthenticated 
        ? const ResidentHomeScreen()
        : const LoginScreen();
  }
}
