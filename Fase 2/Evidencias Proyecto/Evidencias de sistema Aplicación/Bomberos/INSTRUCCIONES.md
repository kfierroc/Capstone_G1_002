# 🚒 Aplicación Bomberos - Instrucciones de Configuración

## 🔧 Configuración Inicial

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar Supabase

1. Crea un archivo `.env` en la raíz de este proyecto (junto a `pubspec.yaml`)
2. Copia el contenido de `.env.example`
3. Reemplaza los valores con tus credenciales reales de Supabase:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon-aqui
```

**Nota:** Este proyecto comparte la misma base de datos con la aplicación Grifos. Usa las mismas credenciales en ambos proyectos.

### 3. Ejecutar la Aplicación

```bash
flutter run
```

## 📱 Características

- ✅ Registro de usuarios con validación de RUT chileno
- ✅ Inicio de sesión seguro con Supabase
- ✅ Recuperación de contraseña por email
- ✅ Diseño responsivo para móvil, tablet y desktop
- ✅ Base de datos compartida con la aplicación Grifos

## 🔑 Autenticación

Esta aplicación usa **Supabase** para autenticación y almacenamiento de datos. Los usuarios registrados en esta aplicación pueden también iniciar sesión en la aplicación Grifos con las mismas credenciales.

## 📊 Estructura de la Base de Datos

La tabla `profiles` contiene:
- `id`: UUID del usuario (referencia a auth.users)
- `full_name`: Nombre completo
- `rut`: RUT chileno (único)
- `fire_company`: Nombre de la compañía de bomberos
- `email`: Email del usuario
- `created_at`: Fecha de creación
- `updated_at`: Fecha de última actualización

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo
- **Supabase**: Backend y autenticación
- **flutter_dotenv**: Gestión de variables de entorno
- **supabase_flutter**: Cliente de Supabase para Flutter

## 📖 Más Información

Para instrucciones detalladas sobre cómo configurar Supabase desde cero, consulta el archivo `CONFIGURACION_SUPABASE.md` en la carpeta raíz del proyecto.

