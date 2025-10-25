
/// Resultado de operaciones de base de datos
class DatabaseResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;

  DatabaseResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });

  /// Resultado exitoso
  factory DatabaseResult.success({
    required T? data,
    String? message,
  }) {
    return DatabaseResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  /// Resultado con error
  factory DatabaseResult.error(String error) {
    return DatabaseResult._(
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'DatabaseResult.success(data: $data, message: $message)';
    } else {
      return 'DatabaseResult.error(error: $error)';
    }
  }
}
