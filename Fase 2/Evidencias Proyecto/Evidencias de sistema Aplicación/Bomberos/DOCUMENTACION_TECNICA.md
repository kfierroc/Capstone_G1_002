# Documentación Técnica - Sistema de Bomberos

## 📋 Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Tecnologías Utilizadas](#tecnologías-utilizadas)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Configuración](#configuración)
6. [Funcionalidades](#funcionalidades)
7. [Base de Datos](#base-de-datos)
8. [Autenticación](#autenticación)
9. [API y Servicios](#api-y-servicios)
10. [Instalación y Despliegue](#instalación-y-despliegue)
11. [Testing](#testing)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Descripción General

El Sistema de Bomberos es una aplicación móvil desarrollada en Flutter que proporciona herramientas especializadas para bomberos en situaciones de emergencia. La aplicación incluye funcionalidades para búsqueda de domicilios, gestión de grifos de agua y protocolos de emergencia.

### Características Principales
- **Aplicación Unificada**: Integra funcionalidades de bomberos y grifos en una sola aplicación
- **Búsqueda de Domicilios**: Sistema de búsqueda en tiempo real de información crítica de domicilios
- **Gestión de Grifos**: Módulo completo para registro y gestión de grifos de agua
- **Autenticación Segura**: Sistema de login/registro con Supabase
- **Interfaz Responsive**: Adaptable a diferentes tamaños de pantalla
- **Modo Emergencia**: Interfaz especializada para situaciones críticas

---

## 🏗️ Arquitectura del Sistema

### Patrón de Arquitectura
La aplicación utiliza el patrón **MVC (Model-View-Controller)** con las siguientes capas:

```
┌─────────────────────────────────────┐
│           PRESENTATION LAYER        │
│  (Screens, Widgets, UI Components)  │
├─────────────────────────────────────┤
│            BUSINESS LAYER           │
│    (Services, Controllers, Logic)   │
├─────────────────────────────────────┤
│             DATA LAYER              │
│  (Supabase, Models, Repositories)   │
└─────────────────────────────────────┘
```

### Flujo de Datos
1. **UI Layer**: Maneja la interacción del usuario
2. **Service Layer**: Procesa la lógica de negocio
3. **Data Layer**: Gestiona la persistencia de datos
4. **Supabase**: Base de datos en la nube

---

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework de desarrollo móvil
- **Dart**: Lenguaje de programación
- **Material Design**: Sistema de diseño de Google

### Backend y Base de Datos
- **Supabase**: Backend as a Service (BaaS)
- **PostgreSQL**: Base de datos relacional
- **Row Level Security (RLS)**: Seguridad a nivel de fila

### Herramientas de Desarrollo
- **Flutter SDK**: ^3.9.0
- **Dart SDK**: ^3.9.0
- **VS Code**: Editor de código recomendado
- **Git**: Control de versiones

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.2
  flutter_dotenv: ^5.1.0
  cupertino_icons: ^1.0.8
```

---

## 📁 Estructura del Proyecto

```
Bomberos/
├── lib/
│   ├── config/                    # Configuración
│   │   └── supabase_config.dart   # Configuración de Supabase
│   ├── constants/                 # Constantes
│   │   ├── grifo_colors.dart     # Colores para módulo grifos
│   │   └── grifo_styles.dart     # Estilos para módulo grifos
│   ├── models/                    # Modelos de datos
│   │   └── grifo.dart            # Modelo de grifo
│   ├── screens/                   # Pantallas
│   │   ├── auth/                 # Autenticación
│   │   │   ├── login.dart
│   │   │   └── register.dart
│   │   ├── grifos/               # Módulo de grifos
│   │   │   ├── grifos_home_screen.dart
│   │   │   └── register_grifo_screen.dart
│   │   └── home/                 # Pantallas principales
│   │       ├── home.dart
│   │       ├── emergency_system_screen.dart
│   │       ├── search_results.dart
│   │       └── address_detail.dart
│   ├── services/                  # Servicios
│   │   ├── supabase_auth_service.dart
│   │   └── mock_auth_service.dart
│   ├── utils/                     # Utilidades
│   │   └── responsive.dart
│   ├── widgets/                   # Widgets reutilizables
│   │   ├── grifo_card.dart
│   │   ├── grifo_stats_section.dart
│   │   ├── grifo_search_section.dart
│   │   └── grifo_map_placeholder.dart
│   └── main.dart                  # Punto de entrada
├── assets/                        # Recursos
├── android/                       # Configuración Android
├── ios/                          # Configuración iOS
├── web/                          # Configuración Web
├── windows/                      # Configuración Windows
├── macos/                        # Configuración macOS
├── linux/                        # Configuración Linux
├── test/                         # Pruebas
├── pubspec.yaml                  # Dependencias
├── env_template.txt              # Plantilla de configuración
└── README.md                     # Documentación básica
```

---

## ⚙️ Configuración

### 1. Configuración de Supabase

#### Crear Proyecto en Supabase
1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una nueva cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Espera a que se complete la configuración

#### Configurar Variables de Entorno
1. Copia el archivo de plantilla:
   ```bash
   cp env_template.txt .env
   ```

2. Edita el archivo `.env` con tus credenciales:
   ```env
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu-clave-anonima-aqui
   ```

3. Obtén las credenciales desde:
   - **URL**: Settings > API > Project URL
   - **Anon Key**: Settings > API > Project API keys > anon public

### 2. Configuración del Esquema de Base de Datos

Ejecuta el script `supabase_schema.sql` en el SQL Editor de Supabase:

```sql
-- Crear tablas necesarias
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS bombero (
  rut_num INTEGER PRIMARY KEY,
  rut_dv VARCHAR(1),
  email_b VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS domicilio (
  id SERIAL PRIMARY KEY,
  direccion TEXT NOT NULL,
  comuna VARCHAR(100),
  region VARCHAR(100),
  coordenadas POINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bombero ENABLE ROW LEVEL SECURITY;
ALTER TABLE domicilio ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Public read access for domicilio" ON domicilio
  FOR SELECT USING (true);
```

---

## 🚀 Funcionalidades

### 1. Sistema de Autenticación

#### Login
- **Ruta**: `/login`
- **Funcionalidad**: Autenticación con email y contraseña
- **Validaciones**: Email válido, contraseña requerida
- **Integración**: Supabase Auth

#### Registro
- **Ruta**: `/register`
- **Funcionalidad**: Registro de nuevos usuarios
- **Campos**: Email, contraseña, nombre completo, RUT, compañía
- **Validaciones**: Email único, RUT válido, contraseña segura

#### Logout
- **Funcionalidad**: Cierre de sesión seguro
- **Limpieza**: Elimina tokens y datos de sesión
- **Redirección**: Vuelve a la pantalla de login

### 2. Pantalla Principal

#### Búsqueda de Domicilios
- **Campo de búsqueda**: Input para dirección
- **Búsqueda en tiempo real**: Consulta base de datos
- **Resultados**: Lista de domicilios encontrados
- **Navegación**: Detalles del domicilio seleccionado

#### Botón de Grifos
- **Texto**: "Consultar Grifos de Agua"
- **Icono**: Gota de agua
- **Color**: Azul
- **Funcionalidad**: Navega directamente al módulo de grifos

### 3. Sistema de Emergencias

#### Alerta de Emergencia
- **Indicador visual**: Banner rojo con icono de emergencia
- **Texto**: "🚨 MODO EMERGENCIA ACTIVO"
- **Descripción**: Instrucciones para situaciones críticas

#### Búsqueda Especializada
- **Campo optimizado**: Para direcciones de emergencia
- **Placeholder**: "Ej: Av. Libertador 1234, Las Condes"
- **Búsqueda rápida**: Resultados inmediatos

#### Guía Rápida
- **Protocolos de emergencia**: Lista de procedimientos
- **Instrucciones**: Para situaciones críticas
- **Información de contacto**: Números de emergencia

### 4. Módulo de Grifos

#### Pantalla Principal de Grifos
- **Lista de grifos**: Todos los grifos registrados con información completa
- **Filtros**: Por estado (Operativo, Dañado, Mantenimiento, Sin verificar)
- **Búsqueda**: Por dirección o comuna
- **Estadísticas**: Contadores por estado con diseño moderno
- **Diseño responsive**: Adaptado a móvil, tablet y desktop

#### Registro de Grifos
- **Formulario completo**: Dirección, comuna, tipo, estado
- **Coordenadas**: Latitud y longitud con validación
- **Notas**: Información adicional
- **Validaciones**: Campos requeridos
- **Diseño responsive**: Optimizado para diferentes tamaños de pantalla

#### Gestión de Estados
- **Cambio de estado**: Desde la lista de grifos con confirmación visual
- **Estados disponibles**: Operativo, Dañado, Mantenimiento, Sin verificar
- **Actualización**: En tiempo real con retroalimentación visual
- **Colores distintivos**: Verde, Rojo, Amarillo, Gris según estado

#### Estadísticas
- **Total de grifos**: Contador general
- **Por estado**: Contadores específicos con iconos
- **Visualización**: Tarjetas modernas con iconos y colores
- **Actualización automática**: Se actualiza al cambiar estados

#### Mapa Interactivo
- **Vista geográfica**: Muestra todos los grifos en un mapa
- **Leyenda de estados**: Colores identificables por estado
- **Estadísticas visuales**: Contadores por estado
- **Responsive**: Adaptado a diferentes tamaños de pantalla

---

## 🗄️ Base de Datos

### Esquema de Tablas

#### Tabla: `profiles`
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  PRIMARY KEY (id)
);
```

#### Tabla: `bombero`
```sql
CREATE TABLE bombero (
  rut_num INTEGER PRIMARY KEY,
  rut_dv VARCHAR(1),
  email_b VARCHAR(255) UNIQUE
);
```

#### Tabla: `domicilio`
```sql
CREATE TABLE domicilio (
  id SERIAL PRIMARY KEY,
  direccion TEXT NOT NULL,
  comuna VARCHAR(100),
  region VARCHAR(100),
  coordenadas POINT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Relaciones
- `profiles.id` → `auth.users.id` (1:1)
- `bombero.email_b` → `auth.users.email` (1:1)
- `domicilio` es independiente (sin relaciones foráneas)

### Índices Recomendados
```sql
-- Índice para búsqueda de domicilios
CREATE INDEX idx_domicilio_direccion ON domicilio USING gin(to_tsvector('spanish', direccion));

-- Índice para búsqueda por comuna
CREATE INDEX idx_domicilio_comuna ON domicilio(comuna);
```

---

## 🔐 Autenticación

### Flujo de Autenticación

1. **Inicio de Sesión**:
   ```dart
   final authService = SupabaseAuthService();
   final result = await authService.signInWithPassword(
     email: email,
     password: password,
   );
   ```

2. **Verificación de Sesión**:
   ```dart
   final user = SupabaseConfig.client.auth.currentUser;
   if (user != null) {
     // Usuario autenticado
   }
   ```

3. **Cierre de Sesión**:
   ```dart
   await SupabaseConfig.client.auth.signOut();
   ```

### Seguridad

#### Row Level Security (RLS)
- **Habilitado**: En todas las tablas
- **Políticas**: Usuarios solo pueden acceder a sus propios datos
- **Excepción**: Tabla `domicilio` es de lectura pública

#### Validaciones
- **Email**: Formato válido
- **Contraseña**: Mínimo 6 caracteres
- **RUT**: Formato chileno válido

---

## 🔌 API y Servicios

### SupabaseAuthService

#### Métodos Principales
```dart
class SupabaseAuthService {
  // Iniciar sesión
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  });

  // Registrar usuario
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String rut,
    required String company,
  });

  // Cerrar sesión
  Future<void> signOut();

  // Recuperar contraseña
  Future<AuthResult> resetPassword(String email);
}
```

### SupabaseConfig

#### Configuración
```dart
class SupabaseConfig {
  // Inicializar Supabase
  static Future<void> initialize();

  // Obtener cliente
  static SupabaseClient get client;

  // Obtener cliente de auth
  static GoTrueClient get auth;

  // Verificar configuración
  static bool get isConfigured;
}
```

---

## 📱 Instalación y Despliegue

### Requisitos Previos
- **Flutter SDK**: ^3.9.0
- **Dart SDK**: ^3.9.0
- **Android Studio**: Para desarrollo Android
- **Xcode**: Para desarrollo iOS (macOS)
- **Git**: Control de versiones

### Instalación Local

1. **Clonar repositorio**:
   ```bash
   git clone <repository-url>
   cd Bomberos
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**:
   ```bash
   cp env_template.txt .env
   # Editar .env con tus credenciales
   ```

4. **Configurar Supabase**:
   - Crear proyecto en Supabase
   - Ejecutar script `supabase_schema.sql`
   - Configurar credenciales en `.env`

5. **Ejecutar aplicación**:
   ```bash
   flutter run
   ```

### Compilación para Producción

#### Android APK
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

### Despliegue en App Stores

#### Google Play Store
1. Generar APK firmado
2. Crear cuenta de desarrollador
3. Subir APK a Google Play Console
4. Configurar metadatos y capturas

#### Apple App Store
1. Generar IPA firmado
2. Crear cuenta de desarrollador
3. Subir a App Store Connect
4. Configurar metadatos y capturas

---

## 🧪 Testing

### Tipos de Pruebas

#### Unit Tests
```dart
// Ejemplo de prueba unitaria
test('should return user data when login is successful', () async {
  // Arrange
  final authService = SupabaseAuthService();
  
  // Act
  final result = await authService.signInWithPassword(
    email: 'test@example.com',
    password: 'password123',
  );
  
  // Assert
  expect(result.isSuccess, true);
  expect(result.user?.email, 'test@example.com');
});
```

#### Widget Tests
```dart
// Ejemplo de prueba de widget
testWidgets('should display login form', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

#### Integration Tests
```dart
// Ejemplo de prueba de integración
testWidgets('should complete login flow', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Llenar formulario
  await tester.enterText(find.byKey(Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  
  // Presionar botón
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  // Verificar navegación
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

### Ejecutar Pruebas
```bash
# Todas las pruebas
flutter test

# Pruebas específicas
flutter test test/widget_test.dart

# Pruebas de integración
flutter drive --target=test_driver/app.dart
```

---

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Error de Configuración de Supabase
**Síntoma**: Error al inicializar Supabase
**Solución**:
```bash
# Verificar archivo .env
cat .env

# Verificar credenciales en Supabase
# Settings > API > Project URL y anon key
```

#### 2. Error de Compilación
**Síntoma**: Error al ejecutar `flutter run`
**Solución**:
```bash
# Limpiar caché
flutter clean

# Reinstalar dependencias
flutter pub get

# Verificar versión de Flutter
flutter doctor
```

#### 3. Error de Autenticación
**Síntoma**: No se puede iniciar sesión
**Solución**:
- Verificar que el usuario existe en Supabase Auth
- Verificar que RLS está configurado correctamente
- Verificar políticas de seguridad

#### 4. Error de Búsqueda
**Síntoma**: No se encuentran resultados de búsqueda
**Solución**:
- Verificar que la tabla `domicilio` tiene datos
- Verificar que los índices están creados
- Verificar permisos de lectura

### Logs y Debugging

#### Habilitar Logs de Supabase
```dart
// En main.dart
void main() {
  // Habilitar logs de debug
  Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: true, // Habilitar logs
  );
}
```

#### Logs de Flutter
```bash
# Ver logs en tiempo real
flutter logs

# Ver logs específicos de la app
flutter logs --app-id com.example.bomberos
```

### Contacto y Soporte

#### Recursos Útiles
- **Documentación Flutter**: [https://docs.flutter.dev](https://docs.flutter.dev)
- **Documentación Supabase**: [https://supabase.com/docs](https://supabase.com/docs)
- **Stack Overflow**: Para preguntas técnicas
- **GitHub Issues**: Para reportar bugs

#### Información del Sistema
```bash
# Información de Flutter
flutter doctor -v

# Información del dispositivo
flutter devices

# Información de la app
flutter run --verbose
```

---

## 📊 Métricas y Monitoreo

### Métricas de Rendimiento
- **Tiempo de carga**: < 3 segundos
- **Memoria utilizada**: < 100MB
- **Tamaño de APK**: < 50MB

### Métricas de Uso
- **Usuarios activos**: Monitoreo en Supabase Dashboard
- **Búsquedas realizadas**: Logs de la tabla `domicilio`
- **Grifos registrados**: Contadores en tiempo real

### Alertas
- **Errores de autenticación**: Monitoreo en Supabase
- **Fallos de búsqueda**: Logs de aplicación
- **Problemas de conectividad**: Retry automático

---

## 🔄 Actualizaciones y Mantenimiento

### Versionado
- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Changelog**: Documentación de cambios
- **Release Notes**: Notas de versión

### Actualizaciones de Dependencias
```bash
# Verificar dependencias obsoletas
flutter pub outdated

# Actualizar dependencias
flutter pub upgrade

# Verificar compatibilidad
flutter pub deps
```

### Backup y Recuperación
- **Base de datos**: Backup automático en Supabase
- **Código**: Control de versiones con Git
- **Configuración**: Documentación en README

---

## 📝 Conclusión

El Sistema de Bomberos es una aplicación robusta y escalable que proporciona herramientas esenciales para bomberos en situaciones de emergencia. La integración con Supabase asegura un backend confiable y escalable, mientras que Flutter proporciona una experiencia de usuario nativa y responsive.

### Características Destacadas
- ✅ **Aplicación unificada** con funcionalidades completas
- ✅ **Autenticación segura** con Supabase
- ✅ **Búsqueda en tiempo real** de domicilios
- ✅ **Gestión completa de grifos**
- ✅ **Interfaz responsive** y moderna
- ✅ **Código limpio** y bien documentado

### Próximos Pasos
1. **Testing exhaustivo** en dispositivos reales
2. **Optimización de rendimiento**
3. **Implementación de notificaciones push**
4. **Integración con mapas en tiempo real**
5. **Analytics y métricas de uso**

---

*Documentación generada para el Sistema de Bomberos v1.0.0*
*Última actualización: Diciembre 2024*
