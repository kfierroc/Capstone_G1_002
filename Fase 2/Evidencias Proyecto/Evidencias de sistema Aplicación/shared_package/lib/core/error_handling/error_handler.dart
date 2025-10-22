// import 'package:flutter/foundation.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'error_types.dart';
import 'error_messages.dart';
import 'error_logger.dart';

/// Manejador centralizado de errores siguiendo principios SOLID
/// 
/// Responsabilidades:
/// - Procesar errores de diferentes fuentes
/// - Convertir errores técnicos a mensajes de usuario
/// - Logging centralizado
/// - Categorización de errores
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final ErrorLogger _logger = ErrorLogger();

  /// Procesa cualquier error y retorna un ErrorResult estructurado
  Future<ErrorResult> handleError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
    bool logError = true,
  }) async {
    try {
      // Logging del error si está habilitado
      if (logError) {
        await _logger.logError(error, operation, context: context);
      }

      // Categorizar y procesar el error
      final errorType = _categorizeError(error);
      final userMessage = _getUserMessage(errorType, error);
      final technicalMessage = _getTechnicalMessage(error);

      return ErrorResult(
        type: errorType,
        userMessage: userMessage,
        technicalMessage: technicalMessage,
        timestamp: DateTime.now(),
        context: context,
      );
    } catch (e) {
      // Fallback en caso de error en el manejador
      return ErrorResult(
        type: ErrorType.unknown,
        userMessage: ErrorMessages.genericError,
        technicalMessage: 'Error handler failed: ${e.toString()}',
        timestamp: DateTime.now(),
        context: context,
      );
    }
  }

  /// Categoriza el tipo de error
  ErrorType _categorizeError(dynamic error) {
    if (error is NetworkException) {
      return ErrorType.network;
    } else if (error is AuthException) {
      return ErrorType.authentication;
    } else if (error is ValidationException) {
      return ErrorType.validation;
    } else if (error is TimeoutException) {
      return ErrorType.timeout;
    } else if (error is DatabaseException) {
      return ErrorType.database;
    } else if (error is PermissionException) {
      return ErrorType.permission;
    } else if (error is ConfigurationException) {
      return ErrorType.configuration;
    } else if (error is ExternalServiceException) {
      return ErrorType.externalService;
    } else if (error is ParsingException) {
      return ErrorType.parsing;
    } else if (error is FormatException) {
      return ErrorType.parsing;
    } else if (error is StateError) {
      return ErrorType.unknown;
    } else {
      return ErrorType.unknown;
    }
  }


  /// Obtiene mensaje amigable para el usuario
  String _getUserMessage(ErrorType type, dynamic error) {
    switch (type) {
      case ErrorType.network:
        return ErrorMessages.networkError;
      case ErrorType.authentication:
        return ErrorMessages.authenticationError;
      case ErrorType.validation:
        return ErrorMessages.validationError;
      case ErrorType.duplicate:
        return ErrorMessages.duplicateError;
      case ErrorType.referentialIntegrity:
        return ErrorMessages.referentialIntegrityError;
      case ErrorType.permission:
        return ErrorMessages.permissionError;
      case ErrorType.timeout:
        return ErrorMessages.timeoutError;
      case ErrorType.format:
        return ErrorMessages.formatError;
      case ErrorType.state:
        return ErrorMessages.stateError;
      case ErrorType.database:
        return ErrorMessages.databaseError;
      case ErrorType.configuration:
        return ErrorMessages.configurationError;
      case ErrorType.externalService:
        return ErrorMessages.externalServiceError;
      case ErrorType.parsing:
        return ErrorMessages.parsingError;
      case ErrorType.unknown:
        return ErrorMessages.genericError;
    }
  }

  /// Obtiene mensaje técnico detallado
  String _getTechnicalMessage(dynamic error) {
    if (error is NetworkException) {
      return 'NetworkException: ${error.message}';
    } else if (error is AuthException) {
      return 'AuthException: ${error.message}';
    } else {
      return error.toString();
    }
  }

  /// Procesa errores de operaciones de base de datos
  Future<ErrorResult> handleDatabaseError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    return handleError(
      error,
      'Database: $operation',
      context: context,
    );
  }

  /// Procesa errores de operaciones de red
  Future<ErrorResult> handleNetworkError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    return handleError(
      error,
      'Network: $operation',
      context: context,
    );
  }

  /// Procesa errores de autenticación
  Future<ErrorResult> handleAuthError(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    return handleError(
      error,
      'Auth: $operation',
      context: context,
    );
  }
}

