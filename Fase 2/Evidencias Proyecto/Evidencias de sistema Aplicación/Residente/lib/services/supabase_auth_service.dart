import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio de autenticación para el proyecto Residente
/// Maneja el registro y login usando Supabase Auth con la tabla grupofamiliar
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  // Obtener cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  // Obtener el usuario actual
  User? get currentUser => _client.auth.currentUser;
  
  // Verificar si hay usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// Registrar nuevo grupo familiar con Supabase Auth
  Future<AuthResult> signUpGrupoFamiliar({
    required String email,
    required String password,
    required String rutTitular,
  }) async {
    try {
      // Paso 1: Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
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

          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: email.trim(),
              rutTitular: rutTitular.trim(),
              grupoFamiliar: grupoFamiliar,
            ),
          );
        } on PostgrestException catch (e) {
          // Si falla al guardar el grupo familiar, eliminar el usuario de Auth
          await _client.auth.signOut();
          return AuthResult.error('Error al guardar el grupo familiar: ${e.message}');
        }
      } else {
        return AuthResult.error('No se pudo crear el usuario');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Obtener datos del grupo familiar
        final grupoFamiliar = await _getGrupoFamiliarByAuthUserId(response.user!.id);
        
        if (grupoFamiliar != null) {
          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: response.user!.email ?? email,
              rutTitular: grupoFamiliar.rutTitular,
              grupoFamiliar: grupoFamiliar,
            ),
          );
        } else {
          await _client.auth.signOut();
          return AuthResult.error('No se encontró información del grupo familiar');
        }
      } else {
        return AuthResult.error('No se pudo iniciar sesión');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Recuperar contraseña
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error al enviar email: ${e.toString()}');
    }
  }

  /// Obtener grupo familiar del usuario autenticado
  Future<GrupoFamiliar?> getCurrentUserGrupoFamiliar() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      
      return await _getGrupoFamiliarByAuthUserId(user.id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener grupo familiar por auth_user_id
  Future<GrupoFamiliar?> _getGrupoFamiliarByAuthUserId(String authUserId) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .select()
          .eq('auth_user_id', authUserId)
          .single();
      
      return GrupoFamiliar.fromJson(response);
    } catch (e) {
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
      return AuthResult.error('Error al actualizar grupo familiar: ${e.toString()}');
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

/// Clase para representar el resultado de operaciones de autenticación
class AuthResult {
  final bool isSuccess;
  final UserData? user;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory AuthResult.success(UserData? user) => AuthResult._(
    isSuccess: true,
    user: user,
  );

  factory AuthResult.error(String error) => AuthResult._(
    isSuccess: false,
    error: error,
  );
}
