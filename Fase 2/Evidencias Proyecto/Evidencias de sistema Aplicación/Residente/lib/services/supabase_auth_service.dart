import 'package:flutter/foundation.dart';
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
    required String nombreTitular,
    required String apellidoTitular,
    required String telefonoTitular,
  }) async {
    try {
      // PASO 0: Verificar que el usuario no esté registrado como bombero
      debugPrint('🔍 Verificando que el usuario no esté registrado como bombero: $email');
      final esBombero = await _verificarSiEsBombero(email.trim());
      if (esBombero) {
        debugPrint('❌ El email $email está registrado como bombero');
        return AuthResult.error('Este correo electrónico ya está registrado como bombero. Por favor, usa la aplicación de bomberos o usa otro email.');
      }
      
      // PASO 1: Verificar si el email ya existe en grupofamiliar
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
      );

      if (response.user != null) {
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
      // PASO 1: Verificar que el usuario existe en grupofamiliar ANTES de autenticar
      debugPrint('🔍 Verificando que el usuario existe en grupofamiliar: $email');
      final grupoFamiliar = await _getGrupoFamiliarByEmail(email.trim());
      
      if (grupoFamiliar == null) {
        debugPrint('❌ Usuario no encontrado en grupofamiliar: $email');
        return AuthResult.error('Este correo electrónico no está registrado como residente. Por favor, regístrate primero o usa la aplicación correcta.');
      }
      
      debugPrint('✅ Usuario encontrado en grupofamiliar, procediendo con autenticación');
      
      // PASO 2: Autenticar con Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // PASO 3: Verificar nuevamente que el grupo familiar existe (doble verificación)
        final grupoFamiliarVerificado = await _getGrupoFamiliarByEmail(response.user!.email!);
        
        if (grupoFamiliarVerificado != null) {
          return AuthResult.success(
            UserData(
              id: response.user!.id,
              email: response.user!.email ?? email,
              rutTitular: grupoFamiliarVerificado.rutTitular,
              grupoFamiliar: grupoFamiliarVerificado,
            ),
          );
        } else {
          await _client.auth.signOut();
          return AuthResult.error('Error al cargar información del grupo familiar');
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
      
      return await _getGrupoFamiliarByEmail(user.email!);
    } catch (e) {
      return null;
    }
  }

  /// Obtener grupo familiar por email
  Future<GrupoFamiliar?> _getGrupoFamiliarByEmail(String email) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .select()
          .eq('email', email)
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
      return AuthResult.error('Error al actualizar grupo familiar: ${e.toString()}');
    }
  }

  /// Verificar si un email ya existe en la tabla grupofamiliar
  Future<bool> _verificarEmailExistente(String email) async {
    try {
      final response = await _client
          .from('grupofamiliar')
          .select('email')
          .eq('email', email.trim())
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      return false; // En caso de error, permitir continuar
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
