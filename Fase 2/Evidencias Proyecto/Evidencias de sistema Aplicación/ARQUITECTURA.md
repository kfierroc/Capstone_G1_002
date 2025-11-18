# 🏗️ Arquitectura Compartida - Sistema de Autenticación

Este documento explica cómo funciona la arquitectura compartida entre las aplicaciones **Bomberos**, **Grifos** y **Residente**, permitiendo que usuarios compartan credenciales (opcional) entre las apps.

## 🔐 Sistema de Autenticación Actualizado

### Características Implementadas

#### 1. **Registro en 2 Pasos (Bomberos)** - Verificación de correo deshabilitada
- **Paso 1**: Email y contraseña (con confirmación)
- **Paso 2**: Completar datos (nombre, apellido, RUT, compañía)
- **NOTA**: La verificación de correo electrónico está comentada, los usuarios pueden continuar sin verificar

#### 2. **Registro en 3 Pasos (Residente)**
- **Paso 1**: Email y contraseña (con confirmación)
- **Paso 2**: Verificación de email con código OTP de 6 dígitos + opción de "Saltar"
- **Paso 3**: Datos del titular, residencia y vivienda (wizard completo)

#### 3. **Reset de Contraseña con Código OTP**
- Envía código OTP de 6 dígitos al email
- Valida que el email esté registrado
- Permite cambiar contraseña con código
- Funciona en ambas aplicaciones

#### 4. **Validación de Roles Entre Apps**
- Bomberos valida que el usuario NO sea residente
- Residente valida que el usuario NO sea bombero
- Mensajes claros de redirección

#### 5. **Diseño Unificado Verde**
- Todas las pantallas de autenticación usan el estilo verde degradado
- Círculos blancos con iconos
・Diseño consistente entre apps

---

## 📊 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                        SUPABASE CLOUD                       │
│                                                             │
│  ┌──────────────────┐    ┌──────────────┐   ┌───────────┐ │
│  │   auth.users     │    │   bombero    │   │grupofamil│ │
│  │                  │    │              │   │   iar     │ │
│  │ - id (UUID)      │    │ - rut_num    │   │ - id_grup│ │
│  │ - email          │    │ - email_b    │   │ - email   │ │
│  │ - password (enc) │    │ - nomb_bombr │   │ - rut_tit │ │
│  └──────────────────┘    └──────────────┘   └───────────┘ │
│                                                             │
│              Row Level Security (RLS) Habilitado           │
│              + Validación de Roles Entre Apps              │
└─────────────────────────────────────────────────────────────┘
                          ▲         ▲
                          │         │
                  Mismas credenciales (.env)
                  SUPABASE_URL + SUPABASE_ANON_KEY
                          │         │
              ┌───────────┴─────────┴───────────┐
              │                                 │
    ┌─────────▼────────┐                       ┌───────────▼─────────┐
    │   APP BOMBEROS   │                       │   APP RESIDENTE     │
    │                  │                       │                     │
    │  ✅ Valida       │                       │  ✅ Valida          │
    │     en bombero   │                       │     NO está en      │
    │                  │                       │     bombero         │
    │  ✅ Mapa de      │                       │  ✅ Wizard 4 pasos  │
    │     grifos       │                       │  ✅ Registro        │
    │                  │                       │     completo        │
    │  Login/Register  │                       │  Login/Wizard       │
    └──────────────────┘                       └─────────────────────┘
