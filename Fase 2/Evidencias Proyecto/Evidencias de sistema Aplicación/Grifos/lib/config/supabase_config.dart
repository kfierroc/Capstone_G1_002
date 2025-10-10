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
