import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import 'database_common.dart';

/// Clase base para todos los servicios de base de datos
/// 
/// Proporciona funcionalidad común como:
/// - Cliente de Supabase
/// - Manejo de errores
/// - Utilidades compartidas
abstract class BaseDatabaseService {
  /// Obtener el cliente de Supabase
  SupabaseClient get client => SupabaseConfig.client;

  /// Parsear condiciones médicas desde string a lista
  List<String> parseMedicalConditions(String? padecimiento) {
    if (padecimiento == null || padecimiento.isEmpty) {
      return <String>[];
    }
    
    return padecimiento
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Manejar errores de Postgrest
  String getPostgrestErrorMessage(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Ya existe un registro con estos datos';
      case '23503':
        return 'No se puede eliminar porque hay registros relacionados';
      case '23502':
        return 'Faltan datos requeridos';
      case '42501':
        return 'No tienes permisos para realizar esta acción';
      case '42P01':
        return 'Tabla no encontrada';
      case '42703':
        return 'Columna no encontrada';
      default:
        return e.message.isNotEmpty ? e.message : 'Error de base de datos';
    }
  }

  /// Manejar errores genéricos y devolver DatabaseResult
  DatabaseResult<T> handleError<T>(dynamic error, {String? customMessage}) {
    if (error is PostgrestException) {
      return DatabaseResult.error(getPostgrestErrorMessage(error));
    } else {
      final message = customMessage ?? 'Error inesperado: ${error.toString()}';
      debugPrint('❌ Error en $runtimeType: $message');
      return DatabaseResult.error(message);
    }
  }

  /// Crear resultado exitoso
  DatabaseResult<T> success<T>(T data, {String? message}) {
    return DatabaseResult.success(data: data, message: message);
  }

  /// Crear resultado de error
  DatabaseResult<T> error<T>(String message) {
    return DatabaseResult.error(message);
  }

  /// Validar que un ID sea válido
  bool isValidId(String? id) {
    if (id == null || id.isEmpty) return false;
    return int.tryParse(id) != null;
  }

  /// Validar que un email sea válido
  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Normaliza el teléfono al formato requerido por la BD: +56[2-9][0-9]{8,9}
  /// El formato debe cumplir: ^\+56[2-9][0-9]{8,9}$
  String normalizePhoneForDB(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ''; // Retornar vacío si no hay teléfono
    }
    
    // Remover todos los caracteres no numéricos
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanPhone.isEmpty) {
      return '';
    }
    
    // Si ya empieza con 56, removerlo para procesar
    if (cleanPhone.startsWith('56')) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    // Si tiene 9 dígitos y empieza con 9 (celular)
    if (cleanPhone.length == 9 && cleanPhone.startsWith('9')) {
      return '+56$cleanPhone'; // +56988776655
    }
    
    // Si tiene 8 dígitos (fijo, generalmente empieza con 2)
    if (cleanPhone.length == 8) {
      return '+56$cleanPhone'; // +56221234567
    }
    
    // Si tiene 9 dígitos pero no empieza con 9
    if (cleanPhone.length == 9) {
      return '+56$cleanPhone';
    }
    
    // Si tiene 10 dígitos (fijo con código de área de 2 dígitos)
    if (cleanPhone.length == 10) {
      return '+56$cleanPhone';
    }
    
    // Si tiene 11 dígitos (ya incluye el 56)
    if (cleanPhone.length == 11 && cleanPhone.startsWith('56')) {
      return '+${cleanPhone.substring(2)}'; // Ya tiene 56, solo agregar +
    }
    
    // Por defecto, agregar +56 al inicio
    return '+56$cleanPhone';
  }

  /// Log de operación exitosa
  void logSuccess(String operation, {String? details}) {
    debugPrint('✅ $operation${details != null ? ': $details' : ''}');
  }

  /// Log de operación con error
  void logError(String operation, dynamic error) {
    debugPrint('❌ Error en $operation: $error');
  }

  /// Log de operación en progreso
  void logProgress(String operation, {String? details}) {
    debugPrint('🔄 $operation${details != null ? ': $details' : ''}');
  }
}
