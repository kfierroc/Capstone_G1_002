/// Resultado de operaciones de servicios
/// 
/// Clase genérica para manejar resultados exitosos y errores
/// en operaciones de servicios de la aplicación Bomberos
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;

  ServiceResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });

  /// Getter para el mensaje de error (alias para error)
  String? get errorMessage => error;

  /// Resultado exitoso
  factory ServiceResult.success({
    required T? data,
    String? message,
  }) {
    return ServiceResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  /// Resultado con error
  factory ServiceResult.error(String error) {
    return ServiceResult._(
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ServiceResult.success(data: $data, message: $message)';
    } else {
      return 'ServiceResult.error(error: $error)';
    }
  }
}
