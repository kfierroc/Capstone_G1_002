// Exporta todos los servicios refactorizados de la aplicación Bomberos
// 
// Este archivo centraliza todas las importaciones de servicios refactorizados
// aplicando principios SOLID y Clean Code

// Clase de resultado
export 'service_result.dart';

// Servicios base
export 'grifo/grifo_service_refactored.dart';
export 'info_grifo/info_grifo_service.dart';
export 'comuna/comuna_service.dart';
export 'estadisticas/estadisticas_service.dart';

// Servicios de autenticación
export 'supabase_auth_service.dart';

// Servicios de datos
export 'search_service.dart' hide ServiceResult;
export 'address_detail_service.dart';

// Utilidades comunes
export '../utils/common_utilities.dart';
export '../utils/validation_system.dart';
export '../utils/responsive_constants.dart';