```

---

## 🔑 Concepto Clave: Una Base de Datos, Múltiples Apps

### ¿Cómo funciona?

#### Opción 1: Base de Datos Compartida (Bomberos + Grifos + Residente)

1. **Las tres apps se conectan al mismo proyecto Supabase**
   - Usan la misma URL
   - Usan la misma clave anon
   - Acceden a las mismas tablas

2. **Un usuario registrado en cualquier app puede usar las otras**
   - El email y contraseña funcionan en las tres
   - Los datos del perfil son los mismos
   - No necesita registrarse múltiples veces

3. **Los cambios se sincronizan automáticamente**
   - Cambios en el perfil se reflejan en todas las apps
   - Cambio de contraseña aplica a todas

#### Opción 2: Base de Datos Separada (Residente independiente)

1. **Bomberos y Grifos comparten una BD**
2. **Residente usa otra BD diferente**
3. **Útil si quieres separar usuarios de residentes vs. personal**

---

## 📱 Servicios de Autenticación Actualizados

### Ubicación de Servicios:
- `Bomberos/lib/services/supabase_auth_service.dart`
- `Grifos/lib/services/supabase_auth_service.dart`
- `Residente/lib/services/unified_auth_service.dart`

### Nuevos Métodos en Bomberos:

```dart
// Registro temporal para verificación de email
Future<AuthResult> registerWithEmail(String email, String password)

// Verificar código de email OTP
Future<AuthResult> verifyEmailCode(String code)

// Reenviar código de verificación
Future<AuthResult> resendEmailVerification({required String email})

// Reset con código OTP - Enviar código
Future<AuthResult> resetPassword(String email)

// Reset con código OTP - Cambiar contraseña
Future<AuthResult> resetPasswordWithCode({
  required String email, 
  required String code, 
  required String newPassword
})
```

### Nuevos Métodos en Residente:

```dart
// Registro con verificación de email
Future<AuthResult> registerWithEmail(String email, String password, {bool sendEmailVerification = false})

// Verificar código OTP
Future<AuthResult> verifyEmailCode(String code)

// Reenviar código de verificación
Future<AuthResult> resendEmailVerification({required String email})

// Reset con código OTP
Future<AuthResult> resetPassword(String email)
Future<AuthResult> resetPasswordWithCode({required String email, required String code, required String newPassword})
```

---

## 🔧 Componentes Compartidos

### 1. Archivo .env (Idéntico en todas las apps)

**Ubicación:**
- `Bomberos/.env`
- `Residente/.env`

**Contenido (IDÉNTICO si quieres compartir usuarios):**
```env
SUPABASE_URL=https://tuproyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon-aqui
```

**¿Por qué idéntico?**
- Para que las apps se conecten al mismo proyecto
- Si usaran diferentes credenciales, serían bases de datos separadas

**Nota:** Si quieres bases de datos separadas, usa credenciales diferentes para cada app.

### 🔒 Validación de Roles

**Nueva funcionalidad implementada:**
- La app de **Bomberos** valida que el usuario no esté registrado como residente
- La app de **Residente** valida que el usuario no esté registrado como bombero
- Previene que un usuario pueda iniciar sesión en la aplicación incorrecta

---

### 2. supabase_config.dart (Idéntico en ambas apps)

**Ubicación:**
- `Bomberos/lib/config/supabase_config.dart`
- `Grifos/lib/config/supabase_config.dart`
- `Residente/lib/config/supabase_config.dart` (con PKCE adicional)

**Función:**
```dart
class SupabaseConfig {
  // Lee credenciales del .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Inicializa conexión
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Acceso al cliente
  static SupabaseClient get client => Supabase.instance.client;
}
```

**Flujo de ejecución:**
```
App inicia
    ↓
Lee .env
    ↓
Conecta con Supabase usando URL + anon key
    ↓
Ahora la app puede:
  - Autenticar usuarios
  - Leer/escribir en profiles
  - Manejar sesiones
