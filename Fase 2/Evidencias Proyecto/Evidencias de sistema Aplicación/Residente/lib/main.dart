import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/home/resident_home.dart';
import 'widgets/auth_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación y UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    // Cargar variables de entorno desde .env
    await dotenv.load(fileName: ".env");
    
    // Inicializar Supabase con las credenciales del .env
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error al inicializar Supabase: $e');
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
      home: const AuthRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/home': (context) => const ResidentHomeScreen(),
      },
    );
  }
}

