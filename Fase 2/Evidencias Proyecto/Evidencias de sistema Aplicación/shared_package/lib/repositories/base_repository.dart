// import 'package:flutter/foundation.dart';
import '../core/error_handling/error_handler.dart';
import '../core/error_handling/error_types.dart';

/// Resultado genérico para operaciones de repositorio
class RepositoryResult<T> {
  const RepositoryResult._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
    this.errorType,
  });

  /// Resultado exitoso
  factory RepositoryResult.success({
    required T data,
    String? message,
  }) {
    return RepositoryResult._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }

  /// Resultado con error
  factory RepositoryResult.error({
    required String error,
    ErrorType? errorType,
  }) {
    return RepositoryResult._(
      isSuccess: false,
      error: error,
      errorType: errorType,
    );
  }

  /// Resultado vacío (para operaciones que no retornan datos)
  factory RepositoryResult.empty() {
    return const RepositoryResult._(isSuccess: true);
  }

  final bool isSuccess;
  final T? data;
  final String? message;
  final String? error;
  final ErrorType? errorType;

  @override
  String toString() {
    return 'RepositoryResult(isSuccess: $isSuccess, data: $data, error: $error)';
  }
}

/// Repositorio base abstracto siguiendo principios SOLID
/// 
/// Responsabilidades:
/// - Definir interfaz común para repositorios
/// - Manejo centralizado de errores
/// - Logging estructurado
/// - Operaciones CRUD básicas
abstract class BaseRepository<T> {
  final ErrorHandler _errorHandler = ErrorHandler();

  /// Ejecuta una operación con manejo centralizado de errores
  Future<RepositoryResult<R>> execute<R>(
    Future<R> Function() operation,
    String operationName, {
    Map<String, dynamic>? context,
  }) async {
    try {
      print('🔄 Ejecutando operación: $operationName');
      
      final result = await operation();
      
      print('✅ Operación exitosa: $operationName');
      return RepositoryResult.success(data: result);
    } catch (error) {
      print('❌ Error en operación $operationName: $error');
      
      final errorResult = await _errorHandler.handleError(
        error,
        operationName,
        context: context,
      );

      return RepositoryResult.error(
        error: errorResult.userMessage,
        errorType: errorResult.type,
      );
    }
  }

  /// Ejecuta una operación que no retorna datos
  Future<RepositoryResult<void>> executeVoid(
    Future<void> Function() operation,
    String operationName, {
    Map<String, dynamic>? context,
  }) async {
    try {
      print('🔄 Ejecutando operación: $operationName');
      
      await operation();
      
      print('✅ Operación exitosa: $operationName');
      return RepositoryResult.empty();
    } catch (error) {
      print('❌ Error en operación $operationName: $error');
      
      final errorResult = await _errorHandler.handleError(
        error,
        operationName,
        context: context,
      );

      return RepositoryResult.error(
        error: errorResult.userMessage,
        errorType: errorResult.type,
      );
    }
  }

  // ============================================
  // OPERACIONES CRUD BÁSICAS
  // ============================================

  /// Obtiene un elemento por ID
  Future<RepositoryResult<T>> getById(String id);

  /// Obtiene todos los elementos
  Future<RepositoryResult<List<T>>> getAll();

  /// Obtiene elementos con paginación
  Future<RepositoryResult<List<T>>> getPaginated({
    required int page,
    required int limit,
  });

  /// Crea un nuevo elemento
  Future<RepositoryResult<T>> create(T item);

  /// Actualiza un elemento existente
  Future<RepositoryResult<T>> update(String id, T item);

  /// Elimina un elemento
  Future<RepositoryResult<void>> delete(String id);

  /// Busca elementos por criterios
  Future<RepositoryResult<List<T>>> search(Map<String, dynamic> criteria);

  // ============================================
  // OPERACIONES DE VALIDACIÓN
  // ============================================

  /// Valida un elemento antes de guardarlo
  Future<RepositoryResult<bool>> validate(T item) async {
    return RepositoryResult.success(data: true);
  }

  /// Verifica si un elemento existe
  Future<RepositoryResult<bool>> exists(String id);

  /// Cuenta elementos que cumplen criterios
  Future<RepositoryResult<int>> count(Map<String, dynamic>? criteria);
}

/// Repositorio específico para entidades con timestamps
abstract class TimestampedRepository<T> extends BaseRepository<T> {
  /// Obtiene elementos creados después de una fecha
  Future<RepositoryResult<List<T>>> getCreatedAfter(DateTime date);

  /// Obtiene elementos actualizados después de una fecha
  Future<RepositoryResult<List<T>>> getUpdatedAfter(DateTime date);

  /// Obtiene elementos por rango de fechas
  Future<RepositoryResult<List<T>>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Repositorio específico para entidades con usuario
abstract class UserOwnedRepository<T> extends BaseRepository<T> {
  /// Obtiene elementos de un usuario específico
  Future<RepositoryResult<List<T>>> getByUserId(String userId);

  /// Obtiene elementos paginados de un usuario
  Future<RepositoryResult<List<T>>> getByUserIdPaginated({
    required String userId,
    required int page,
    required int limit,
  });

  /// Cuenta elementos de un usuario
  Future<RepositoryResult<int>> countByUserId(String userId);
}

/// Repositorio específico para entidades con ubicación
abstract class LocationRepository<T> extends BaseRepository<T> {
  /// Obtiene elementos cercanos a coordenadas
  Future<RepositoryResult<List<T>>> getNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Obtiene elementos en un área específica
  Future<RepositoryResult<List<T>>> getInArea({
    required double minLat,
    required double maxLat,
    required double minLon,
    required double maxLon,
  });
}

/// Mixin para repositorios que manejan archivos
mixin FileRepositoryMixin<T> {
  /// Sube un archivo asociado a una entidad
  Future<RepositoryResult<String>> uploadFile({
    required String entityId,
    required String filePath,
    required String fileName,
  });

  /// Descarga un archivo asociado a una entidad
  Future<RepositoryResult<String>> downloadFile({
    required String entityId,
    required String fileName,
  });

  /// Elimina un archivo asociado a una entidad
  Future<RepositoryResult<void>> deleteFile({
    required String entityId,
    required String fileName,
  });
}

/// Mixin para repositorios que manejan cache
mixin CacheRepositoryMixin<T> {
  /// Obtiene datos del cache
  Future<RepositoryResult<T?>> getFromCache(String key);

  /// Guarda datos en cache
  Future<RepositoryResult<void>> saveToCache(String key, T data);

  /// Elimina datos del cache
  Future<RepositoryResult<void>> removeFromCache(String key);

  /// Limpia todo el cache
  Future<RepositoryResult<void>> clearCache();
}