```

---

### 3. Servicios de Autenticación

**Ubicación:**
- `Bomberos/lib/services/supabase_auth_service.dart`
- `Grifos/lib/services/supabase_auth_service.dart`
- `Residente/lib/services/auth_service.dart` (versión mejorada)

**Diferencias:**
- Bomberos y Grifos usan `supabase_auth_service.dart` (idéntico)
- Residente usa `auth_service.dart` (más avanzado):
  - Logs detallados
  - Metadata para datos adicionales
  - PKCE para mayor seguridad
  - Traducción mejorada de errores

**Métodos principales:**

#### signInWithPassword()
```dart
// Lo que hace:
// 1. Envía email y contraseña a Supabase
// 2. Supabase valida contra auth.users
// 3. Si es correcto, retorna token de sesión
// 4. Obtiene datos adicionales de profiles
// 5. Retorna todo junto
```

#### signUp()
```dart
// Lo que hace:
// 1. Crea usuario en auth.users (Supabase Auth)
// 2. Guarda datos adicionales en profiles (nuestra tabla)
// 3. Si el paso 2 falla, elimina el usuario del paso 1 (rollback)
// 4. Retorna éxito o error
```

#### resetPassword() - Método actualizado con OTP
```dart
// Lo que hace:
// 1. Valida que el email esté registrado
// 2. Envía código OTP de 6 dígitos al email
// 3. Usuario ingresa código en la app
// 4. Usuario ingresa nueva contraseña
// 5. El sistema valida el código y actualiza la contraseña
// 6. La nueva contraseña funciona en todas las apps
```

#### Pantallas de Autenticación

**Bomberos:**
- `/register-step1` → Email y contraseña
- `/register-step2` → Verificación de email con OTP
- `/register-step3` → Completar datos del bombero
- `/code-reset` → Reset de contraseña con código

**Residente:**
- `/initial-registration` → Email y contraseña
- `/email-verification` → Verificación de email con OTP (+ botón "Saltar")
- `/registration-steps` → Wizard de registro completo
- `/code-reset` → Reset de contraseña con código

---

## 🗄️ Base de Datos Compartida en Supabase

### Tabla: auth.users (Manejada por Supabase)

```sql
CREATE TABLE auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    encrypted_password TEXT NOT NULL,
    email_confirmed_at TIMESTAMP WITH TIME ZONE,
    last_sign_in_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**¿Qué guarda?**
- Email y contraseña encriptada
- Metadatos de autenticación
- Timestamps de actividad

**¿Quién la maneja?**
- Supabase automáticamente
- No insertamos directamente aquí
- Usamos `supabase.auth.signUp()` y Supabase la llena

---

### Tabla: profiles (Nuestra tabla personalizada)

```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    full_name TEXT NOT NULL,
    rut TEXT UNIQUE NOT NULL,
    fire_company TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**¿Qué guarda?**
- Datos adicionales del usuario
- Información específica de nuestra app
- RUT (identificación chilena)
- Compañía de bomberos

**¿Quién la maneja?**
- Nosotros, manualmente
- Insertamos con `supabase.from('profiles').insert()`
- Leemos con `supabase.from('profiles').select()`

---

### Relación entre las tablas:

```
auth.users (id = "abc-123")
    ↓ (references)
profiles (id = "abc-123")

Mismo ID = Mismo usuario
```

**Ejemplo:**
```
Usuario: juan@ejemplo.com

auth.users:
  id: "abc-123"
  email: "juan@ejemplo.com"
  encrypted_password: "$2b$10$..."
  
profiles:
  id: "abc-123"  ← Mismo ID
  full_name: "Juan Pérez"
  rut: "12.345.678-9"
  fire_company: "Primera Compañía"
  email: "juan@ejemplo.com"
```

---

## 🔒 Seguridad: Row Level Security (RLS) y Validación de Roles

### ¿Qué es RLS?

**Row Level Security** es una característica de PostgreSQL (base de datos de Supabase) que limita qué filas puede ver/modificar cada usuario.

### Validación de Roles Entre Apps

**Implementación:**
1. **App de Bomberos**: Verifica que el usuario exista en la tabla `bombero` antes de permitir login
2. **App de Residente**: Verifica que el usuario NO exista en la tabla `bombero` antes de permitir login
3. **App de firedata_admin**: Verifica que el usuario tenga `is_admin = true` o `1` en la tabla `bombero` para permitir acceso
4. **Mensajes de error claros**: Indica al usuario en qué app debe iniciar sesión

**Campo is_admin en tabla bombero:**
- `true` o `1`: Usuario tiene acceso a firedata_admin
- `false`, `0`, `empty`, o `null`: Usuario NO tiene acceso a firedata_admin

**Código de validación en Bomberos:**
```dart
// Verificar que existe en tabla bombero
final bombero = await _getBomberoByEmail(email.trim());
if (bombero == null) {
  return AuthResult.error('No está registrado como bombero. Usa la app de residentes.');
}
```

**Código de validación en Residente:**
```dart
// Verificar que NO existe en tabla bombero
final esBombero = await _verificarSiEsBombero(email.trim());
if (esBombero) {
  return AuthResult.error('Está registrado como bombero. Usa la app de bomberos.');
}
```

### Políticas implementadas:

#### Política 1: Ver solo tu propio perfil

```sql
CREATE POLICY "users_view_own_profile"
ON profiles
FOR SELECT
USING (auth.uid() = id);
```

**Traducción:**
- `FOR SELECT` → Aplica cuando lees datos
- `auth.uid()` → ID del usuario autenticado actualmente
- `USING (auth.uid() = id)` → Solo si el ID coincide

**Ejemplo:**
```dart
// Usuario "abc-123" está autenticado
final result = await supabase.from('profiles').select();

