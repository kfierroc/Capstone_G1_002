// Archivo desactivado temporalmente mientras no se usa Supabase
// Para activarlo:
// 1. Descomenta supabase_flutter en pubspec.yaml
// 2. Ejecuta: flutter pub get
// 3. Descomenta el código de abajo
// 4. Agrega tus credenciales de Supabase

/*
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Reemplaza con tus credenciales de Supabase
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';

  // Inicializar Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Obtener cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
*/

// Versión temporal sin dependencias (mientras se usa MockAuthService)
class SupabaseConfig {
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';

  // Mock - no hace nada por ahora
  static Future<void> initialize() async {
    // Cuando actives Supabase, descomenta el código de arriba
    await Future.delayed(Duration.zero);
  }
}
