import 'error_types.dart';

/// Mensajes de error amigables para el usuario
/// Centralizados para mantener consistencia en toda la aplicación
class ErrorMessages {
  ErrorMessages._();

  // Mensajes genéricos
  static const String genericError = 'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.';
  static const String unknownError = 'Error desconocido. Contacta al soporte técnico si persiste.';

  // Errores de red
  static const String networkError = 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
  static const String timeoutError = 'La operación tardó demasiado. Verifica tu conexión e intenta nuevamente.';

  // Errores de autenticación
  static const String authenticationError = 'Error de autenticación. Por favor, inicia sesión nuevamente.';
  static const String sessionExpiredError = 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
  static const String permissionError = 'No tienes permisos para realizar esta acción.';

  // Errores de validación
  static const String validationError = 'Los datos ingresados no son válidos. Por favor, revisa e intenta nuevamente.';
  static const String requiredFieldError = 'Este campo es obligatorio.';
  static const String invalidFormatError = 'El formato de los datos no es correcto.';

  // Errores de base de datos
  static const String databaseError = 'Error de base de datos. Por favor, intenta nuevamente más tarde.';
  static const String duplicateError = 'Este registro ya existe. Por favor, verifica los datos ingresados.';
  static const String referentialIntegrityError = 'No se puede realizar esta acción debido a datos relacionados.';

  // Errores de formato
  static const String formatError = 'Error en el formato de los datos. Por favor, verifica e intenta nuevamente.';
  static const String jsonFormatError = 'Error en el formato de datos. Contacta al soporte técnico.';

  // Errores de estado
  static const String stateError = 'El estado de la aplicación no es válido. Por favor, reinicia la aplicación.';
  static const String invalidStateError = 'Operación no válida en el estado actual.';

  // Errores de configuración
  static const String configurationError = 'Error de configuración. Contacta al soporte técnico.';
  static const String missingConfigurationError = 'Configuración faltante. Contacta al soporte técnico.';

  // Errores de servicios externos
  static const String externalServiceError = 'Error en servicio externo. Por favor, intenta nuevamente más tarde.';
  static const String serviceUnavailableError = 'Servicio no disponible. Por favor, intenta más tarde.';

  // Errores de parseo
  static const String parsingError = 'Error al procesar los datos. Contacta al soporte técnico.';
  static const String dataCorruptionError = 'Los datos están corruptos. Contacta al soporte técnico.';

  // Mensajes específicos por operación
  static const String saveError = 'Error al guardar los datos. Por favor, intenta nuevamente.';
  static const String loadError = 'Error al cargar los datos. Por favor, intenta nuevamente.';
  static const String deleteError = 'Error al eliminar el registro. Por favor, intenta nuevamente.';
  static const String updateError = 'Error al actualizar los datos. Por favor, intenta nuevamente.';

  // Mensajes específicos para módulos
  static const String grifoSaveError = 'Error al guardar el grifo. Verifica los datos e intenta nuevamente.';
  static const String grifoLoadError = 'Error al cargar los grifos. Por favor, intenta nuevamente.';
  static const String grifoDeleteError = 'Error al eliminar el grifo. Por favor, intenta nuevamente.';

  static const String familyMemberSaveError = 'Error al guardar el integrante familiar. Verifica los datos e intenta nuevamente.';
  static const String familyMemberLoadError = 'Error al cargar los integrantes familiares. Por favor, intenta nuevamente.';
  static const String familyMemberDeleteError = 'Error al eliminar el integrante familiar. Por favor, intenta nuevamente.';

  static const String petSaveError = 'Error al guardar la mascota. Verifica los datos e intenta nuevamente.';
  static const String petLoadError = 'Error al cargar las mascotas. Por favor, intenta nuevamente.';
  static const String petDeleteError = 'Error al eliminar la mascota. Por favor, intenta nuevamente.';

  static const String residenceSaveError = 'Error al guardar la información de residencia. Verifica los datos e intenta nuevamente.';
  static const String residenceLoadError = 'Error al cargar la información de residencia. Por favor, intenta nuevamente.';
  static const String residenceUpdateError = 'Error al actualizar la información de residencia. Por favor, intenta nuevamente.';

  // Mensajes de éxito
  static const String saveSuccess = 'Datos guardados exitosamente.';
  static const String updateSuccess = 'Datos actualizados exitosamente.';
  static const String deleteSuccess = 'Registro eliminado exitosamente.';

  // Mensajes informativos
  static const String noDataFound = 'No se encontraron datos.';
  static const String loadingData = 'Cargando datos...';
  static const String savingData = 'Guardando datos...';
  static const String processingData = 'Procesando datos...';

  /// Obtiene un mensaje específico basado en el tipo de error y operación
  static String getMessageForOperation(ErrorType errorType, String operation) {
    switch (operation.toLowerCase()) {
      case 'save':
      case 'create':
      case 'insert':
        return _getSaveMessage(errorType);
      case 'load':
      case 'get':
      case 'fetch':
        return _getLoadMessage(errorType);
      case 'update':
      case 'modify':
        return _getUpdateMessage(errorType);
      case 'delete':
      case 'remove':
        return _getDeleteMessage(errorType);
      default:
        return _getGenericMessage(errorType);
    }
  }

  static String _getSaveMessage(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Error de conexión al guardar. Verifica tu internet e intenta nuevamente.';
      case ErrorType.validation:
        return 'Los datos no son válidos. Revisa la información e intenta nuevamente.';
      case ErrorType.duplicate:
        return 'Este registro ya existe. Verifica los datos ingresados.';
      case ErrorType.permission:
        return 'No tienes permisos para guardar este registro.';
      default:
        return saveError;
    }
  }

  static String _getLoadMessage(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Error de conexión al cargar datos. Verifica tu internet e intenta nuevamente.';
      case ErrorType.authentication:
        return 'Error de autenticación al cargar datos. Inicia sesión nuevamente.';
      case ErrorType.permission:
        return 'No tienes permisos para acceder a estos datos.';
      default:
        return loadError;
    }
  }

  static String _getUpdateMessage(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Error de conexión al actualizar. Verifica tu internet e intenta nuevamente.';
      case ErrorType.validation:
        return 'Los datos no son válidos. Revisa la información e intenta nuevamente.';
      case ErrorType.permission:
        return 'No tienes permisos para actualizar este registro.';
      default:
        return updateError;
    }
  }

  static String _getDeleteMessage(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return 'Error de conexión al eliminar. Verifica tu internet e intenta nuevamente.';
      case ErrorType.referentialIntegrity:
        return 'No se puede eliminar este registro porque está siendo usado en otra parte del sistema.';
      case ErrorType.permission:
        return 'No tienes permisos para eliminar este registro.';
      default:
        return deleteError;
    }
  }

  static String _getGenericMessage(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return networkError;
      case ErrorType.authentication:
        return authenticationError;
      case ErrorType.validation:
        return validationError;
      case ErrorType.duplicate:
        return duplicateError;
      case ErrorType.referentialIntegrity:
        return referentialIntegrityError;
      case ErrorType.permission:
        return permissionError;
      case ErrorType.timeout:
        return timeoutError;
      case ErrorType.format:
        return formatError;
      case ErrorType.state:
        return stateError;
      case ErrorType.database:
        return databaseError;
      case ErrorType.configuration:
        return configurationError;
      case ErrorType.externalService:
        return externalServiceError;
      case ErrorType.parsing:
        return parsingError;
      case ErrorType.unknown:
        return genericError;
    }
  }
}
