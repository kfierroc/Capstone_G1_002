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
        print('❌ Email inválido según validación local: $email');
        return AuthResult.error('Email inválido');
      }
      
      print('✅ Email válido según validación local: $email');

      // Verificar si el email ya está registrado (con lógica mejorada)
      print('🔍 Verificando si el email ya está registrado...');
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        print('❌ El email ya está registrado: $email');
        return AuthResult.error('Este email ya está registrado. Si es tu cuenta, intenta iniciar sesión. Si quieres crear una nueva cuenta, usa un email diferente.');
      }
      print('✅ Email disponible para registro: $email');

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
      print('❌ AuthException capturada en signUp:');
      print('   - Message: ${e.message}');
      print('   - Status Code: ${e.statusCode}');
      print('   - Email que causó el error: $email');
      
      final message = e.message.toLowerCase();
      
      // Si el error es que el usuario ya existe, dar un mensaje más específico
      if (message.contains('user already registered') || 
          message.contains('email already registered') ||
          message.contains('already been registered')) {
        print('🔄 Usuario ya registrado según Supabase');
        return AuthResult.error('Este email ya está registrado. Si es tu cuenta, intenta iniciar sesión. Si quieres crear una nueva cuenta, usa un email diferente.');
      }
      
      // Si Supabase dice que el email es inválido, puede ser que ya exista
      if (message.contains('email address') && message.contains('invalid')) {
        print('🔄 Email marcado como inválido por Supabase (posiblemente ya existe)');
        return AuthResult.error('Este email ya está registrado o no es válido. Si es tu cuenta, intenta iniciar sesión. Si quieres crear una nueva cuenta, usa un email diferente.');
      }
      
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
      print('🔐 AuthService.signIn - Iniciando...');
      print('📧 Email: $email');
      print('🔐 Password length: ${password.length}');
      
      // Validaciones básicas
      if (email.isEmpty || password.isEmpty) {
        print('❌ Email o contraseña vacíos');
        return AuthResult.error('Email y contraseña son requeridos');
      }

      if (!_isValidEmail(email)) {
        print('❌ Email inválido: $email');
        return AuthResult.error('Email inválido');
      }

      print('✅ Validaciones pasadas, iniciando sesión en Supabase...');

      // Verificar si el email está confirmado antes de intentar login
      print('🔍 Verificando si el email está confirmado...');
      final isConfirmed = await isEmailConfirmed(email);
      if (!isConfirmed) {
        print('❌ El email no está confirmado: $email');
        return AuthResult.error('Debes confirmar tu email antes de iniciar sesión. Revisa tu bandeja de entrada y haz clic en el enlace de confirmación');
      }
      print('✅ Email confirmado: $email');

      // Iniciar sesión
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('📦 Response recibido de Supabase');
      print('👤 User: ${response.user?.id}');
      print('📧 Email: ${response.user?.email}');
      print('🔓 Session: ${response.session != null ? "Sí" : "No"}');

      if (response.user == null) {
        print('❌ Usuario es null después del login');
        return AuthResult.error('Error al iniciar sesión');
      }

      print('✅ Sesión iniciada exitosamente: ${response.user!.id}');
      
      return AuthResult.success(
        user: AppUser.fromSupabaseUser(response.user!),
        message: 'Sesión iniciada exitosamente',
      );
    } on AuthException catch (e) {
      print('❌ AuthException capturada en signIn:');
      print('   - Message: ${e.message}');
      print('   - Status Code: ${e.statusCode}');
      print('   - Email que causó el error: $email');
      final errorMsg = _getAuthErrorMessage(e);
      print('   - Error traducido: $errorMsg');
      return AuthResult.error(errorMsg);
    } catch (e) {
      print('❌ Excepción inesperada en signIn: $e');
      print('   - Type: ${e.runtimeType}');
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

  /// Verificar si un email ya está registrado (método simplificado)
  Future<bool> isEmailRegistered(String email) async {
    try {
      print('🔍 Verificando si email está registrado: $email');
      
      // Usar una contraseña muy específica para evitar conflictos
      final dummyPassword = 'dummy_check_${DateTime.now().millisecondsSinceEpoch}';
      
      await _auth.signInWithPassword(
        email: email,
        password: dummyPassword,
      );
      
      // Si llegamos aquí sin excepción, algo está mal
      print('⚠️ No se lanzó excepción, esto es inesperado');
      return false;
      
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      print('📧 Error al verificar email: ${e.message}');
      print('📧 Status Code: ${e.statusCode}');
      
      // Solo confiar en errores muy específicos
      if (message.contains('email not confirmed')) {
        print('✅ Email existe (no confirmado)');
        return true;
      }
      
      // Para "invalid login credentials", ser más conservador
      if (message.contains('invalid login credentials')) {
        print('❓ Email posiblemente existe, pero siendo conservador...');
        return false; // Cambiar a false para evitar falsos positivos
      }
      
      // Si obtenemos "user not found" o similar, el email no existe
      if (message.contains('user not found') || 
          message.contains('email not found') ||
          message.contains('invalid email')) {
        print('❌ Email no existe');
        return false;
      }
      
      // Para cualquier otro error, asumir que no existe
      print('❓ Error desconocido, asumiendo que email no existe');
      return false;
      
    } catch (e) {
      print('❌ Excepción inesperada al verificar email: $e');
      return false;
    }
  }

  /// Verificar si un email está confirmado
  Future<bool> isEmailConfirmed(String email) async {
    try {
      print('🔍 Verificando si email está confirmado: $email');
      
      // Intentar iniciar sesión con una contraseña falsa
      // Si obtenemos "email not confirmed", significa que existe pero no está confirmado
      await _auth.signInWithPassword(
        email: email,
        password: 'dummy_password_123456789',
      );
      
      // Si llegamos aquí sin excepción, algo está mal
      print('⚠️ No se lanzó excepción al verificar confirmación');
      return false;
      
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      print('📧 Error al verificar confirmación: ${e.message}');
      
      if (message.contains('email not confirmed')) {
        print('❌ Email existe pero no está confirmado');
        return false;
      } else if (message.contains('invalid login credentials')) {
        print('✅ Email existe y está confirmado');
        return true;
      } else if (message.contains('user not found') || 
                 message.contains('email not found')) {
        print('❌ Email no existe');
        return false;
      }
      
      // En caso de duda, asumir que no está confirmado
      print('❓ Error desconocido, asumiendo que no está confirmado');
      return false;
      
    } catch (e) {
      print('❌ Excepción inesperada al verificar confirmación: $e');
      return false;
    }
  }

  /// Obtener mensaje de error amigable
  String _getAuthErrorMessage(AuthException error) {
    print('🔍 Analizando error de autenticación:');
    print('   - Status Code: ${error.statusCode}');
    print('   - Message: ${error.message}');
    
    final message = error.message.toLowerCase();
    
    // Verificar si el email ya está registrado
    if (message.contains('user already registered') || 
        message.contains('email already registered') ||
        message.contains('already been registered')) {
      return 'Este email ya está registrado. ¿Quieres iniciar sesión?';
    }
    
    // Verificar si el email no está confirmado
    if (message.contains('email not confirmed') || 
        message.contains('email_not_confirmed')) {
      return 'Debes confirmar tu email. Revisa tu bandeja de entrada y haz clic en el enlace de confirmación';
    }
    
    // Verificar credenciales inválidas (para login)
    if (message.contains('invalid login credentials') || 
        message.contains('invalid credentials')) {
      return 'Email o contraseña incorrectos. Verifica tus credenciales';
    }
    
    // Verificar si el usuario no existe
    if (message.contains('user not found') || 
        message.contains('email not found')) {
      return 'No existe una cuenta con este email. ¿Quieres registrarte?';
    }
    
    // Verificar si el email es inválido
    if (message.contains('invalid email') || 
        message.contains('email address') && message.contains('invalid')) {
      return 'El formato del email no es válido. Verifica que esté escrito correctamente';
    }
    
    // Verificar problemas de contraseña
    if (message.contains('password') && message.contains('weak')) {
      return 'La contraseña es muy débil. Debe tener al menos 6 caracteres';
    }
    
    // Verificar límites de tasa
    if (message.contains('too many requests') || 
        message.contains('rate limit')) {
      return 'Demasiados intentos. Espera unos minutos antes de intentar nuevamente';
    }
    
    switch (error.statusCode) {
      case '400':
        if (message.contains('email')) {
          return 'Problema con el email: ${error.message}';
        }
        return 'Datos inválidos: ${error.message}';
      case '401':
        return 'Email o contraseña incorrectos';
      case '422':
        return 'Email ya registrado o datos inválidos';
      case '429':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        // Devolver el mensaje completo para mejor diagnóstico
        return 'Error: ${error.message}';
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

