import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login.dart';
import 'screens/home/home.dart';

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
