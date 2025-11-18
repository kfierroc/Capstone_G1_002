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
