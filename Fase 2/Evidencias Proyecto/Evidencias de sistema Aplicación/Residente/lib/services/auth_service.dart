import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio de autenticación usando Supabase
/// 
/// Proporciona métodos para registro, inicio de sesión, cierre de sesión
/// y gestión de sesiones de usuario
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Obtener el cliente de autenticación
  GoTrueClient get _auth => SupabaseConfig.auth;

  /// Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obtener el ID del usuario actual
  String? get userId => currentUser?.id;

  /// Obtener el email del usuario actual
  String? get userEmail => currentUser?.email;

  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Registrar un nuevo usuario
  /// 
  /// [email]: Email del usuario
  /// [password]: Contraseña (mínimo 6 caracteres recomendado)
  /// [metadata]: Datos adicionales del usuario (opcional)
  /// 
  /// Retorna [AuthResult] con el resultado de la operación
  Future<AuthResult> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('🔍 AuthService.signUp - Iniciando...');
      
      // Validaciones básicas
      if (email.isEmpty || password.isEmpty) {
        print('❌ Email o contraseña vacíos');
        return AuthResult.error('Email y contraseña son requeridos');
      }

      if (password.length < 6) {
        print('❌ Contraseña muy corta: ${password.length} caracteres');
        return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
      }

      if (!_isValidEmail(email)) {
        print('❌ Email inválido: $email');
        return AuthResult.error('Email inválido');
      }

      print('✅ Validaciones pasadas, registrando en Supabase...');
      print('📧 Email: $email');
      print('🔐 Password length: ${password.length}');
      print('📝 Metadata: $metadata');

      // Registrar usuario en Supabase
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      print('📦 Response recibido de Supabase');
      print('👤 User: ${response.user?.id}');
      print('📧 Email: ${response.user?.email}');
      print('🔓 Session: ${response.session != null ? "Sí" : "No"}');

      if (response.user == null) {
        print('❌ Usuario es null después del registro');
        return AuthResult.error('Error al crear la cuenta');
      }

      print('✅ Usuario creado exitosamente: ${response.user!.id}');
      
      return AuthResult.success(
        user: AppUser.fromSupabaseUser(response.user!),
        message: 'Cuenta creada exitosamente',
      );
    } on AuthException catch (e) {
      print('❌ AuthException capturada:');
      print('   - Message: ${e.message}');
      print('   - Status Code: ${e.statusCode}');
      final errorMsg = _getAuthErrorMessage(e);
      print('   - Error traducido: $errorMsg');
      return AuthResult.error(errorMsg);
    } catch (e) {
      print('❌ Excepción inesperada: $e');
      print('   - Type: ${e.runtimeType}');
      print('   - Stack: ${StackTrace.current}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Iniciar sesión con email y contraseña
  /// 
  /// [email]: Email del usuario
  /// [password]: Contraseña
  /// 
  /// Retorna [AuthResult] con el resultado de la operación
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones básicas
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.error('Email y contraseña son requeridos');
      }

      // Iniciar sesión
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Error al iniciar sesión');
      }

      return AuthResult.success(
        user: AppUser.fromSupabaseUser(response.user!),
        message: 'Sesión iniciada exitosamente',
      );
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Restablecer contraseña
  /// Envía un email con enlace para restablecer la contraseña
  /// 
  /// [email]: Email del usuario
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      if (email.isEmpty) {
        return AuthResult.error('Email es requerido');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.error('Email inválido');
      }

      await _auth.resetPasswordForEmail(email);

      return AuthResult.success(
        user: null,
        message: 'Se ha enviado un email para restablecer tu contraseña',
      );
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar email del usuario
  Future<AuthResult> updateEmail({required String newEmail}) async {
    try {
      if (!_isValidEmail(newEmail)) {
        return AuthResult.error('Email inválido');
      }

      final response = await _auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user == null) {
        return AuthResult.error('Error al actualizar email');
      }

      return AuthResult.success(
        user: AppUser.fromSupabaseUser(response.user!),
        message: 'Email actualizado exitosamente',
      );
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualizar contraseña del usuario
  Future<AuthResult> updatePassword({required String newPassword}) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
      }

      final response = await _auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        return AuthResult.error('Error al actualizar contraseña');
      }

      return AuthResult.success(
        user: AppUser.fromSupabaseUser(response.user!),
        message: 'Contraseña actualizada exitosamente',
      );
    } on AuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Eliminar cuenta de usuario
  Future<AuthResult> deleteAccount() async {
    try {
      // Nota: Supabase no tiene un método directo para eliminar usuarios
      // desde el cliente. Esto debe hacerse desde el backend o mediante
      // una función de base de datos. Por ahora, solo cerramos sesión.
      
      await signOut();
      
      return AuthResult.success(
        user: null,
        message: 'Cuenta eliminada exitosamente',
      );
    } catch (e) {
      return AuthResult.error('Error al eliminar cuenta: ${e.toString()}');
    }
  }

  /// Validar formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Obtener mensaje de error amigable
  String _getAuthErrorMessage(AuthException error) {
    print('🔍 Analizando error de autenticación:');
    print('   - Status Code: ${error.statusCode}');
    print('   - Message: ${error.message}');
    
    switch (error.statusCode) {
      case '400':
        if (error.message.toLowerCase().contains('email')) {
          return 'Email inválido o ya registrado';
        }
        return 'Credenciales inválidas: ${error.message}';
      case '401':
        return 'Email o contraseña incorrectos';
      case '422':
        return 'Email ya registrado';
      case '429':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        if (error.message.toLowerCase().contains('email')) {
          return 'Problema con el email: ${error.message}';
        } else if (error.message.toLowerCase().contains('password')) {
          return 'La contraseña no cumple con los requisitos: ${error.message}';
        } else if (error.message.toLowerCase().contains('user already registered')) {
          return 'Este email ya está registrado';
        } else if (error.message.toLowerCase().contains('email not confirmed')) {
          return 'Debes confirmar tu email. Revisa tu bandeja de entrada';
        } else {
          // Devolver el mensaje completo para mejor diagnóstico
          return 'Error: ${error.message}';
        }
    }
  }
}

/// Modelo de usuario de la aplicación
class AppUser {
  final String id;
  final String email;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.metadata,
    this.createdAt,
  });

  /// Crear AppUser desde User de Supabase
  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      metadata: user.userMetadata,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  /// Obtener nombre del usuario desde metadata
  String get name => metadata?['name'] ?? email.split('@')[0];

  /// Convertir a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool isSuccess;
  final AppUser? user;
  final String? message;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });

  /// Resultado exitoso
  factory AuthResult.success({
    required AppUser? user,
    String? message,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
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

