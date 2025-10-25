import 'package:flutter/foundation.dart';
import 'base_database_service.dart';
import 'grupo_familiar_service.dart';
import 'residencia_service.dart';
import 'integrante_service.dart';
import 'mascota_service.dart';
import 'comuna_service.dart';
import 'registro_v_service.dart';
import 'user_data_service.dart';

/// Factory para gestionar instancias de servicios de base de datos
/// 
/// Implementa el patrón Singleton para cada servicio y proporciona
/// acceso centralizado a todos los servicios especializados.
class DatabaseServiceFactory {
  // Instancias singleton de cada servicio
  static final Map<Type, BaseDatabaseService> _services = {};
  
  // Flag para inicialización
  static bool _initialized = false;

  /// Inicializar el factory (opcional, se inicializa automáticamente)
  static void initialize() {
    if (_initialized) return;
    
    debugPrint('🏭 Inicializando DatabaseServiceFactory...');
    
    // Crear instancias de todos los servicios
    _services[GrupoFamiliarService] = GrupoFamiliarService();
    _services[ResidenciaService] = ResidenciaService();
    _services[IntegranteService] = IntegranteService();
    _services[MascotaService] = MascotaService();
    _services[ComunaService] = ComunaService();
    _services[RegistroVService] = RegistroVService();
    _services[UserDataService] = UserDataService();
    
    _initialized = true;
    debugPrint('✅ DatabaseServiceFactory inicializado correctamente');
  }

  /// Obtener un servicio específico
  static T getService<T extends BaseDatabaseService>() {
    // Inicializar si no está inicializado
    if (!_initialized) {
      initialize();
    }
    
    final service = _services[T];
    if (service == null) {
      throw Exception('Servicio no encontrado: $T');
    }
    
    return service as T;
  }

  /// Obtener todos los servicios disponibles
  static Map<Type, BaseDatabaseService> getAllServices() {
    if (!_initialized) {
      initialize();
    }
    
    return Map.unmodifiable(_services);
  }

  /// Verificar si un servicio está disponible
  static bool hasService<T extends BaseDatabaseService>() {
    if (!_initialized) {
      initialize();
    }
    
    return _services.containsKey(T);
  }

  /// Obtener estadísticas de servicios
  static Map<String, dynamic> getServiceStats() {
    if (!_initialized) {
      initialize();
    }
    
    return {
      'total_services': _services.length,
      'services': _services.keys.map((type) => type.toString()).toList(),
      'initialized': _initialized,
    };
  }

  /// Limpiar cache de servicios (para testing)
  static void clearCache() {
    _services.clear();
    _initialized = false;
    debugPrint('🧹 Cache de servicios limpiado');
  }

  /// Reinicializar servicios
  static void reinitialize() {
    clearCache();
    initialize();
  }
}

/// Extensiones para facilitar el acceso a servicios específicos
extension DatabaseServiceFactoryExtensions on DatabaseServiceFactory {
  /// Obtener servicio de grupos familiares
  static GrupoFamiliarService get grupoFamiliar => 
      DatabaseServiceFactory.getService<GrupoFamiliarService>();
  
  /// Obtener servicio de residencias
  static ResidenciaService get residencia => 
      DatabaseServiceFactory.getService<ResidenciaService>();
  
  /// Obtener servicio de integrantes
  static IntegranteService get integrante => 
      DatabaseServiceFactory.getService<IntegranteService>();
  
  /// Obtener servicio de mascotas
  static MascotaService get mascota => 
      DatabaseServiceFactory.getService<MascotaService>();
  
  /// Obtener servicio de comunas
  static ComunaService get comuna => 
      DatabaseServiceFactory.getService<ComunaService>();
  
  /// Obtener servicio de registro_v
  static RegistroVService get registroV => 
      DatabaseServiceFactory.getService<RegistroVService>();
  
  /// Obtener servicio de datos de usuario
  static UserDataService get userData => 
      DatabaseServiceFactory.getService<UserDataService>();
}

/// Clase de conveniencia para acceso rápido a servicios
class DatabaseServices {
  /// Servicio de grupos familiares
  static GrupoFamiliarService get grupoFamiliar => 
      DatabaseServiceFactory.getService<GrupoFamiliarService>();
  
  /// Servicio de residencias
  static ResidenciaService get residencia => 
      DatabaseServiceFactory.getService<ResidenciaService>();
  
  /// Servicio de integrantes
  static IntegranteService get integrante => 
      DatabaseServiceFactory.getService<IntegranteService>();
  
  /// Servicio de mascotas
  static MascotaService get mascota => 
      DatabaseServiceFactory.getService<MascotaService>();
  
  /// Servicio de comunas
  static ComunaService get comuna => 
      DatabaseServiceFactory.getService<ComunaService>();
  
  /// Servicio de registro_v
  static RegistroVService get registroV => 
      DatabaseServiceFactory.getService<RegistroVService>();
  
  /// Servicio de datos de usuario
  static UserDataService get userData => 
      DatabaseServiceFactory.getService<UserDataService>();
}
