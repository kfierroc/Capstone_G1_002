import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Supabase para el Sistema de Grifos
/// 
/// IMPORTANTE: Antes de usar, debes:
/// 1. Crear un proyecto en https://supabase.com
/// 2. Ejecutar el script supabase_schema.sql en el SQL Editor
/// 3. Obtener tus credenciales en Settings > API
/// 4. Crear archivo .env con tus credenciales (ver env_template.txt)
class SupabaseConfig {
  // Las credenciales se cargan desde el archivo .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'TU_SUPABASE_URL';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'TU_SUPABASE_ANON_KEY';

  /// Inicializar Supabase
  /// Debe llamarse antes de usar cualquier funcionalidad de Supabase
  static Future<void> initialize() async {
    try {
      // Cargar variables de entorno desde el archivo .env
      await dotenv.load(fileName: ".env");
      
      // Verificar que las credenciales estén configuradas
      if (!isConfigured) {
        throw Exception(
          'Credenciales de Supabase no configuradas. '
          'Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY. '
          'Ver env_template.txt para más información.'
        );
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      print('✅ Supabase inicializado correctamente en Grifos');
    } catch (e) {
      print('❌ Error al inicializar Supabase en Grifos: $e');
      rethrow;
    }
  }

  /// Obtener el cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Obtener el cliente de autenticación
  static GoTrueClient get auth => client.auth;
  
  /// Verificar si Supabase está configurado correctamente
  static bool get isConfigured {
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    
    return url != null && 
           key != null && 
           url.isNotEmpty && 
           key.isNotEmpty &&
           url != 'TU_SUPABASE_URL' && 
           key != 'TU_SUPABASE_ANON_KEY';
  }
}