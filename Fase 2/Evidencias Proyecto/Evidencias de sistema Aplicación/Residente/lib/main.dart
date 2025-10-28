import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/reset_password_with_code_screen.dart';
import 'screens/auth/initial_registration_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/registration_steps/registration_flow_screen.dart';
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
    // Mostrar pantalla de error en lugar de continuar
    runApp(
      MaterialApp(
        title: 'FireData - Residente',
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Error de configuración',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el archivo .env\n\n'
                    'Por favor, crea un archivo .env en la raíz del proyecto '
                    'con tus credenciales de Supabase.\n\n'
                    'Ver env_template.txt para más información.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Reiniciar la aplicación
                      main();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireData - Residente',
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
        '/code-reset': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return ResetPasswordWithCodeScreen(
            email: args['email']!,
          );
        },
        '/home': (context) => const ResidentHomeScreen(),
        '/initial-registration': (context) => const InitialRegistrationScreen(),
        '/email-verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return EmailVerificationScreen(
            email: args['email']!,
            password: args['password']!,
          );
        },
        '/registration-steps': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return RegistrationFlowScreen(
            email: args['email']!,
            password: args['password']!,
          );
        },
      },
    );
  }
}

