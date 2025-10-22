# Widgets de Bienvenida - Sistema Residente

## Descripción
Este conjunto de widgets proporciona una experiencia de usuario personalizada con mensajes de bienvenida y despedida en la aplicación Residente.

## Widgets Incluidos

### 1. WelcomeBanner
**Archivo**: `welcome_banner.dart`

Banner principal de bienvenida que se muestra en la parte superior de la pantalla principal.

**Características**:
- Saludo personalizado con el nombre del usuario
- Mensaje informativo sobre el sistema
- Botón de cerrar sesión integrado
- Diseño responsivo para tablet y móvil
- Gradiente de colores atractivo

**Uso**:
```dart
WelcomeBanner(
  userName: _registrationData.fullName,
  onLogout: _logout,
  isTablet: isTablet,
)
```

### 2. LogoutDialog
**Archivo**: `logout_dialog.dart`

Dialog de confirmación para cerrar sesión con mensaje personalizado.

**Características**:
- Mensaje personalizado con el nombre del usuario
- Información sobre la seguridad de los datos
- Botones de cancelar y confirmar
- Diseño moderno con iconos

**Uso**:
```dart
LogoutDialog(
  userName: _registrationData.fullName,
  onConfirm: () => Navigator.pop(context, true),
  onCancel: () => Navigator.pop(context, false),
)
```

### 3. WelcomeSnackBar
**Archivo**: `welcome_snackbar.dart`

SnackBar de bienvenida que se muestra cuando el usuario inicia sesión.

**Características**:
- Mensaje de bienvenida personalizado
- Duración de 4 segundos
- Diseño flotante moderno
- Botón de cerrar opcional

**Uso**:
```dart
WelcomeSnackBar.show(context, _registrationData.fullName);
```

### 4. FarewellDialog
**Archivo**: `farewell_dialog.dart`

Dialog de despedida personalizado al cerrar sesión.

**Características**:
- Mensaje de despedida personalizado
- Información sobre la seguridad de los datos
- Confirmación de cierre de sesión
- Diseño amigable con iconos

**Uso**:
```dart
FarewellDialog(
  userName: _registrationData.fullName,
  onConfirm: () async {
    // Lógica de cierre de sesión
  },
)
```

## Integración en la Aplicación

### Pantalla Principal (resident_home.dart)
- **WelcomeBanner**: Reemplaza el AppBar tradicional
- **WelcomeSnackBar**: Se muestra al cargar datos exitosamente
- **FarewellDialog**: Se usa en el método `_logout()`

### Flujo de Usuario
1. **Inicio de sesión**: Se muestra WelcomeSnackBar
2. **Pantalla principal**: Se muestra WelcomeBanner
3. **Cerrar sesión**: Se muestra FarewellDialog

## Personalización

### Colores
Los widgets usan el sistema de colores definido en `app_styles.dart`:
- `AppColors.primary`: Color principal
- `AppColors.textWhite`: Texto blanco
- `AppColors.error`: Color de error
- `AppColors.textWhite70`: Texto blanco con transparencia

### Responsividad
Los widgets se adaptan automáticamente a diferentes tamaños de pantalla:
- **Móvil**: Tamaños de fuente y espaciado reducidos
- **Tablet**: Tamaños de fuente y espaciado aumentados

## Dependencias
- `package:flutter/material.dart`
- `../utils/app_styles.dart`

## Notas de Implementación
- Todos los widgets manejan casos donde el nombre del usuario es `null` o vacío
- Los widgets son completamente responsivos
- Se mantiene consistencia con el diseño general de la aplicación
- Los mensajes son personalizables y pueden ser fácilmente traducidos
