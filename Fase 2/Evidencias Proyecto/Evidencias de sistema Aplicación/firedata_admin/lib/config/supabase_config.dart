import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Supabase para el Panel Administrativo FireData
/// 
/// IMPORTANTE: Antes de usar, debes:
/// 1. Crear un proyecto en https://supabase.com
/// 2. Ejecutar el script supabase_schema.sql en el SQL Editor
/// 3. Obtener tus credenciales en Settings > API
/// 4. Crear archivo .env con tus credenciales
class SupabaseConfig {
  // Las credenciales se cargan desde el archivo .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'TU_SUPABASE_URL';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'TU_SUPABASE_ANON_KEY';

  static String? get emailRedirectUrl {
    final value = dotenv.env['SUPABASE_EMAIL_REDIRECT'];
    if (value == null || value.isEmpty || value == 'null') return null;
    return value;
  }

  static String? get passwordResetRedirectUrl {
    final value = dotenv.env['SUPABASE_PASSWORD_RESET_REDIRECT'];
    if (value == null || value.isEmpty || value == 'null') return null;
    return value;
  }

  /// Inicializar Supabase
  /// Debe llamarse antes de usar cualquier funcionalidad de Supabase
  static Future<void> initialize() async {
    try {
      // Intentar cargar variables de entorno desde el archivo .env
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        debugPrint('⚠️ Archivo .env no encontrado. Usando valores por defecto.');
        debugPrint('💡 Para configurar Supabase, crea un archivo .env con tus credenciales.');
      }
      
      // Verificar que las credenciales estén configuradas
      if (!isConfigured) {
        debugPrint('⚠️ Credenciales de Supabase no configuradas.');
        debugPrint('💡 Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY.');
        return; // No lanzar excepción, solo mostrar advertencia
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      debugPrint('✅ Supabase inicializado correctamente en FireData Admin');
    } catch (e) {
      debugPrint('❌ Error al inicializar Supabase en FireData Admin: $e');
      // No rethrow para evitar que la app falle completamente
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

