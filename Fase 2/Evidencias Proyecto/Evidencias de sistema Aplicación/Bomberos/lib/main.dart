import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
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
    
    // Configurar listener para manejar deep links de verificación de email y reset de contraseña
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      debugPrint('📱 Evento de autenticación: $event');
      
      // Detectar cuando se abre el enlace de reset de contraseña
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔄 Evento de recuperación de contraseña detectado');
        if (session != null && session.user.email != null) {
          debugPrint('✅ Email encontrado: ${session.user.email}');
          // La navegación se manejará en AuthChecker o en la pantalla actual
        }
      }
      
      // Detectamos cuando se verifica el email o se confirma el registro
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
        debugPrint('✅ Usuario autenticado o actualizado');
      }
    });

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
    // Usar StreamBuilder para escuchar cambios en el estado de autenticación
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        final event = snapshot.data?.event;

        // Manejar evento de recuperación de contraseña
        if (event == AuthChangeEvent.passwordRecovery && session != null) {
          // Navegar a la pantalla de reset de contraseña con el email
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/code-reset',
                arguments: session.user.email,
              );
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay sesión activa, mostrar home
        if (session != null) {
          return const HomeScreen();
        }

        // Si no hay sesión, mostrar login
        return const LoginScreen();
      },
    );
  }
}
