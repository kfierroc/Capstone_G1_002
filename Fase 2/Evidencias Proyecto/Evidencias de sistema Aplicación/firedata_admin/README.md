# FireData Admin - Panel Administrativo Web

Panel administrativo web separado para la gestión de FireData. Este proyecto está completamente independiente de la aplicación móvil de Bomberos por razones de seguridad y automatización.

## 🚀 Inicio Rápido

### Requisitos Previos

- Flutter SDK 3.9.0 o superior
- Cuenta de Supabase configurada
- Archivo `.env` con las credenciales de Supabase

### Configuración

1. **Clonar/Copiar el proyecto:**
   ```bash
   cd firedata_admin
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno:**
   - Crea un archivo `.env` en la raíz del proyecto
   - Agrega tus credenciales de Supabase:
     ```
     SUPABASE_URL=tu_url_de_supabase
     SUPABASE_ANON_KEY=tu_clave_anonima
     ```

4. **Ejecutar en modo desarrollo (con vista previa):**
   ```bash
   flutter run -d chrome --dart-define=PREVIEW_ADMIN_PANEL=true
   ```

5. **Ejecutar en producción:**
   ```bash
   flutter run -d chrome
   ```

## 📁 Estructura del Proyecto

```
lib/
├── config/
│   └── supabase_config.dart      # Configuración de Supabase
├── models/
│   ├── resident.dart            # Modelo de residentes
│   ├── residencia.dart          # Modelo de viviendas
│   ├── bombero.dart             # Modelo de bomberos
│   └── grifo.dart               # Modelo de grifos
├── services/
│   └── admin_auth_service.dart  # Servicio de autenticación admin
└── web_admin/
    ├── app_shell.dart           # Shell principal del panel
    ├── pages/                   # Páginas del panel
    │   ├── dashboard_page.dart
    │   ├── residents_page.dart
    │   ├── firefighters_page.dart
    │   ├── houses_page.dart
    │   └── hydrants_page.dart
    ├── services/                # Servicios del panel
    │   ├── navigation_service.dart
    │   ├── admin_metrics_service.dart
    │   ├── residents_admin_service.dart
    │   ├── firefighters_admin_service.dart
    │   ├── houses_admin_service.dart
    │   └── hydrants_admin_service.dart
    └── widgets/
        └── admin_sidebar.dart   # Barra lateral de navegación
```

## 🔐 Seguridad

- El panel requiere que el usuario tenga rol `admin` en Supabase
- La verificación se hace mediante `user_metadata.roles` o tabla `profiles`
- En modo producción, solo usuarios autenticados con rol admin pueden acceder

## 🛠️ Desarrollo

### Modo Vista Previa

Para desarrollo sin necesidad de autenticación:
```bash
flutter run -d chrome --dart-define=PREVIEW_ADMIN_PANEL=true
```

### Build para Producción

```bash
flutter build web --release
```

## 📝 Notas

- Este proyecto está completamente separado de la app móvil de Bomberos
- Comparte la misma base de datos (Supabase) pero tiene su propio código
- Los modelos están duplicados para mantener la independencia
- No hay dependencias entre este proyecto y el proyecto Bomberos

## 🔄 Actualizaciones

Para actualizar el panel con cambios de la base de datos:
1. Actualiza los modelos en `lib/models/`
2. Actualiza los servicios en `lib/web_admin/services/`
3. Verifica que los imports estén correctos
