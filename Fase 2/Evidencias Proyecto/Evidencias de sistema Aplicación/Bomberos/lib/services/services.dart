// Exporta todos los servicios de la aplicación Bomberos
// 
// Este archivo centraliza todas las importaciones de servicios para facilitar
// su uso en otras partes de la aplicación.

// Clases de resultado
export 'service_result.dart';

// Servicios de autenticación
export 'supabase_auth_service.dart';

// Servicios de datos
export 'grifo_service.dart' hide ServiceResult;
export 'search_service.dart' hide ServiceResult;
export 'address_detail_service.dart';