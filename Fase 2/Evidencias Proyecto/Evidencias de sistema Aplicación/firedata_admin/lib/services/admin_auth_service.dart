import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio encargado de validar el acceso al panel web administrativo.
///
/// Reutiliza la configuración global de Supabase y expone métodos para
/// verificar el rol del usuario. Se asume que el rol se mantiene en
/// `user_metadata.roles` o en la tabla `profiles`.
class AdminAuthService {
  AdminAuthService._();

  static final AdminAuthService instance = AdminAuthService._();

  SupabaseClient get _client => SupabaseConfig.client;

  /// Verifica si el usuario autenticado posee un rol de administrador.
  ///
  /// Este método primero intenta obtener los roles desde los metadatos del
  /// usuario (`user_metadata.roles`). En caso de que no exista o no contenga
  /// el rol requerido, consultará la tabla `profiles` buscando un registro
  /// asociado al usuario actual.
  Future<bool> verifyAdminAccess() async {
    try {
      final currentSession = _client.auth.currentSession;
      if (currentSession == null) {
        debugPrint('⚠️ No existe sesión activa al verificar rol admin.');
        return false;
      }

      final user = currentSession.user;

      // 1. Revisar metadatos
      final metadataRoles = user.userMetadata?['roles'];
      if (metadataRoles is List && metadataRoles.contains('admin')) {
        return true;
      }

      // 2. Consultar tabla profiles si existe
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        final role = response['role']?.toString();
        return role == 'admin';
      }
    } catch (e) {
      debugPrint('❌ Error verificando rol admin: $e');
    }
    return false;
  }

  /// Cierra la sesión actual y devuelve al usuario a la pantalla de login.
  Future<void> signOut() => _client.auth.signOut();
}

