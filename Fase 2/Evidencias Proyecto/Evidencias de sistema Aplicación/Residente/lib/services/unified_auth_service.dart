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

  /// Registrar usuario con email y contraseña (para verificación)
  Future<AuthResult> registerWithEmail(
    String email,
    String password, {
    bool sendEmailVerification = false,
  }) async {
    try {
      debugPrint('🔐 UnifiedAuthService.registerWithEmail - Iniciando...');
      debugPrint('📧 Email: $email');
      debugPrint('📧 Enviar verificación: $sendEmailVerification');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: sendEmailVerification ? 'https://tu-app.com/verify' : null,
      );

      if (response.user != null) {
        debugPrint('✅ Usuario registrado exitosamente');
        return AuthResult.success(
          UserData(
            id: response.user!.id,
            email: response.user!.email ?? email,
            rutTitular: '', // Se llenará después del registro completo
            grupoFamiliar: null,
          ),
          message: 'Usuario registrado exitosamente',
        );
      } else {
        debugPrint('❌ Error: Usuario no creado');
        return AuthResult.error('No se pudo crear el usuario');
      }
    } catch (e) {
      debugPrint('❌ Error en registerWithEmail: $e');
      return AuthResult.error('Error al registrar usuario: $e');
    }
  }

  /// Reenviar correo de verificación
  Future<void> resendEmailVerification({String? email}) async {
    try {
      debugPrint('📧 Reenviando correo de verificación...');
      
      // Usar el email proporcionado o el del usuario actual
      final emailToUse = email ?? currentUser?.email;
      
      if (emailToUse == null || emailToUse.isEmpty) {
        throw Exception('No se puede reenviar el correo: email no disponible');
      }
      
      debugPrint('📧 Reenviando a: $emailToUse');
      
      await _client.auth.resend(
        type: OtpType.signup,
        email: emailToUse,
      );
      debugPrint('✅ Correo de verificación reenviado');
    } catch (e) {
      debugPrint('❌ Error al reenviar correo: $e');
      rethrow;
    }
  }

  /// Verificar código de verificación
  Future<AuthResult> verifyEmailCode(String code) async {
    try {
      debugPrint('🔐 Verificando código de verificación: $code');
      
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        return AuthResult.error('No hay usuario para verificar');
      }
      
      // Verificar el código con Supabase usando OTP
      final response = await _client.auth.verifyOTP(
        type: OtpType.signup,
        token: code,
        email: currentUser.email!,
      );
      
      if (response.user != null) {
        debugPrint('✅ Correo verificado exitosamente');
        return AuthResult.success(
          UserData(
            id: response.user!.id,
            email: response.user!.email ?? '',
            rutTitular: '', // Se llenará después del registro completo
            grupoFamiliar: null,
          ),
          message: 'Correo verificado exitosamente',
        );
      } else {
        return AuthResult.error('Código de verificación inválido');
      }
    } catch (e) {
      debugPrint('❌ Error al verificar código: $e');
      return AuthResult.error('Código de verificación inválido o expirado');
    }
  }

  /// Registrar nuevo grupo familiar con Supabase Auth
  Future<AuthResult> signUpGrupoFamiliar({
    required String email,
    required String password,
    required String rutTitular,
    required String nombreTitular,
    required String apellidoTitular,
    required String telefonoTitular,
  }) async {
    try {
      debugPrint('🔐 UnifiedAuthService.signUpGrupoFamiliar - Iniciando...');
      debugPrint('📧 Email: $email');
      debugPrint('🆔 RUT Titular: $rutTitular');

      // Verificar si el email ya existe en grupofamiliar
      final emailExiste = await _verificarEmailExistente(email);
      if (emailExiste) {
        debugPrint('⚠️ El email $email ya existe en grupofamiliar');
        debugPrint('🔄 Intentando iniciar sesión con credenciales existentes...');
        
        // Intentar iniciar sesión con las credenciales proporcionadas
        try {
          final signInResult = await signInWithPassword(
            email: email,
            password: password,
          );
          
          if (signInResult.isSuccess) {
            debugPrint('✅ Sesión iniciada exitosamente para usuario existente');
            
            // Actualizar datos faltantes del grupo familiar
            await _actualizarDatosGrupoFamiliar(email, nombreTitular, apellidoTitular, telefonoTitular);
            
            return signInResult;
          } else {
            debugPrint('❌ No se pudo iniciar sesión: ${signInResult.error}');
            return AuthResult.error('Este correo electrónico ya está registrado pero la contraseña es incorrecta. Por favor, inicie sesión o use otro email.');
          }
        } catch (e) {
          debugPrint('❌ Error al intentar iniciar sesión: $e');
          return AuthResult.error('Este correo electrónico ya está registrado. Por favor, inicie sesión o use otro email.');
        }
      }

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
          // Generar un ID único para el grupo familiar usando método más seguro
          final idGrupof = _generarIdGrupofUnico();
          
          final grupoFamiliarData = {
            'id_grupof': idGrupof,
            'rut_titular': rutTitular.trim(),
            'nomb_titular': nombreTitular.trim(),
            'ape_p_titular': apellidoTitular.trim(),
            'telefono_titular': telefonoTitular.trim(),
            'email': email.trim(),
            'fecha_creacion': DateTime.now().toIso8601String(),
          };

          debugPrint('📝 Insertando grupo familiar con ID: $idGrupof');
          debugPrint('📝 Datos: $grupoFamiliarData');

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

      // PRIMERO: Verificar que el usuario no esté registrado como bombero
      debugPrint('🔍 Verificando que el usuario no esté registrado como bombero: $email');
      final esBombero = await _verificarSiEsBombero(email.trim());
      if (esBombero) {
        debugPrint('❌ El email $email está registrado como bombero');
        return AuthResult.error('Este correo electrónico está registrado como bombero. Por favor, usa la aplicación de bomberos o usa otro email.');
      }

      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        debugPrint('✅ Usuario autenticado: ${response.user!.id}');
        
        // Obtener datos del grupo familiar
        final grupoFamiliar = await _getGrupoFamiliarByEmail(response.user!.email!);
        
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
          debugPrint('   - Esto puede ocurrir si el usuario fue creado antes de implementar el sistema actual');
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

  /// Recuperar contraseña - envía código OTP al email
  Future<AuthResult> resetPassword(String email) async {
    try {
      debugPrint('🔐 UnifiedAuthService.resetPassword - Enviando código OTP...');
      
      // Enviar código OTP para reset de contraseña
      await _client.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false, // No crear usuario nuevo
      );
      
      debugPrint('✅ Código OTP enviado');
      return AuthResult.success(
        null,
        message: 'Se ha enviado un código de verificación a tu correo',
      );
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en resetPassword: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en resetPassword: $e');
      return AuthResult.error('Error al enviar código: ${e.toString()}');
    }
  }

  /// Resetear contraseña con código OTP
  Future<AuthResult> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔐 UnifiedAuthService.resetPasswordWithCode - Verificando código...');
      
      // Verificar el código OTP
      final response = await _client.auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim(),
        token: code.trim(),
      );

      if (response.user != null) {
        debugPrint('✅ Código verificado, actualizando contraseña...');
        
        // Establecer la sesión temporal para poder cambiar la contraseña
        await _client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
        
        debugPrint('✅ Contraseña actualizada exitosamente');
        
        // Cerrar sesión después de cambiar la contraseña
        await _client.auth.signOut();
        
        return AuthResult.success(
          null,
          message: 'Contraseña cambiada exitosamente',
        );
      } else {
        return AuthResult.error('Código de verificación inválido');
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en resetPasswordWithCode: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en resetPasswordWithCode: $e');
      return AuthResult.error('Error al cambiar contraseña: ${e.toString()}');
    }
  }

  /// Actualizar contraseña del usuario actual
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      debugPrint('🔐 UnifiedAuthService.updatePassword - Actualizando contraseña...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        return AuthResult.error('No hay usuario autenticado');
      }
      
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      debugPrint('✅ Contraseña actualizada exitosamente');
      return AuthResult.success(null);
    } on AuthException catch (e) {
      debugPrint('❌ AuthException en updatePassword: ${e.message}');
      return AuthResult.error(_translateAuthError(e.message));
    } catch (e) {
      debugPrint('❌ Error inesperado en updatePassword: $e');
      return AuthResult.error('Error al actualizar contraseña: ${e.toString()}');
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
      return await _getGrupoFamiliarByEmail(user.email!);
    } catch (e) {
      debugPrint('❌ Error al obtener grupo familiar: $e');
      return null;
    }
  }

  /// Obtener grupo familiar por email
  Future<GrupoFamiliar?> _getGrupoFamiliarByEmail(String email) async {
    try {
      debugPrint('🔍 Buscando grupo familiar por email: $email');
      
      final response = await _client
          .from('grupofamiliar')
          .select()
          .eq('email', email)
          .single();
      
      debugPrint('✅ Grupo familiar encontrado por email');
      return GrupoFamiliar.fromJson(response);
    } catch (e) {
      debugPrint('⚠️ No se encontró grupo familiar por email: $e');
      return null;
    }
  }

  /// Verificar si un email está registrado como bombero
  Future<bool> _verificarSiEsBombero(String email) async {
    try {
      final response = await _client
          .from('bombero')
          .select('email_b')
          .eq('email_b', email.trim())
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Error al verificar si es bombero: $e');
      return false; // En caso de error, permitir continuar
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
          .eq('email', user.email!);

      // Obtener datos actualizados
      final grupoFamiliar = await _getGrupoFamiliarByEmail(user.email!);
      
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

  /// Verificar si un email ya existe en la tabla grupofamiliar
  Future<bool> _verificarEmailExistente(String email) async {
    try {
      debugPrint('🔍 Verificando si el email $email ya existe...');
      
      final response = await _client
          .from('grupofamiliar')
          .select('email')
          .eq('email', email.trim())
          .limit(1);
      
      final existe = response.isNotEmpty;
      debugPrint('📊 Email $email existe: $existe');
      
      return existe;
    } catch (e) {
      debugPrint('❌ Error al verificar email $email: $e');
      return false; // En caso de error, permitir continuar
    }
  }

  /// Generar un ID único para grupo familiar dentro del rango de INTEGER
  int _generarIdGrupofUnico() {
    // Usar timestamp en segundos + microsegundos para mayor unicidad
    final ahora = DateTime.now();
    final timestampSegundos = ahora.millisecondsSinceEpoch ~/ 1000;
    final microsegundos = ahora.microsecond;
    
    // Combinar timestamp y microsegundos, limitar a rango seguro de INTEGER
    final idBase = timestampSegundos % 1000000; // Limitar a 6 dígitos
    final idCompleto = idBase * 1000 + (microsegundos % 1000); // Agregar 3 dígitos más
    
    // Asegurar que esté dentro del rango de INTEGER positivo
    final idFinal = idCompleto % 2147483647; // Máximo valor positivo de INTEGER
    
    debugPrint('🆔 ID generado: $idFinal (base: $idBase, micro: $microsegundos)');
    return idFinal;
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

  /// Actualizar datos faltantes del grupo familiar para usuarios existentes
  Future<void> _actualizarDatosGrupoFamiliar(
    String email,
    String nombreTitular,
    String apellidoTitular,
    String telefonoTitular,
  ) async {
    try {
      debugPrint('🔄 Actualizando datos del grupo familiar para: $email');
      
      // Obtener el grupo familiar actual
      final grupoActual = await _getGrupoFamiliarByEmail(email);
      if (grupoActual == null) {
        debugPrint('❌ No se encontró grupo familiar para actualizar');
        return;
      }
      
      // Preparar datos de actualización (solo campos que no estén vacíos)
      final datosActualizacion = <String, dynamic>{};
      
      if (nombreTitular.isNotEmpty && grupoActual.nombTitular.isEmpty) {
        datosActualizacion['nomb_titular'] = nombreTitular.trim();
        debugPrint('📝 Actualizando nombre: $nombreTitular');
      }
      
      if (apellidoTitular.isNotEmpty && grupoActual.apePTitular.isEmpty) {
        datosActualizacion['ape_p_titular'] = apellidoTitular.trim();
        debugPrint('📝 Actualizando apellido: $apellidoTitular');
      }
      
      if (telefonoTitular.isNotEmpty && grupoActual.telefonoTitular.isEmpty) {
        datosActualizacion['telefono_titular'] = telefonoTitular.trim();
        debugPrint('📝 Actualizando teléfono: $telefonoTitular');
      }
      
      // Solo actualizar si hay datos nuevos
      if (datosActualizacion.isNotEmpty) {
        debugPrint('📝 Datos a actualizar: $datosActualizacion');
        
        final response = await _client
            .from('grupofamiliar')
            .update(datosActualizacion)
            .eq('email', email)
            .select()
            .single();
        
        debugPrint('✅ Datos del grupo familiar actualizados exitosamente');
        debugPrint('📦 Respuesta: $response');
      } else {
        debugPrint('ℹ️ No hay datos nuevos para actualizar');
      }
    } catch (e) {
      debugPrint('❌ Error al actualizar datos del grupo familiar: $e');
      // No lanzar excepción para no interrumpir el flujo de login
    }
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
