# Paquete Compartido - Sistema de Bomberos y Residentes

Este paquete contiene componentes y utilidades compartidas entre las aplicaciones de bomberos y residentes.

## Características

### 🎨 Sistema de Diseño
- **Colores**: Sistema de colores unificado con soporte para temas claro y oscuro
- **Tipografía**: Estilos de texto consistentes siguiendo Material Design

### 🛠️ Core
- **Manejo de Errores**: Sistema centralizado para manejo y logging de errores
- **Carga Perezosa**: Sistema de lazy loading para optimización de rendimiento
- **Repositorios**: Clases base para repositorios de datos

## Uso

### Importación
```dart
import 'package:shared_package/shared_package.dart';
```

### Colores
```dart
// Usar colores del sistema
Container(
  color: AppColors.primary,
  child: Text(
    'Texto',
    style: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.textWhite,
    ),
  ),
)
```

### Tipografía
```dart
// Usar estilos de texto
Text(
  'Título',
  style: AppTextStyles.titleLarge,
)

// Personalizar estilos
Text(
  'Texto personalizado',
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.error,
    fontWeight: FontWeight.bold,
  ),
)
```

### Manejo de Errores
```dart
// Registrar errores
ErrorLogger.logError('Error al cargar datos', error);

// Manejar errores
try {
  // Código que puede fallar
} catch (e) {
  ErrorHandler.handleError(e);
}
```

## Estructura

```
lib/
├── design_system/
│   ├── colors/
│   │   └── app_colors.dart
│   └── typography/
│       └── text_styles.dart
├── core/
│   ├── error_handling/
│   ├── lazy_loading/
│   └── utils/
└── repositories/
    └── base_repository.dart
```

## Contribución

Al agregar nuevos componentes:

1. Sigue las convenciones de nomenclatura establecidas
2. Documenta todas las clases y métodos públicos
3. Agrega tests para nueva funcionalidad
4. Actualiza este README si es necesario

## Versión

Versión actual: 1.0.0