// Supabase automáticamente agrega:
// WHERE id = 'abc-123'

// Resultado: Solo ve su propio perfil
```

#### Política 2: Editar solo tu propio perfil

```sql
CREATE POLICY "users_update_own_profile"
ON profiles
FOR UPDATE
USING (auth.uid() = id);
```

**Ejemplo:**
```dart
// Usuario "abc-123" intenta actualizar perfil "xyz-789"
await supabase.from('profiles')
  .update({'full_name': 'Hacker'})
  .eq('id', 'xyz-789');

// ❌ Supabase lo rechaza porque:
// auth.uid() = "abc-123"
// id = "xyz-789"
// No coinciden!
```

#### Política 3: Crear perfil durante registro

```sql
CREATE POLICY "anyone_can_insert_profile"
ON profiles
FOR INSERT
WITH CHECK (true);
```

**¿Por qué permitir a todos?**
- Durante el registro, el usuario aún no está autenticado
- Necesita poder insertar su perfil
- Después de crearlo, se autentica y aplican las otras políticas

---

## 🔄 Flujos de Autenticación Compartida

### Flujo 1: Registro en Bomberos → Login en Grifos

```
1. Usuario abre app BOMBEROS
2. Va a pantalla de registro
3. Llena formulario:
   - Email: maria@ejemplo.com
   - Password: maria123
   - Nombre: María González
   - RUT: 11.111.111-1
   - Compañía: Segunda Compañía
4. Presiona "Registrarse"

Backend (Supabase):
5. Se crea registro en auth.users:
   id: "def-456"
   email: "maria@ejemplo.com"
   encrypted_password: "$2b$10$..."
   
6. Se crea registro en profiles:
   id: "def-456"
   full_name: "María González"
   rut: "11.111.111-1"
   fire_company: "Segunda Compañía"

7. Usuario cierra app BOMBEROS

8. Usuario abre app GRIFOS
9. Va a pantalla de login
10. Ingresa:
    - Email: maria@ejemplo.com
    - Password: maria123
11. Presiona "Iniciar Sesión"

Backend (Supabase):
12. Valida contra auth.users
13. Encuentra el usuario (mismo email)
14. Verifica contraseña
15. ✅ Login exitoso!
16. Lee datos de profiles
17. Retorna: "¡Bienvenida María González!"

Resultado: Usuario puede usar ambas apps con una sola cuenta
```

---

### Flujo 2: Cambio de contraseña afecta ambas apps

```
Usuario está registrado como: carlos@ejemplo.com

1. Abre app GRIFOS
2. Va a "Olvidé mi contraseña"
3. Ingresa: carlos@ejemplo.com
4. Supabase envía email con enlace
5. Usuario hace clic en enlace
6. Crea nueva contraseña: carlos2024

Backend (Supabase):
7. Actualiza auth.users:
   WHERE email = "carlos@ejemplo.com"
   SET encrypted_password = "$2b$10$..." (nueva)

8. Usuario intenta entrar a app BOMBEROS
9. Ingresa:
   - Email: carlos@ejemplo.com
   - Password: carlos123 (vieja)
10. ❌ Error: "Credenciales incorrectas"

