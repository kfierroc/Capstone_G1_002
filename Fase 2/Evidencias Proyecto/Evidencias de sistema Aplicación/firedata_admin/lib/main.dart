import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/admin_auth_service.dart';
import 'web_admin/app_shell.dart';

/// Punto de entrada para la versión web administrativa de FireData.
///
/// Este archivo inicializa Supabase, verifica que el usuario tenga rol
/// de administrador y, en caso afirmativo, muestra el panel web.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const FireDataAdminApp());
}

class FireDataAdminApp extends StatelessWidget {
  const FireDataAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireData Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB71C1C),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(
        builder: (context) {
          // En modo debug, permitir acceso directo para desarrollo
          if (kDebugMode) {
            return const AdminAppShell();
          }
          
          // En modo producción, verificar acceso admin
          return FutureBuilder<bool>(
            future: AdminAuthService.instance.verifyAdminAccess(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              if (snapshot.hasData && snapshot.data == true) {
                return const AdminAppShell();
              }
              
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Acceso restringido',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión con una cuenta de administrador.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        if (snapshot.hasError) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
