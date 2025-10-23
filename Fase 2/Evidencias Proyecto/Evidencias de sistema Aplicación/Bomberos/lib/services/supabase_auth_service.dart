import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/models.dart';

/// Servicio de autenticación para el proyecto Bomberos
/// Maneja el registro y login usando Supabase Auth con la tabla bombero
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

  /// Registrar nuevo bombero con Supabase Auth
  /// 
  /// Los usuarios deben verificar su correo electrónico antes de poder iniciar sesión.
  /// Se enviará un email de confirmación automáticamente después del registro.
  Future<AuthResult> signUpBombero({
    required String email,
    required String password,
    required String rutCompleto,
    required String nombre,
    required String apellidoPaterno,
    required String compania,
  }) async {
    try {
      // Paso 0: Validar que el RUT no esté ya registrado
      final bomberoExistente = await _getBomberoByRut(rutCompleto);
      if (bomberoExistente != null) {
        return AuthResult.error('Ya existe un bombero registrado con este RUT: $rutCompleto');
      }

      // Paso 0.5: Validar que el email no esté ya registrado como bombero
      final bomberoConEmail = await _getBomberoByEmail(email.trim());
      if (bomberoConEmail != null) {
        return AuthResult.error('Ya existe un bombero registrado con este email: ${email.trim()}');
      }

      // Paso 0.6: Verificar que el usuario no esté registrado como residente
      debugPrint('🔍 Verificando que el usuario no esté registrado como residente: $email');
      final esResidente = await _verificarSiEsResidente(email.trim());
      if (esResidente) {
        debugPrint('❌ El email $email está registrado como residente');
        return AuthResult.error('Este correo electrónico ya está registrado como residente. Por favor, usa la aplicación de residentes o usa otro email.');
      }

      // Paso 1: Registrar usuario en Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Paso 2: Guardar información en la tabla bombero
        try {
          // Obtener una comuna válida antes de crear el bombero
          final comunaValida = await _obtenerComunaValida();
          
          final bombero = Bombero(
            rutNum: Bombero.fromRutCompleto(rutCompleto, '').rutNum,
            rutDv: Bombero.fromRutCompleto(rutCompleto, '').rutDv,
            compania: compania.trim(),
            nombBombero: nombre.trim(),
            apePBombero: apellidoPaterno.trim(),
            emailB: email.trim(),
            cutCom: comunaValida,
          );
          final bomberoData = bombero.toInsertData();

          final bomberoResponse = await _client
              .from('bombero')
              .insert(bomberoData)
              .select()
              .single();

          final bomberoInsertado = Bombero.fromJson(bomberoResponse);

          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: email.trim(),
              rutCompleto: rutCompleto,
              bombero: bomberoInsertado,
            ),
          );
        } on PostgrestException catch (e) {
          // Si falla al guardar el bombero, eliminar el usuario de Auth
          await _client.auth.signOut();
          
          // Traducir errores específicos de PostgreSQL
          if (e.message.contains('duplicate key value violates unique constraint')) {
            if (e.message.contains('Bombero_pkey')) {
              return AuthResult.error('Ya existe un bombero registrado con este RUT: $rutCompleto');
            } else if (e.message.contains('bombero_email_b_key')) {
              return AuthResult.error('Ya existe un bombero registrado con este email: ${email.trim()}');
            }
          }
          
          return AuthResult.error('Error al guardar información del bombero: ${e.message}');
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
      // PASO 1: Verificar que el usuario existe en bombero ANTES de autenticar
      debugPrint('🔍 Verificando que el usuario existe en bombero: $email');
      final bombero = await _getBomberoByEmail(email.trim());
      
      if (bombero == null) {
        debugPrint('❌ Usuario no encontrado en bombero: $email');
        return AuthResult.error('Este correo electrónico no está registrado como bombero. Por favor, regístrate primero o usa la aplicación correcta.');
      }
      
      debugPrint('✅ Usuario encontrado en bombero, procediendo con autenticación');
      
      // PASO 2: Autenticar con Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // PASO 3: Verificar nuevamente que el bombero existe (doble verificación)
        final bomberoVerificado = await _getBomberoByEmail(response.user!.email!);
        
        if (bomberoVerificado != null) {
          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: response.user!.email ?? email,
              rutCompleto: bomberoVerificado.rutCompleto,
              bombero: bomberoVerificado,
            ),
          );
        } else {
          await _client.auth.signOut();
          return AuthResult.error('Error al cargar información del bombero');
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

  /// Reenviar email de confirmación
  Future<AuthResult> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.error('Error al reenviar email de confirmación: ${e.toString()}');
    }
  }

  /// Obtener bombero del usuario autenticado
  Future<Bombero?> getCurrentUserBombero() async {
    try {
      final user = _client.auth.currentUser;
      if (user?.email == null) return null;
      
      return await _getBomberoByEmail(user!.email!);
    } catch (e) {
      return null;
    }
  }

  /// Obtener bombero por email
  Future<Bombero?> _getBomberoByEmail(String email) async {
    try {
      final response = await _client
          .from('bombero')
          .select()
          .eq('email_b', email)
          .single();
      
      return Bombero.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Obtener bombero por RUT completo
  Future<Bombero?> _getBomberoByRut(String rutCompleto) async {
    try {
      final bombero = Bombero.fromRutCompleto(rutCompleto, '');
      final response = await _client
          .from('bombero')
          .select()
          .eq('rut_num', bombero.rutNum)
          .single();
      
      return Bombero.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Verificar si un email está registrado como residente
  Future<bool> _verificarSiEsResidente(String email) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .select('email')
          .eq('email', email.trim())
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Error al verificar si es residente: $e');
      return false; // En caso de error, permitir continuar
    }
  }


  /// Actualizar información del bombero
  Future<AuthResult> updateBombero({
    String? rutDv,
    String? email,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult.error('Usuario no autenticado');
      }

      final updates = <String, dynamic>{};

      if (rutDv != null && rutDv.trim().isNotEmpty) {
        updates['rut_dv'] = rutDv.trim();
      }

      if (email != null && email.trim().isNotEmpty) {
        updates['email_b'] = email.trim();
      }

      if (updates.isEmpty) {
        return AuthResult.error('No hay datos para actualizar');
      }

      await _client
          .from('bombero')
          .update(updates)
          .eq('email_b', user.email!);

      // Obtener datos actualizados
      final bombero = await _getBomberoByEmail(user.email!);
      
      return AuthResult.success(
        UserData(
          id: user.id,
          email: user.email!,
          rutCompleto: bombero?.rutCompleto ?? '',
          bombero: bombero,
        ),
      );
    } catch (e) {
      return AuthResult.error('Error al actualizar bombero: ${e.toString()}');
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
      return 'Por favor, confirma tu correo electrónico antes de iniciar sesión.';
    } else if (error.contains('User not found')) {
      return 'Usuario no encontrado.';
    }
    return error;
  }

  /// Obtener una comuna válida para crear bomberos
  Future<int> _obtenerComunaValida() async {
    try {
      // Buscar comunas existentes
      final comunasResponse = await _client
          .from('comunas')
          .select('cut_com')
          .limit(1);
      
      if (comunasResponse.isNotEmpty) {
        final cutCom = comunasResponse.first['cut_com'] as int;
        debugPrint('✅ Usando comuna existente: $cutCom');
        return cutCom;
      }
      
      // Si no hay comunas, crear una temporal válida
      const cutComTemporal = 13101; // Santiago
      debugPrint('⚠️ No hay comunas en la BD, usando Santiago por defecto: $cutComTemporal');
      
      try {
        await _client.from('comunas').insert({
          'cut_com': cutComTemporal,
          'comuna': 'Santiago',
          'cut_reg': 13,
          'region': 'Metropolitana',
          'cut_prov': 131,
          'provincia': 'Santiago',
          'superficie': 641.4,
          'geometry': 'POINT(-70.6693 -33.4489)',
        });
        debugPrint('✅ Comuna temporal creada: $cutComTemporal');
        return cutComTemporal;
      } catch (e) {
        debugPrint('⚠️ Error al crear comuna temporal: $e');
        // Usar comuna alternativa
        const cutComAlternativo = 13102; // Providencia
        debugPrint('🔄 Intentando con comuna alternativa: $cutComAlternativo');
        
        try {
          await _client.from('comunas').insert({
            'cut_com': cutComAlternativo,
            'comuna': 'Providencia',
            'cut_reg': 13,
            'region': 'Metropolitana',
            'cut_prov': 131,
            'provincia': 'Santiago',
            'superficie': 14.4,
            'geometry': 'POINT(-70.6167 -33.4255)',
          });
          debugPrint('✅ Comuna alternativa creada: $cutComAlternativo');
          return cutComAlternativo;
        } catch (e2) {
          debugPrint('❌ Error al crear comuna alternativa: $e2');
          // Retornar valor por defecto
          return cutComTemporal;
        }
      }
    } catch (e) {
      debugPrint('❌ Error al obtener comuna válida: $e');
      // Retornar Santiago por defecto
      return 13101;
    }
  }
}

/// Clase para representar los datos del usuario bombero
class UserData {
  final String id;
  final String email;
  final String rutCompleto;
  final Bombero? bombero;

  UserData({
    required this.id,
    required this.email,
    required this.rutCompleto,
    this.bombero,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'rut_completo': rutCompleto,
    'bombero': bombero?.toJson(),
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json['id'] as String,
    email: json['email'] as String,
    rutCompleto: json['rut_completo'] as String,
    bombero: json['bombero'] != null 
        ? Bombero.fromJson(json['bombero'] as Map<String, dynamic>)
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