11. Ingresa:
    - Email: carlos@ejemplo.com
    - Password: carlos2024 (nueva)
12. ✅ Login exitoso!

Resultado: El cambio de contraseña en Grifos afecta Bomberos
```

---

## 🛠️ Configuración Técnica

### Paso 1: Crear proyecto en Supabase

```
1. Ir a https://supabase.com
2. Crear cuenta / Iniciar sesión
3. "New Project"
4. Nombre: "bomberos-grifos"
5. Password de BD: (crear una segura)
6. Región: South America
7. Esperar ~2 minutos
```

### Paso 2: Ejecutar script SQL

```sql
-- En Supabase > SQL Editor > New Query
-- Pegar contenido de supabase_setup.sql
-- Clic en "Run"

-- Crea:
-- - Tabla profiles
-- - Políticas de seguridad (RLS)
-- - Índices para performance
-- - Triggers para updated_at
-- - Funciones auxiliares
```

### Paso 3: Obtener credenciales

```
Supabase > Settings > API

Copiar:
1. Project URL → SUPABASE_URL
2. anon/public key → SUPABASE_ANON_KEY
```

### Paso 4: Configurar apps

```bash
# BOMBEROS
cd Bomberos
echo "SUPABASE_URL=https://tuproyecto.supabase.co" > .env
echo "SUPABASE_ANON_KEY=tu-clave-anon" >> .env

# GRIFOS (MISMAS CREDENCIALES)
cd ../Grifos
echo "SUPABASE_URL=https://tuproyecto.supabase.co" > .env
echo "SUPABASE_ANON_KEY=tu-clave-anon" >> .env
```

### Paso 5: Instalar dependencias

```bash
# Usar script automático
./install_dependencies.sh  # Linux/Mac
.\install_dependencies.ps1  # Windows
```

---

## 🎯 Ventajas de Esta Arquitectura

### 1. **Single Source of Truth**
- Una sola base de datos
- Datos siempre consistentes
- No hay sincronización manual

### 2. **Experiencia de Usuario Unificada**
- Un solo registro para ambas apps
- Mismas credenciales funcionan en todo
- Cambios se reflejan automáticamente

### 3. **Mantenimiento Simplificado**
- Código de autenticación en un solo lugar
- Actualizar lógica → Afecta ambas apps
- Menos duplicación de código

### 4. **Seguridad Robusta**
- Row Level Security en BD
- Validaciones del lado del cliente
- Encriptación de contraseñas
- Tokens de sesión seguros
- **Validación de roles entre apps**: Previene acceso no autorizado entre apps
- **Migración segura de usuarios**: Manejo de usuarios existentes sin grupo familiar

### 5. **Escalabilidad**
- Agregar más apps es fácil
- Solo usar las mismas credenciales
- Supabase maneja la carga

---

## 🔄 Sincronización de Código

### Archivos según configuración:

#### Si comparten BD (Bomberos + Grifos + Residente):

```
Bomberos/                    Grifos/                     Residente/
├── .env                ←→   ├── .env               ←→   ├── .env
│   (MISMAS credenciales)    │   (MISMAS)                │   (MISMAS)
```

#### Si Residente es independiente:

```
Bomberos/                    Grifos/                     Residente/
├── .env                ←→   ├── .env                    ├── .env
│   (Credenciales A)         │   (Credenciales A)        │   (Credenciales B - DIFERENTES)
```

### ¿Qué pasa si los haces diferentes?

**Ejemplo: Diferentes credenciales**
```
Bomberos/.env:
  SUPABASE_URL=https://proyecto1.supabase.co

Grifos/.env:
  SUPABASE_URL=https://proyecto2.supabase.co

Resultado: ❌ Bases de datos separadas, usuarios no compartidos
```

**Ejemplo: Diferente lógica de auth**
```
Bomberos/supabase_auth_service.dart:
  // Guarda datos en tabla 'profiles'

Grifos/supabase_auth_service.dart:
  // Guarda datos en tabla 'usuarios' (diferente)

