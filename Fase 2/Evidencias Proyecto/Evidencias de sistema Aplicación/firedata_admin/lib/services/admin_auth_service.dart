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
  /// Este método verifica primero si el usuario existe en la tabla bombero
  /// y si tiene el campo is_admin en true o 1. También verifica metadatos
  /// y la tabla profiles como métodos alternativos.
  Future<bool> verifyAdminAccess() async {
    try {
      final currentSession = _client.auth.currentSession;
      if (currentSession == null) {
        debugPrint('⚠️ No existe sesión activa al verificar rol admin.');
        return false;
      }

      final user = currentSession.user;

      // 1. Verificar campo is_admin en tabla bombero (PRINCIPAL)
      if (user.email != null) {
        try {
          final bomberoResponse = await _client
              .from('bombero')
              .select('is_admin')
              .eq('email_b', user.email!)
              .maybeSingle();

          if (bomberoResponse != null) {
            final isAdmin = bomberoResponse['is_admin'];
            // Verificar si is_admin es true, 1, o 'true'
            if (isAdmin == true || isAdmin == 1 || isAdmin == 'true' || isAdmin == '1') {
              debugPrint('✅ Usuario tiene acceso admin verificado desde tabla bombero');
              return true;
            } else {
              debugPrint('❌ Usuario NO tiene acceso admin (is_admin: $isAdmin)');
              return false;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error al verificar is_admin en bombero: $e');
        }
      }

      // 2. Revisar metadatos (método alternativo)
      final metadataRoles = user.userMetadata?['roles'];
      if (metadataRoles is List && metadataRoles.contains('admin')) {
        return true;
      }

      // 3. Consultar tabla profiles si existe (método alternativo)
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

