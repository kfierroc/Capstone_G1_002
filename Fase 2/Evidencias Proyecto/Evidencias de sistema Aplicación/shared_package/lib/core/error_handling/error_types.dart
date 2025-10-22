/// Tipos de errores del sistema
/// 
/// Define los diferentes tipos de errores que puede manejar la aplicación
enum ErrorType {
  /// Error de red/conectividad
  network,
  
  /// Error de autenticación/autorización
  authentication,
  
  /// Error de validación de datos
  validation,
  
  /// Error de base de datos (PostgreSQL/Supabase)
  database,
  
  /// Error de timeout
  timeout,
  
  /// Error desconocido/no categorizado
  unknown,
  
  /// Error de permisos
  permission,
  
  /// Error de configuración
  configuration,
  
  /// Error de servicio externo
  externalService,
  
  /// Error de parseo/serialización
  parsing,
  
  /// Error de duplicado
  duplicate,
  
  /// Error de integridad referencial
  referentialIntegrity,
  
  /// Error de formato
  format,
  
  /// Error de estado
  state,
}

/// Resultado de procesamiento de error
class ErrorResult {
  const ErrorResult({
    required this.type,
    required this.userMessage,
    required this.technicalMessage,
    this.context,
    required this.timestamp,
    this.stackTrace,
  });

  final ErrorType type;
  final String userMessage;
  final String technicalMessage;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final String? stackTrace;

  /// Crea una copia con campos actualizados
  ErrorResult copyWith({
    ErrorType? type,
    String? userMessage,
    String? technicalMessage,
    Map<String, dynamic>? context,
    DateTime? timestamp,
    String? stackTrace,
  }) {
    return ErrorResult(
      type: type ?? this.type,
      userMessage: userMessage ?? this.userMessage,
      technicalMessage: technicalMessage ?? this.technicalMessage,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'ErrorResult(type: $type, userMessage: $userMessage, technicalMessage: $technicalMessage)';
  }
}

/// Excepciones personalizadas del sistema
class AppException implements Exception {
  const AppException(this.message, this.type, [this.context]);

  final String message;
  final ErrorType type;
  final Map<String, dynamic>? context;

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.network, context);
}

class AuthException extends AppException {
  const AuthException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.authentication, context);
}

class ValidationException extends AppException {
  const ValidationException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.validation, context);
}

class DatabaseException extends AppException {
  const DatabaseException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.database, context);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.timeout, context);
}

class PermissionException extends AppException {
  const PermissionException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.permission, context);
}

class ConfigurationException extends AppException {
  const ConfigurationException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.configuration, context);
}

class ExternalServiceException extends AppException {
  const ExternalServiceException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.externalService, context);
}

class ParsingException extends AppException {
  const ParsingException(String message, [Map<String, dynamic>? context])
      : super(message, ErrorType.parsing, context);
}