# Documentación Técnica - FireData Admin

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Configuración](#configuración)
6. [Autenticación y Seguridad](#autenticación-y-seguridad)
7. [Funcionalidades](#funcionalidades)
8. [Instalación y Despliegue](#instalación-y-despliegue)

---

## 🎯 Descripción General

FireData Admin es un panel administrativo web desarrollado en Flutter que permite la gestión administrativa del sistema FireData. Este panel está completamente separado de las aplicaciones móviles por razones de seguridad y automatización.

### Características Principales
- **Panel Web Administrativo**: Interfaz web para administración del sistema
- **Autenticación con is_admin**: Solo bomberos con `is_admin = true` o `1` pueden acceder
- **Gestión de Datos**: Administración de residentes, bomberos, viviendas y grifos
- **Métricas y Estadísticas**: Dashboard con información del sistema
- **Comparte Base de Datos**: Usa la misma base de datos Supabase que las apps móviles

---

## 🏗️ Arquitectura del Sistema

### Patrón de Arquitectura
La aplicación utiliza el patrón **MVC (Model-View-Controller)** con las siguientes capas:

```
┌─────────────────────────────────────┐
│           PRESENTATION LAYER        │
│  (Web Admin Pages, Widgets, UI)     │
├─────────────────────────────────────┤
│            BUSINESS LAYER           │
│    (Admin Services, Controllers)    │
├─────────────────────────────────────┤
│             DATA LAYER              │
│  (Supabase, Models, Repositories)   │
└─────────────────────────────────────┘
```

### Flujo de Autenticación
1. Usuario intenta acceder al panel
2. Sistema verifica `is_admin` en tabla `bombero`
3. Si `is_admin = true` o `1`: Permite acceso
4. Si `is_admin = false`, `0`, `empty`, o `null`: Deniega acceso

---

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework de desarrollo (compilado para web)
- **Dart**: Lenguaje de programación
- **Material Design**: Sistema de diseño de Google

### Backend y Base de Datos
- **Supabase**: Backend as a Service (BaaS)
- **PostgreSQL**: Base de datos relacional
- **Row Level Security (RLS)**: Seguridad a nivel de fila

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.2
  flutter_dotenv: ^5.1.0
```

---

## 📁 Estructura del Proyecto

```
firedata_admin/
├── lib/
│   ├── config/
│   │   └── supabase_config.dart      # Configuración de Supabase
│   ├── models/
│   │   ├── resident.dart            # Modelo de residentes
│   │   ├── residencia.dart          # Modelo de viviendas
│   │   ├── bombero.dart             # Modelo de bomberos
│   │   └── grifo.dart               # Modelo de grifos
│   ├── services/
│   │   └── admin_auth_service.dart  # Servicio de autenticación admin
│   └── web_admin/
│       ├── app_shell.dart           # Shell principal del panel
│       ├── pages/                   # Páginas del panel
│       │   ├── dashboard_page.dart
│       │   ├── residents_page.dart
│       │   ├── firefighters_page.dart
│       │   ├── houses_page.dart
│       │   └── hydrants_page.dart
│       └── services/                # Servicios del panel
│           ├── navigation_service.dart
│           ├── admin_metrics_service.dart
│           ├── residents_admin_service.dart
│           ├── firefighters_admin_service.dart
│           ├── houses_admin_service.dart
│           └── hydrants_admin_service.dart
├── .env                             # Variables de entorno
└── pubspec.yaml                     # Dependencias
```

---

## ⚙️ Configuración

### 1. Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima-aqui
```

**IMPORTANTE**: Debe usar las mismas credenciales que las aplicaciones móviles para compartir la misma base de datos.

### 2. Configuración de Supabase

El panel utiliza la misma base de datos que las apps móviles. Asegúrate de que:
- La tabla `bombero` tenga el campo `is_admin`
- Los bomberos administrativos tengan `is_admin = true` o `1`

---

## 🔐 Autenticación y Seguridad

### Verificación de Acceso Administrativo

El servicio `AdminAuthService` verifica el acceso de la siguiente manera:

```dart
Future<bool> verifyAdminAccess() async {
  // 1. Verificar campo is_admin en tabla bombero (PRINCIPAL)
  final bomberoResponse = await _client
      .from('bombero')
      .select('is_admin')
      .eq('email_b', user.email!)
      .maybeSingle();

  if (bomberoResponse != null) {
    final isAdmin = bomberoResponse['is_admin'];
    // Verificar si is_admin es true, 1, o 'true'
    if (isAdmin == true || isAdmin == 1 || isAdmin == 'true' || isAdmin == '1') {
      return true; // ✅ Tiene acceso
    } else {
      return false; // ❌ NO tiene acceso
    }
  }
  
  // 2. Métodos alternativos (metadatos y profiles)
  // ...
}
```

### Valores que Permiten Acceso
- `true` (booleano)
- `1` (entero)
- `'true'` (string)
- `'1'` (string)

### Valores que Deniegan Acceso
- `false` (booleano)
- `0` (entero)
- `empty` (vacío)
- `null` (nulo)

### Seguridad
- **RLS habilitado**: Las políticas de seguridad de Supabase protegen los datos
- **Verificación en backend**: La verificación se hace consultando la base de datos
- **Sin bypass**: No se puede acceder sin tener `is_admin = true` o `1`

---

## 🚀 Funcionalidades

### Dashboard
- **Métricas generales**: Estadísticas del sistema
- **Resumen de datos**: Información consolidada
- **Gráficos y visualizaciones**: Representación visual de datos

### Gestión de Residentes
- Ver lista de residentes
- Buscar residentes
- Ver detalles de residentes

### Gestión de Bomberos
- Ver lista de bomberos
- Gestionar campo `is_admin`
- Buscar bomberos
- Ver detalles de bomberos

### Gestión de Viviendas
- Ver lista de viviendas
- Buscar viviendas
- Ver detalles de viviendas

### Gestión de Grifos
- Ver lista de grifos
- Ver información completa de grifos (incluyendo notas)
- Buscar grifos
- Ver estadísticas de grifos

---

## 📱 Instalación y Despliegue

### Requisitos Previos
- Flutter SDK 3.9.0 o superior
- Cuenta de Supabase configurada
- Archivo `.env` con las credenciales de Supabase

### Instalación Local

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Configurar variables de entorno:**
   - Crear archivo `.env` con credenciales de Supabase

3. **Ejecutar en modo desarrollo:**
   ```bash
   flutter run -d chrome --dart-define=PREVIEW_ADMIN_PANEL=true
   ```

4. **Ejecutar en producción:**
   ```bash
   flutter run -d chrome
   ```

### Build para Producción

```bash
flutter build web --release
```

### Despliegue Web

1. Compilar la aplicación:
   ```bash
   flutter build web --release
   ```

2. Desplegar el contenido de `build/web/` en tu servidor web

---

## 🔄 Relación con Otras Apps

### Base de Datos Compartida
- **Bomberos**: App móvil para bomberos
- **Residente**: App móvil para residentes
- **firedata_admin**: Panel web administrativo
- Todas comparten la misma base de datos Supabase

### Campo is_admin
El campo `is_admin` en la tabla `bombero` determina qué usuarios pueden acceder al panel administrativo:
- Los bomberos con `is_admin = true` o `1` pueden acceder a firedata_admin
- Los bomberos con `is_admin = false`, `0`, `empty`, o `null` NO pueden acceder

---

## 📝 Notas Importantes

- Este proyecto está completamente separado de las apps móviles
- Comparte la misma base de datos pero tiene su propio código
- Los modelos están duplicados para mantener la independencia
- No hay dependencias entre este proyecto y el proyecto Bomberos
- La autenticación se basa en el campo `is_admin` de la tabla `bombero`

---

*Documentación generada para FireData Admin v1.0.0*
*Última actualización: Diciembre 2024*

