import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio de autenticación compartido entre las aplicaciones Bomberos y Grifos
/// Usa Supabase para gestionar usuarios en una base de datos común
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
        // Obtener datos adicionales del perfil
        final profile = await _getUserProfile(response.user!.id);
        
        return AuthResult.success(
          UserData(
            id: response.user!.id,
            email: response.user!.email ?? email,
            fullName: profile?['full_name'] ?? '',
            rut: profile?['rut'] ?? '',
            company: profile?['fire_company'] ?? '',
          ),
        );
      } else {
        return AuthResult.error('No se pudo iniciar sesión');
      }
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Registrar nuevo usuario
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rut,
    required String company,
  }) async {
    try {
      // Paso 1: Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Paso 2: Guardar información adicional en la tabla profiles
        try {
          await _client.from('profiles').insert({
            'id': response.user!.id,
            'full_name': fullName.trim(),
            'rut': rut.trim(),
            'fire_company': company.trim(),
            'email': email.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });

          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: email.trim(),
              fullName: fullName.trim(),
              rut: rut.trim(),
              company: company.trim(),
            ),
          );
        } on PostgrestException catch (e) {
          // Si falla al guardar el perfil, eliminar el usuario de Auth
          await _client.auth.signOut();
          return AuthResult.error('Error al guardar el perfil: ${e.message}');
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

  /// Obtener perfil del usuario desde la base de datos
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
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

  /// Actualizar perfil del usuario
  Future<AuthResult> updateProfile({
    required String userId,
    String? fullName,
    String? rut,
    String? company,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (rut != null) updates['rut'] = rut;
      if (company != null) updates['fire_company'] = company;
      
      if (updates.isEmpty) {
        return AuthResult.error('No hay datos para actualizar');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('profiles').update(updates).eq('id', userId);
      
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error('Error al actualizar perfil: ${e.toString()}');
    }
  }
}

/// Clase para representar los datos del usuario
class UserData {
  final String id;
  final String email;
  final String fullName;
  final String rut;
  final String company;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.rut,
    required this.company,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'rut': rut,
    'fire_company': company,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String? ?? '',
    rut: json['rut'] as String? ?? '',
    company: json['fire_company'] as String? ?? '',
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