Resultado: ❌ Usuarios no compatibles entre apps
```

---

## 📊 Monitoreo y Debugging

### Dashboard de Supabase

#### 1. Ver usuarios registrados:
```
Supabase > Authentication > Users

Verás:
- Email de cada usuario
- Fecha de registro
- Última vez que inició sesión
- Confirmación de email
```

#### 2. Ver perfiles en BD:
```
Supabase > Table Editor > profiles

Verás:
- Nombre completo
- RUT
- Compañía
- Fechas
```

#### 3. Logs de autenticación:
```
Supabase > Logs > Auth Logs

Verás:
- Intentos de login (éxito/error)
- Registros nuevos
- Cambios de contraseña
```

#### 4. Logs de base de datos:
```
Supabase > Logs > Database Logs

Verás:
- Consultas SQL ejecutadas
- Inserts, updates, selects
- Errores de BD
```

---

## 🐛 Troubleshooting

### Problema: Usuario registrado en Bomberos no puede entrar a Grifos

**Causas posibles:**
1. **Credenciales diferentes en .env**
   ```bash
   # Verificar:
   cat Bomberos/.env
   cat Grifos/.env
   # ¿Son idénticos?
   ```

2. **Tabla profiles no existe**
   ```sql
   -- Verificar en Supabase > SQL Editor:
   SELECT * FROM profiles LIMIT 1;
   -- Si da error, ejecutar supabase_setup.sql
   ```

3. **RLS bloqueando acceso**
   ```sql
   -- Verificar políticas en Supabase > Authentication > Policies
   -- Deben existir las 3 políticas
   ```

---

### Problema: Error "Las credenciales no están configuradas"

**Causas posibles:**
1. **Archivo .env no existe**
   ```bash
   ls -la Bomberos/.env
   ls -la Grifos/.env
   # Deben existir ambos
   ```

2. **Variables mal escritas**
   ```env
   # MAL:
   SUPABASE_url=...  # Minúsculas
   
   # BIEN:
   SUPABASE_URL=...  # Mayúsculas
   ```

3. **Archivo .env no en assets**
   ```yaml
   # Verificar en pubspec.yaml:
   flutter:
     assets:
       - .env  # Debe estar presente
   ```

---

## 📝 Checklist de Implementación

### Configuración de Supabase:
- [ ] Crear proyecto en Supabase
- [ ] Ejecutar script SQL (supabase_setup.sql)
- [ ] Verificar que tabla profiles existe
- [ ] Verificar que RLS está habilitado
- [ ] Obtener credenciales (URL + anon key)

### Configuración de Bomberos:
- [ ] Crear archivo .env con credenciales
- [ ] Verificar supabase_config.dart
- [ ] Verificar supabase_auth_service.dart
- [ ] Ejecutar flutter pub get
- [ ] Probar registro de usuario
- [ ] Probar inicio de sesión

### Configuración de Grifos:
- [ ] Crear archivo .env con MISMAS credenciales
- [ ] Verificar supabase_config.dart (idéntico a Bomberos)
- [ ] Verificar supabase_auth_service.dart (idéntico a Bomberos)
- [ ] Ejecutar flutter pub get
- [ ] Probar login con usuario de Bomberos
- [ ] Verificar que datos se muestran correctamente

### Configuración de Residente:
- [ ] Decidir: ¿BD compartida o separada?
- [ ] Crear archivo .env (mismas credenciales o diferentes)
- [ ] Verificar supabase_config.dart (con PKCE)
- [ ] Verificar auth_service.dart
- [ ] Ejecutar flutter pub get
- [ ] Probar wizard de registro (4 pasos)
- [ ] Probar inicio de sesión
- [ ] Verificar navegación automática con StreamBuilder

### Pruebas de integración (si comparten BD):
- [ ] Registrar usuario en Bomberos
- [ ] Login con ese usuario en Grifos ✅
- [ ] Login con ese usuario en Residente ✅
- [ ] Registrar usuario en Grifos
- [ ] Login con ese usuario en Bomberos ✅
- [ ] Login con ese usuario en Residente ✅
- [ ] Registrar usuario en Residente (wizard)
- [ ] Login con ese usuario en Bomberos ✅
- [ ] Login con ese usuario en Grifos ✅
- [ ] Cambiar contraseña en cualquier app
- [ ] Verificar que funciona en las tres apps ✅

---

## 🎓 Conceptos Avanzados

### 1. JWT (JSON Web Tokens)

Cuando un usuario inicia sesión, Supabase devuelve un **token**:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkw...
```

