import '../config/supabase_config.dart';

/// Servicio para manejar la lógica de perfil de usuario
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  /// Carga el perfil del usuario desde Supabase
  Future<Map<String, dynamic>?> loadUserProfile() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return null;

      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      // Log error in production
      // ignore: avoid_print
      print('Error loading user profile: $e');
      return null;
    }
  }

  /// Obtiene el nombre completo del usuario
  String getUserDisplayName(Map<String, dynamic>? profile) {
    if (profile == null) return 'Bombero';
    return profile['full_name'] ?? 'Bombero';
  }

  /// Verifica si el usuario está autenticado
  bool isUserAuthenticated() {
    return SupabaseConfig.client.auth.currentUser != null;
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    await SupabaseConfig.client.auth.signOut();
  }
}
