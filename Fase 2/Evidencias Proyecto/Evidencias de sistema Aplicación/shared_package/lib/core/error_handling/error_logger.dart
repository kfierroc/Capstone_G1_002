// import 'package:flutter/foundation.dart';
import 'error_types.dart';

/// Niveles de severidad de errores
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Logger centralizado para errores siguiendo principios SOLID
/// 
/// Responsabilidades:
/// - Logging estructurado de errores
/// - Diferentes niveles de logging
/// - Contexto adicional para debugging
/// - Filtrado por severidad
class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();
  factory ErrorLogger() => _instance;
  ErrorLogger._internal();

  /// Logs un error con contexto adicional
  Future<void> logError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
    ErrorSeverity? severity,
  }) async {
    try {
      final errorSeverity = severity ?? _determineSeverity(error);
      
      // Solo loggear errores de severidad media o superior en producción
      if (!kDebugMode && errorSeverity.index < ErrorSeverity.medium.index) {
        return;
      }

      final logEntry = _createLogEntry(error, operation, context, errorSeverity);
      
      if (kDebugMode) {
        _logToConsole(logEntry);
      }
      
      // En producción, enviar a servicio de logging externo
      if (!kDebugMode && errorSeverity.index >= ErrorSeverity.high.index) {
        await _sendToExternalService(logEntry);
      }
    } catch (e) {
      // Fallback: loggear el error del logger
      print('ErrorLogger failed: $e');
    }
  }

  /// Determina la severidad del error
  ErrorSeverity _determineSeverity(dynamic error) {
    if (error is NetworkException) {
      return ErrorSeverity.high;
    } else if (error is AuthException) {
      return ErrorSeverity.critical;
    } else if (error is DatabaseException) {
      return ErrorSeverity.high;
    } else if (error is ValidationException) {
      return ErrorSeverity.medium;
    } else if (error is TimeoutException) {
      return ErrorSeverity.medium;
    } else if (error is PermissionException) {
      return ErrorSeverity.critical;
    } else {
      return ErrorSeverity.medium;
    }
  }

  /// Crea una entrada de log estructurada
  Map<String, dynamic> _createLogEntry(
    dynamic error,
    String operation,
    Map<String, dynamic>? context,
    ErrorSeverity severity,
  ) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'severity': severity.name,
      'operation': operation,
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'context': context ?? {},
      'platform': 'unknown',
      'is_debug': kDebugMode,
    };
  }

  /// Logs a consola en modo debug
  void _logToConsole(Map<String, dynamic> logEntry) {
    final severity = logEntry['severity'] as String;
    final operation = logEntry['operation'] as String;
    final errorMessage = logEntry['error_message'] as String;
    
    final emoji = _getSeverityEmoji(severity);
    print('$emoji [$severity] $operation: $errorMessage');
    
    if (logEntry['context'] != null && (logEntry['context'] as Map).isNotEmpty) {
      print('   Context: ${logEntry['context']}');
    }
  }

  /// Obtiene emoji para la severidad
  String _getSeverityEmoji(String severity) {
    switch (severity) {
      case 'critical':
        return '🚨';
      case 'high':
        return '⚠️';
      case 'medium':
        return '⚠️';
      case 'low':
        return 'ℹ️';
      default:
        return '❌';
    }
  }

  /// Envía el error a un servicio externo (implementar según necesidades)
  Future<void> _sendToExternalService(Map<String, dynamic> logEntry) async {
    // Implementación básica para envío a servicio externo
    // Se puede integrar con Firebase Crashlytics, Sentry, LogRocket, etc.
    
    // Por ahora, solo loggear en modo debug
    print('External logging: ${logEntry.toString()}');
  }

  /// Logs específicos para diferentes tipos de operaciones
  Future<void> logDatabaseError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    await logError(
      error,
      'Database: $operation',
      context: context,
      severity: ErrorSeverity.high,
    );
  }

  Future<void> logNetworkError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    await logError(
      error,
      'Network: $operation',
      context: context,
      severity: ErrorSeverity.high,
    );
  }

  Future<void> logAuthError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    await logError(
      error,
      'Auth: $operation',
      context: context,
      severity: ErrorSeverity.critical,
    );
  }

  Future<void> logValidationError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    await logError(
      error,
      'Validation: $operation',
      context: context,
      severity: ErrorSeverity.medium,
    );
  }

  /// Logs de información (no errores)
  void logInfo(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  void logWarning(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }

  void logSuccess(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
      if (context != null && context.isNotEmpty) {
        print('   Context: $context');
      }
    }
  }
  
  // Constante para modo debug
  static const bool kDebugMode = true; // Cambiar a false en producción
}
