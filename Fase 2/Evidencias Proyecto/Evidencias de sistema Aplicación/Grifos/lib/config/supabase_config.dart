import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Cargar credenciales desde .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Inicializar Supabase
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Las credenciales de Supabase no están configuradas. '
        'Por favor, crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY',
      );
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Obtener cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
