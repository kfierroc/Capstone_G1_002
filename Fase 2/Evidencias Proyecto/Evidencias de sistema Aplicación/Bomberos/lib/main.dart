import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'screens/auth/login.dart';
import 'screens/auth/password.dart';
import 'screens/auth/reset_password_with_code_screen.dart';
import 'screens/auth/register_step1.dart';
import 'screens/auth/register_step2.dart';
import 'screens/auth/register_step3.dart';
import 'screens/home/home_main.dart';
import 'screens/grifos/grifos_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar variables de entorno desde .env
    await dotenv.load(fileName: ".env");

    // Inicializar Supabase con las credenciales del .env
    await SupabaseConfig.initialize();

    runApp(const MyApp());
  } catch (e) {
    // Si hay error al cargar .env, mostrar mensaje de error
    runApp(
      MaterialApp(
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
                  Text(
                    'No se pudo cargar el archivo .env\n\n'
                    'Por favor, crea un archivo .env en la raíz del proyecto '
                    'con tus credenciales de Supabase.\n\n'
                    'Error: ${e.toString()}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireData - Bomberos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forzar tema claro
      // Usar AuthChecker temporal para pruebas
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/code-reset': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return ResetPasswordWithCodeScreen(email: email);
        },
        '/register-step1': (context) => const RegisterStepInputScreen(),
        '/register-step2': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RegisterStep2VerificationScreen(
            email: args['email'] as String,
            password: args['password'] as String,
          );
        },
        '/register-step3': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RegisterStep3CompletionScreen(
            email: args['email'] as String,
            password: args['password'] as String,
          );
        },
        '/email-verification-bomberos': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return RegisterStep2VerificationScreen(
            email: args['email'] as String,
            password: args['password'] as String,
          );
        },
        '/home': (context) => const HomeScreen(),
        '/grifos': (context) => const GrifosHomeScreen(),
      },
    );
  }
}

// Verifica si el usuario ya está autenticado
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  Widget build(BuildContext context) {
    // Verificar si hay una sesión activa en Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Usuario autenticado -> Ir a Home
      return const HomeScreen();
    } else {
      // Usuario no autenticado -> Ir a Login
      return const LoginScreen();
    }
  }
}
