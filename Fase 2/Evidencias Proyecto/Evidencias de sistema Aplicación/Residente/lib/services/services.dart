// Exporta todos los servicios de la aplicación Residente
// 
// Este archivo centraliza todas las importaciones de servicios para facilitar
// su uso en otras partes de la aplicación.

// Servicios de autenticación
export 'unified_auth_service.dart';
export 'supabase_auth_service.dart' hide UserData, AuthResult;

// Servicios de datos
export 'residencia_service.dart';
export 'grupofamiliar_service.dart';

// Servicios existentes (compatibilidad)
export 'auth_service.dart' hide AuthResult;
export 'database_service.dart';
