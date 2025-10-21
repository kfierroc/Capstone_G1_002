import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio unificado de autenticación que maneja el estado de forma consistente
/// 
/// Este servicio centraliza todo el manejo de autenticación y asegura que
/// el estado esté sincronizado en toda la aplicación.
class UnifiedAuthService {
  static final UnifiedAuthService _instance = UnifiedAuthService._internal();
  factory UnifiedAuthService() => _instance;
  UnifiedAuthService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  // Obtener el usuario actual
  User? get currentUser => _client.auth.currentUser;
  
  // Verificar si hay usuario autenticado
  bool get isAuthenticated => currentUser != null;

  // Obtener el email del usuario actual
  String? get userEmail => currentUser?.email;

  // Obtener el ID del usuario actual
  String? get userId => currentUser?.id;

  // Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Registrar nuevo grupo familiar con Supabase Auth
  Future<AuthResult> signUpGrupoFamiliar({
    required String email,
    required String password,
    required String rutTitular,
  }) async {
    try {
      debugPrint('🔐 UnifiedAuthService.signUpGrupoFamiliar - Iniciando...');
      debugPrint('📧 Email: $email');
      debugPrint('🆔 RUT Titular: $rutTitular');

      // Paso 1: Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: null, // Deshabilitar confirmación de email para pruebas
      );

      if (response.user != null) {
        debugPrint('✅ Usuario creado en Supabase Auth: ${response.user!.id}');
        
        // Paso 2: Guardar información en la tabla grupofamiliar
        try {
          final grupoFamiliarData = {
            'rut_titular': rutTitular.trim(),
            'email': email.trim(),
            'auth_user_id': response.user!.id,
            'fecha_creacion': DateTime.now().toIso8601String(),
          };

          final grupoFamiliarResponse = await _client
              .from('grupofamiliar')
              .insert(grupoFamiliarData)
              .select()
              .single();

          final grupoFamiliar = GrupoFamiliar.fromJson(grupoFamiliarResponse);
          debugPrint('✅ Grupo familiar creado: ${grupoFamiliar.idGrupof}');

          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: email.trim(),
              rutTitular: rutTitular.trim(),
              grupoFamiliar: grupoFamiliar,
            ),
          );
        } on PostgrestException catch (e) {
          debugPrint('❌ Error al guardar grupo familiar: ${e.message}');
          // NO cerrar sesión automáticamente, solo reportar el error
          return AuthResult.error('Error al guardar el grupo familiar: ${e.message}');
        }
      } else {
        debugPrint('❌ No se pudo crear el usuario');
        return AuthResult.error('No se pudo crear el usuario');
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en signUpGrupoFamiliar: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en signUpGrupoFamiliar: $e');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 UnifiedAuthService.signInWithPassword - Iniciando...');
      debugPrint('📧 Email: $email');

      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ Usuario autenticado: ${response.user!.id}');
        
        // Obtener datos del grupo familiar
        final grupoFamiliar = await _getGrupoFamiliarByAuthUserId(response.user!.id);
        
        if (grupoFamiliar != null) {
          debugPrint('✅ Grupo familiar encontrado: ${grupoFamiliar.idGrupof}');
          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: response.user!.email ?? email,
              rutTitular: grupoFamiliar.rutTitular,
              grupoFamiliar: grupoFamiliar,
            ),
          );
        } else {
          debugPrint('⚠️ No se encontró grupo familiar para el usuario, pero permitiendo login');
          debugPrint('   - Esto puede ocurrir si el usuario fue creado antes de implementar auth_user_id');
          debugPrint('   - El usuario puede continuar y se creará el grupo familiar si es necesario');
          
          // NO desloguear al usuario, permitir que continúe
          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: response.user!.email ?? email,
              rutTitular: 'Sin RUT', // Valor por defecto
              grupoFamiliar: null, // Se creará cuando sea necesario
            ),
          );
        }
      } else {
        debugPrint('❌ No se pudo iniciar sesión');
        return AuthResult.error('No se pudo iniciar sesión');
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en signInWithPassword: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en signInWithPassword: $e');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      debugPrint('🔐 UnifiedAuthService.signOut - Cerrando sesión...');
      await _client.auth.signOut();
      debugPrint('✅ Sesión cerrada exitosamente');
    } catch (e) {
      debugPrint('❌ Error al cerrar sesión: $e');
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Recuperar contraseña
  Future<AuthResult> resetPassword(String email) async {
    try {
      debugPrint('🔐 UnifiedAuthService.resetPassword - Enviando email...');
      await _client.auth.resetPasswordForEmail(email.trim());
      debugPrint('✅ Email de recuperación enviado');
      return AuthResult.success(null);
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en resetPassword: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en resetPassword: $e');
      return AuthResult.error('Error al enviar email: ${e.toString()}');
    }
  }

  /// Obtener grupo familiar del usuario autenticado
  Future<GrupoFamiliar?> getCurrentUserGrupoFamiliar() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ No hay usuario autenticado');
        return null;
      }
      
      debugPrint('🔍 Buscando grupo familiar para usuario: ${user.id}');
      return await _getGrupoFamiliarByAuthUserId(user.id);
    } catch (e) {
      debugPrint('❌ Error al obtener grupo familiar: $e');
      return null;
    }
  }

  /// Obtener grupo familiar por auth_user_id
  Future<GrupoFamiliar?> _getGrupoFamiliarByAuthUserId(String authUserId) async {
    try {
      debugPrint('🔍 Buscando grupo familiar por auth_user_id: $authUserId');
      
      // Primero intentar buscar por auth_user_id
      try {
        final response = await _client
            .from('grupofamiliar')
            .select()
            .eq('auth_user_id', authUserId)
            .single();
        
        debugPrint('✅ Grupo familiar encontrado por auth_user_id');
        return GrupoFamiliar.fromJson(response);
      } catch (e) {
        debugPrint('⚠️ No se encontró grupo familiar por auth_user_id: $e');
        
        // Si no se encuentra por auth_user_id, intentar buscar por email
        final user = _client.auth.currentUser;
        if (user?.email != null) {
          debugPrint('🔍 Intentando buscar por email: ${user!.email}');
          try {
            final response = await _client
                .from('grupofamiliar')
                .select()
                .eq('email', user.email!)
                .single();
            
            debugPrint('✅ Grupo familiar encontrado por email');
            
            // Actualizar el registro con el auth_user_id para futuras consultas
            await _client
                .from('grupofamiliar')
                .update({'auth_user_id': authUserId})
                .eq('email', user.email!);
            
            debugPrint('✅ auth_user_id actualizado en el grupo familiar');
            return GrupoFamiliar.fromJson(response);
          } catch (e) {
            debugPrint('⚠️ No se encontró grupo familiar por email: $e');
          }
        }
      }
      
      debugPrint('❌ No se encontró grupo familiar por ningún método');
      return null;
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener grupo familiar: $e');
      return null;
    }
  }

  /// Actualizar información del grupo familiar
  Future<AuthResult> updateGrupoFamiliar({
    required String rutTitular,
    String? email,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult.error('Usuario no autenticado');
      }

      final updates = <String, dynamic>{
        'rut_titular': rutTitular.trim(),
      };

      if (email != null && email.trim().isNotEmpty) {
        updates['email'] = email.trim();
      }

      await _client
          .from('grupofamiliar')
          .update(updates)
          .eq('auth_user_id', user.id);

      // Obtener datos actualizados
      final grupoFamiliar = await _getGrupoFamiliarByAuthUserId(user.id);
      
      return AuthResult.success(
        UserData(
          id: user.id,
          email: user.email ?? email ?? '',
          rutTitular: rutTitular,
          grupoFamiliar: grupoFamiliar,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error al actualizar grupo familiar: $e');
      return AuthResult.error('Error al actualizar grupo familiar: ${e.toString()}');
    }
  }

  /// Verificar si la sesión es válida
  Future<bool> isSessionValid() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      // Verificar si el token no ha expirado
      final session = _client.auth.currentSession;
      if (session == null) return false;
      
      // Verificar si el token expira en menos de 5 minutos
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      
      return expiresAt > now + 300; // 5 minutos de margen
    } catch (e) {
      debugPrint('❌ Error al verificar sesión: $e');
      return false;
    }
  }

  /// Refrescar sesión si es necesario
  Future<void> refreshSessionIfNeeded() async {
    try {
      final isValid = await isSessionValid();
      if (!isValid) {
        debugPrint('🔄 Refrescando sesión...');
        await _client.auth.refreshSession();
        debugPrint('✅ Sesión refrescada');
      }
    } catch (e) {
      debugPrint('❌ Error al refrescar sesión: $e');
      // Si no se puede refrescar, cerrar sesión
      await signOut();
    }
  }

  /// Traducir errores comunes de Supabase al español
  String _translateAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Credenciales incorrectas. Verifica tu email y contraseña.';
    } else if (error.contains('User already registered')) {
      return 'Este correo electrónico ya está registrado.';
    } else if (error.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    } else if (error.contains('Invalid email')) {
      return 'El correo electrónico no es válido.';
    } else if (error.contains('Email not confirmed')) {
      return 'Por favor, confirma tu correo electrónico.';
    } else if (error.contains('User not found')) {
      return 'Usuario no encontrado.';
    }
    return error;
  }
}

/// Clase para representar los datos del usuario
class UserData {
  final String id;
  final String email;
  final String rutTitular;
  final GrupoFamiliar? grupoFamiliar;

  UserData({
    required this.id,
    required this.email,
    required this.rutTitular,
    this.grupoFamiliar,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'rut_titular': rutTitular,
    'grupo_familiar': grupoFamiliar?.toJson(),
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'] as String,
    email: json['email'] as String,
    rutTitular: json['rut_titular'] as String,
    grupoFamiliar: json['grupo_familiar'] != null 
        ? GrupoFamiliar.fromJson(json['grupo_familiar'] as Map<String, dynamic>)
        : null,
  );
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool isSuccess;
  final UserData? data;
  final String? message;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });

  /// Resultado exitoso
  factory AuthResult.success(UserData? data, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  /// Resultado con error
  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