Este token:
- Identifica al usuario
- Tiene fecha de expiración
- Se envía en cada petición a la API
- Permite que Supabase sepa quién eres

### 2. Refresh Tokens

Supabase también da un **refresh token**:
- Cuando el JWT expira, lo renueva automáticamente
- El usuario no necesita volver a hacer login
- La sesión persiste entre reinicios de app

### 3. PostgreSQL Row Level Security

Es una feature nativa de PostgreSQL (BD de Supabase):
- Aplica filtros automáticos a queries
- Se ejecuta en el servidor (no se puede bypassear)
- Usa funciones especiales como `auth.uid()`

---

## 📱 Responsividad y Diseño Adaptativo

### Mejoras Implementadas

#### 1. **Diseño Centrado en Desktop**
```dart
// Max-width de 1400px para mejor legibilidad
final maxWidth = isDesktop ? 1400.0 : null;
return Center(
  child: ResponsiveContainer(
    maxWidth: maxWidth,
    child: Column(...),
  ),
);
```

#### 2. **Grid Adaptativo por Ancho**
```dart
// Grid de 2 o 4 columnas según ancho de pantalla
final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
return GridView.count(
  crossAxisCount: crossAxisCount,
  childAspectRatio: crossAxisCount == 4 ? 3.5 : 2.5,
);
```

#### 3. **Prevención de Overflow**
- Todos los widgets con `isExpanded: true` donde corresponde
- Textos con `overflow: TextOverflow.ellipsis`
- Layouts verticales en móvil, horizontales en desktop
- Contenedores con `SingleChildScrollView` para contenido extenso

#### 4. **Breakpoints Responsivos**
```dart
// Mobile: < 600px
// Tablet: 600px - 900px
// Desktop: > 900px
final isMobile = MediaQuery.of(context).size.width < 600;
final isTablet = MediaQuery.of(context).size.width >= 600 && 
                 MediaQuery.of(context).size.width < 900;
final isDesktop = MediaQuery.of(context).size.width >= 900;
```

### Navegación Adaptativa
- **Móvil**: Navigation drawer y tabs inferiores
- **Tablet**: Tabs superiores o laterales
- **Desktop**: Sidebar o menú horizontal superior

---

## 🚀 Próximos Pasos

### Para agregar una cuarta app:

1. Crear nuevo proyecto Flutter
2. Agregar mismas dependencias (supabase_flutter, flutter_dotenv)
3. Copiar archivo .env con **mismas credenciales**
4. Copiar supabase_config.dart (idéntico)
5. Copiar supabase_auth_service.dart (idéntico) o auth_service.dart (avanzado)
6. Crear pantallas de login/register
7. ¡Listo! Ya comparte usuarios con Bomberos, Grifos y Residente

### Para agregar más campos al perfil:

```sql
-- En Supabase SQL Editor:
ALTER TABLE profiles
ADD COLUMN telefono TEXT;

-- Luego actualizar SupabaseAuthService para incluirlo
```

### Para agregar roles de usuario:

```sql
ALTER TABLE profiles
ADD COLUMN role TEXT DEFAULT 'user';

-- Crear política para admins:
CREATE POLICY "admins_view_all_profiles"
ON profiles FOR SELECT
USING (
  auth.jwt() ->> 'role' = 'admin'
);
```

---

## 📚 Recursos

- **Documentación de Supabase**: https://supabase.com/docs
- **Flutter + Supabase Guide**: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
- **Row Level Security**: https://supabase.com/docs/guides/auth/row-level-security
- **PostgreSQL RLS**: https://www.postgresql.org/docs/current/ddl-rowsecurity.html

---

¡Felicidades! Ahora entiendes cómo funciona la arquitectura compartida. 🎉

