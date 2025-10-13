# 💧 Documentación Técnica - Aplicación Grifos

Esta documentación explica de manera sencilla cómo funciona el código de autenticación con Supabase en la aplicación Grifos.

## 📁 Estructura del Proyecto

```
Grifos/
├── lib/
│   ├── config/
│   │   └── supabase_config.dart          # Configuración de Supabase
│   ├── services/
│   │   └── supabase_auth_service.dart    # Servicio de autenticación
│   ├── screens/
│   │   └── auth/
│   │       ├── login.dart                # Pantalla de inicio de sesión
│   │       ├── register.dart             # Pantalla de registro
│   │       └── password.dart             # Recuperación de contraseña
│   ├── widgets/                          # Componentes reutilizables
│   ├── constants/                        # Colores, estilos, constantes
│   └── main.dart                         # Punto de entrada de la app
├── .env                                  # Variables de entorno (credenciales)
└── pubspec.yaml                          # Dependencias del proyecto
```

---

## 🔧 1. Configuración Inicial (pubspec.yaml)

### ¿Qué hace?
Define las dependencias que necesita el proyecto para funcionar.

### Código explicado:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.2    # Cliente para conectarse a Supabase
  flutter_dotenv: ^5.1.0        # Para leer variables de entorno (.env)
  cupertino_icons: ^1.0.8       # Iconos de iOS

flutter:
  assets:
    - .env                      # Incluir el archivo .env en la app
```

### ¿Por qué es importante?
- `supabase_flutter`: Nos permite conectarnos a la base de datos Supabase
- `flutter_dotenv`: Protege nuestras credenciales manteniéndolas fuera del código
- El archivo `.env` debe estar listado en assets para que Flutter lo pueda leer

---

## 🔐 2. Archivo de Variables de Entorno (.env)

### ¿Qué hace?
Guarda las credenciales de Supabase de forma segura.

### Código explicado:
```env
# URL de tu proyecto en Supabase
SUPABASE_URL=https://tuproyecto.supabase.co

# Clave pública para autenticación
SUPABASE_ANON_KEY=tu-clave-super-larga-aqui
```

### ⚠️ Importante:
- Este archivo usa **LAS MISMAS credenciales** que la app Bomberos
- Por eso ambas apps comparten usuarios
- Nunca subas este archivo a Git (está en `.gitignore`)

---

## ⚙️ 3. Configuración de Supabase (supabase_config.dart)

### ¿Qué hace?
Lee las credenciales del archivo `.env` e inicializa la conexión con Supabase.

### Código explicado:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Lee la URL desde el archivo .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  // Lee la clave anon desde el archivo .env
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Inicializa la conexión con Supabase
  static Future<void> initialize() async {
    // Verifica que las credenciales existan
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Las credenciales de Supabase no están configuradas. '
        'Por favor, crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY',
      );
    }
    
    // Conecta con Supabase usando las credenciales
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Proporciona acceso al cliente de Supabase en toda la app
  static SupabaseClient get client => Supabase.instance.client;
}
```

### Flujo de ejecución:
1. `main.dart` llama a `dotenv.load()` para cargar el `.env`
2. `main.dart` llama a `SupabaseConfig.initialize()`
3. Se verifican las credenciales
4. Se crea la conexión con Supabase
5. Ahora `SupabaseConfig.client` está disponible en toda la app

---

## 🔑 4. Servicio de Autenticación (supabase_auth_service.dart)

### ¿Qué hace?
Centraliza toda la lógica de autenticación en un solo lugar.

### Estructura del Servicio:

```dart
class SupabaseAuthService {
  // Patrón Singleton: solo una instancia
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();
  
  // Acceso rápido al cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;
  
  // Obtener el usuario actual (si existe)
  User? get currentUser => _client.auth.currentUser;
  
  // Verificar si hay usuario autenticado
  bool get isAuthenticated => currentUser != null;
}
```

**Ventajas del Singleton:**
- Todos los componentes usan la misma instancia
- Evita crear múltiples conexiones
- Facilita el mantenimiento

### 4.1. Inicio de Sesión

```dart
Future<AuthResult> signInWithPassword({
  required String email,
  required String password,
}) async {
  try {
    // Enviar credenciales a Supabase
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),    // .trim() quita espacios en blanco
      password: password,
    );

    if (response.user != null) {
      // Obtener datos adicionales de la tabla profiles
      final profile = await _getUserProfile(response.user!.id);
      
      // Crear objeto UserData con toda la información
      return AuthResult.success(
        UserData(
          id: response.user!.id,
          email: response.user!.email ?? email,
          fullName: profile?['full_name'] ?? '',
          rut: profile?['rut'] ?? '',
          company: profile?['fire_company'] ?? '',
        ),
      );
    } else {
      return AuthResult.error('No se pudo iniciar sesión');
    }
  } on AuthException catch (e) {
    // Capturar errores específicos de autenticación
    return AuthResult.error(_translateAuthError(e.message));
  } catch (e) {
    // Capturar cualquier otro error
    return AuthResult.error('Error inesperado: ${e.toString()}');
  }
}
```

**¿Qué hace `_getUserProfile()`?**
```dart
Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
  try {
    // Buscar en la tabla profiles por ID
    final response = await _client
        .from('profiles')
        .select()               // Seleccionar todas las columnas
        .eq('id', userId)       // Donde id = userId
        .single();              // Retornar solo un resultado
    return response;
  } catch (e) {
    return null;  // Si no encuentra, retorna null
  }
}
```

### 4.2. Registro de Usuario

```dart
Future<AuthResult> signUp({
  required String email,
  required String password,
  required String fullName,
  required String rut,
  required String company,
}) async {
  try {
    // PASO 1: Crear cuenta en Supabase Auth
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      // PASO 2: Guardar datos adicionales en tabla profiles
      try {
        await _client.from('profiles').insert({
          'id': response.user!.id,              // Mismo ID que auth.users
          'full_name': fullName.trim(),
          'rut': rut.trim(),
          'fire_company': company.trim(),
          'email': email.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });

        // Si todo sale bien, retornar éxito
        return AuthResult.success(
          UserData(
            id: response.user!.id,
            email: email.trim(),
            fullName: fullName.trim(),
            rut: rut.trim(),
            company: company.trim(),
          ),
        );
      } on PostgrestException catch (e) {
        // Si falla insertar en profiles, eliminar cuenta de Auth
        await _client.auth.signOut();
        return AuthResult.error('Error al guardar el perfil: ${e.message}');
      }
    } else {
      return AuthResult.error('No se pudo crear el usuario');
    }
  } on AuthException catch (e) {
    return AuthResult.error(_translateAuthError(e.message));
  } catch (e) {
    return AuthResult.error('Error inesperado: ${e.toString()}');
  }
}
```

**¿Por qué dos pasos?**
1. **Supabase Auth** → Maneja email/contraseña y tokens de sesión
2. **Tabla profiles** → Guarda información adicional (nombre, RUT, compañía)

**Rollback automático:** Si el paso 2 falla, eliminamos la cuenta del paso 1.

### 4.3. Traducción de Errores

```dart
String _translateAuthError(String error) {
  if (error.contains('Invalid login credentials')) {
    return 'Credenciales incorrectas. Verifica tu email y contraseña.';
  } else if (error.contains('User already registered')) {
    return 'Este correo electrónico ya está registrado.';
  } else if (error.contains('Password should be at least')) {
    return 'La contraseña debe tener al menos 6 caracteres.';
  } else if (error.contains('Invalid email')) {
    return 'El correo electrónico no es válido.';
  } else if (error.contains('Email not confirmed')) {
    return 'Por favor, confirma tu correo electrónico.';
  } else if (error.contains('User not found')) {
    return 'Usuario no encontrado.';
  }
  return error;  // Si no hay traducción, retorna el error original
}
```

---

## 📱 5. Pantalla de Login (login.dart)

### Diferencia con Bomberos:
Esta app usa **componentes personalizados** para mantener consistencia visual:
- `GradientScaffold` → Fondo con gradiente
- `CustomTextField` → Campo de texto personalizado
- `CustomButton` → Botón personalizado
- `AuthHeader` → Encabezado de autenticación

### Código explicado:

```dart
class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar lo que escribe el usuario
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();
  
  // Estado de carga (mostrar/ocultar spinner)
  bool _isLoading = false;
}
```

### Función de Login:

```dart
Future<void> _login() async {
  // 1. Validar formulario
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      // 2. Llamar al servicio de autenticación
      final authService = SupabaseAuthService();
      final result = await authService.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          // ✅ Login exitoso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${result.user!.fullName}!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Navegar a HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                onLogout: _handleLogout,
                userEmail: result.user!.email,
              ),
            ),
          );
        } else {
          // ❌ Error en login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error de autenticación'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      // ❌ Error inesperado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // 3. Ocultar spinner
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

### ¿Qué es `mounted`?
```dart
if (mounted) {
  // Ejecutar código solo si el widget sigue en pantalla
}
```
**¿Por qué usarlo?** Previene errores si el usuario sale de la pantalla antes de que termine la operación asíncrona.

---

## 📝 6. Pantalla de Registro (register.dart)

### Diferencia con Bomberos:
Usa el patrón de **widgets personalizados** y validadores centralizados:

```dart
// En lugar de definir validadores en cada pantalla
// Se usan validadores centralizados de utils/validators.dart
CustomTextField(
  controller: _fullNameController,
  labelText: 'Nombre Completo *',
  validator: Validators.fullName,  // ← Validador centralizado
)

CustomTextField(
  controller: _rutController,
  labelText: 'RUT *',
  validator: Validators.rut,       // ← Validador centralizado
)

CustomTextField(
  controller: _emailController,
  labelText: 'Email *',
  validator: Validators.email,     // ← Validador centralizado
)
```

### Validador de RUT (en utils/validators.dart):

```dart
static String? rut(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu RUT';
  }

  // Limpiar formato
  String cleanRut = value.replaceAll('.', '').replaceAll('-', '').toUpperCase();

  if (cleanRut.length < 8) return 'RUT inválido';

  String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
  String verifier = cleanRut.substring(cleanRut.length - 1);

  // Algoritmo módulo 11
  int sum = 0;
  int multiplier = 2;

  for (int i = rutNumber.length - 1; i >= 0; i--) {
    sum += int.parse(rutNumber[i]) * multiplier;
    multiplier = multiplier == 7 ? 2 : multiplier + 1;
  }

  int mod = 11 - (sum % 11);
  String calculatedVerifier = mod == 11 ? '0' : mod == 10 ? 'K' : mod.toString();

  if (verifier != calculatedVerifier) return 'RUT inválido';

  return null;  // RUT válido
}
```

### Formateo automático de RUT:

```dart
CustomTextField(
  controller: _rutController,
  onChanged: (value) {
    // Aplicar formato mientras escribe: 12345678-9 → 12.345.678-9
    Formatters.applyRutFormat(value, (formatted) {
      _rutController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  },
)
```

**Resultado:** El usuario escribe `123456789` y automáticamente se formatea a `12.345.678-9`

### Función de Registro:

```dart
Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      final authService = SupabaseAuthService();
      final result = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        rut: _rutController.text.trim(),
        company: _companyController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.msgRegistroSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Volver a la pantalla de login
          Navigator.pop(context);
        } else {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al registrar'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

---

## 🔄 7. Recuperación de Contraseña (password.dart)

### ¿Qué hace?
Envía un email al usuario con un enlace para restablecer su contraseña.

### Estados de la pantalla:

```dart
bool _isLoading = false;      // Mostrar spinner mientras envía email
bool _emailSent = false;      // Cambiar UI después de enviar
```

### Código explicado:

```dart
Future<void> _sendResetEmail() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      final authService = SupabaseAuthService();
      final result = await authService.resetPassword(
        _emailController.text.trim(),
      );

      if (result.isSuccess) {
        // Cambiar estado para mostrar mensaje de éxito
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.msgRecuperacionSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Mostrar error
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al enviar email'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
```

### Interfaz condicional:

```dart
Widget build(BuildContext context) {
  return GradientScaffold(
    child: Column(
      children: [
        AuthHeader(
          icon: _emailSent ? Icons.check_circle_outline : Icons.lock_reset,
          title: _emailSent ? '¡Email Enviado!' : 'Recuperar Contraseña',
        ),
        // Mostrar formulario O mensaje de éxito
        if (!_emailSent) 
          _buildEmailForm()      // Formulario para ingresar email
        else 
          _buildSuccessMessage() // Mensaje de confirmación
      ],
    ),
  );
}
```

---

## 🚀 8. Punto de Entrada (main.dart)

### ¿Qué hace?
Inicializa la app, carga configuración y verifica autenticación.

### Código completo explicado:

```dart
Future<void> main() async {
  // IMPORTANTE: Inicializar binding de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // PASO 1: Cargar archivo .env con las credenciales
    await dotenv.load(fileName: ".env");
    
    // PASO 2: Inicializar conexión con Supabase
    await SupabaseConfig.initialize();
    
    // PASO 3: Ejecutar la aplicación
    runApp(const MyApp());
    
  } catch (e) {
    // Si algo falla, mostrar pantalla de error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Error de configuración',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se pudo cargar el archivo .env\n\n'
                    'Por favor, crea un archivo .env con tus credenciales.\n\n'
                    'Error: ${e.toString()}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Verificador de Autenticación:

```dart
class _AuthCheckerState extends State<AuthChecker> {
  void _logout() async {
    // Cerrar sesión en Supabase
    await Supabase.instance.client.auth.signOut();
    
    // Navegar a login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(onLogin: (email) {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay sesión activa
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // ✅ Usuario autenticado
      return HomeScreen(
        onLogout: _logout,
        userEmail: session.user.email,
      );
    }
    
    // ❌ No autenticado
    return LoginScreen(onLogin: (email) {});
  }
}
```

**Flujo al abrir la app:**
```
App inicia
    ↓
Cargar .env
    ↓
Inicializar Supabase
    ↓
¿Hay sesión activa?
    ↓
Sí → HomeScreen
No → LoginScreen
```

---

## 🎨 9. Widgets Personalizados

### GradientScaffold:
```dart
// Proporciona un fondo con gradiente consistente
GradientScaffold(
  gradientColors: [AppColors.primaryLight, Colors.blue.shade700],
  child: // contenido
)
```

### CustomTextField:
```dart
// Campo de texto con estilo consistente
CustomTextField(
  controller: _emailController,
  labelText: 'Email',
  prefixIcon: Icons.email_outlined,
  validator: Validators.email,
)
```

### CustomButton:
```dart
// Botón con spinner de carga integrado
CustomButton(
  text: 'Iniciar Sesión',
  backgroundColor: AppColors.primary,
  onPressed: _login,
  isLoading: _isLoading,  // Muestra spinner automáticamente
)
```

**Ventajas:**
- Código más limpio y legible
- Estilos consistentes en toda la app
- Fácil mantenimiento (cambio en un lugar afecta a todos)

---

## 🔄 Flujo Completo de Autenticación

### 1. Registro:
```
Usuario llena formulario en RegisterScreen
    ↓
Validar datos (incluyendo RUT chileno)
    ↓
SupabaseAuthService.signUp()
    ↓
Crear cuenta en auth.users
    ↓
Guardar datos en profiles
    ↓
Volver a LoginScreen
    ↓
Usuario inicia sesión
```

### 2. Login:
```
Usuario ingresa email y contraseña en LoginScreen
    ↓
SupabaseAuthService.signInWithPassword()
    ↓
Supabase valida credenciales
    ↓
Obtener datos de profiles
    ↓
Guardar sesión localmente
    ↓
Navegar a HomeScreen
```

### 3. Persistencia:
```
Usuario cierra la app
    ↓
Usuario abre la app de nuevo
    ↓
AuthChecker verifica session
    ↓
Si existe → HomeScreen directamente
Si no → LoginScreen
```

### 4. Logout:
```
Usuario presiona "Cerrar sesión"
    ↓
Supabase.client.auth.signOut()
    ↓
Borrar sesión local
    ↓
Navegar a LoginScreen
```

---

## 🗄️ Base de Datos Compartida

### ¿Cómo funciona?

**Ambas apps (Bomberos y Grifos) usan:**
- La misma URL de Supabase
- La misma clave anon
- La misma tabla `profiles`

**Por lo tanto:**
- Un usuario registrado en Bomberos puede login en Grifos
- Un usuario registrado en Grifos puede login en Bomberos
- Los cambios en el perfil se reflejan en ambas apps

### Tablas en Supabase:

#### auth.users (Manejada por Supabase):
```sql
id              UUID PRIMARY KEY
email           TEXT UNIQUE
encrypted_password TEXT
created_at      TIMESTAMP
last_sign_in_at TIMESTAMP
```

#### profiles (Nuestra tabla):
```sql
id              UUID PRIMARY KEY REFERENCES auth.users(id)
full_name       TEXT NOT NULL
rut             TEXT UNIQUE NOT NULL
fire_company    TEXT NOT NULL
email           TEXT NOT NULL
created_at      TIMESTAMP DEFAULT NOW()
updated_at      TIMESTAMP DEFAULT NOW()
```

---

## 🔒 Seguridad Implementada

### Row Level Security (RLS):

```sql
-- Política 1: Ver solo tu propio perfil
CREATE POLICY "users_view_own_profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Política 2: Editar solo tu propio perfil
CREATE POLICY "users_update_own_profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- Política 3: Crear perfil durante registro
CREATE POLICY "anyone_can_insert_profile"
ON profiles FOR INSERT
WITH CHECK (true);
```

**¿Qué significa?**
- `auth.uid()` → ID del usuario actualmente autenticado
- `USING (auth.uid() = id)` → Solo si el ID coincide con el del perfil
- `WITH CHECK (true)` → Permitir durante el registro (no hay sesión aún)

### Validaciones del lado del cliente:

```dart
// Email válido
Validators.email(value)

// RUT chileno válido
Validators.rut(value)

// Nombre completo (nombre y apellido)
Validators.fullName(value)

// Contraseña mínimo 6 caracteres
Validators.password(value)

// Confirmar contraseña
Validators.confirmPassword(value, originalPassword)
```

---

## 📚 Estructura de Archivos Importante

### Constants:
```
constants/
├── app_colors.dart      # Colores de la app
├── app_constants.dart   # Constantes (mensajes, durations)
└── app_styles.dart      # Estilos de texto
```

### Utils:
```
utils/
├── validators.dart      # Validadores de formularios
└── formatters.dart      # Formateadores (RUT, etc.)
```

### Widgets:
```
widgets/
├── auth_header.dart           # Encabezado de pantallas auth
├── custom_button.dart         # Botón personalizado
├── custom_text_field.dart     # Campo de texto personalizado
└── gradient_scaffold.dart     # Scaffold con gradiente
```

**Ventaja:** Separación clara de responsabilidades

---

## 🎓 Conceptos Clave para Entender el Código

### 1. Singleton Pattern:
```dart
class SupabaseAuthService {
  static final _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();
}
```
**Usa:** Solo una instancia en toda la app

### 2. Async/Await:
```dart
Future<AuthResult> signInWithPassword() async {
  final result = await _client.auth.signInWithPassword();
  return result;
}
```
**Usa:** Espera operaciones que toman tiempo (API calls)

### 3. Try/Catch:
```dart
try {
  await supabase.auth.signIn();
} on AuthException catch (e) {
  // Error específico de autenticación
} catch (e) {
  // Cualquier otro error
}
```
**Usa:** Manejo de errores

### 4. StatefulWidget:
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  
  void _login() {
    setState(() => _isLoading = true);  // Actualiza UI
  }
}
```
**Usa:** Widgets que cambian (mostrar spinner, etc.)

### 5. Null Safety:
```dart
User? user = supabase.auth.currentUser;  // Puede ser null
if (user != null) {
  print(user.email);  // Seguro usar aquí
}
```
**Usa:** Evita errores por valores nulos

---

## 🆚 Diferencias con la App Bomberos

| Aspecto | Bomberos | Grifos |
|---------|----------|--------|
| **Widgets** | Código directo en pantallas | Widgets personalizados |
| **Validadores** | En cada pantalla | Centralizados en `utils/` |
| **Estilos** | Hardcoded | Constantes en `constants/` |
| **Colores** | Colors.blue, Colors.red | AppColors.primary, etc. |
| **Manteniblidad** | Más código repetido | Más reutilizable |

**Pero ambas comparten:**
- Mismo `SupabaseAuthService`
- Mismo `SupabaseConfig`
- Misma base de datos
- Misma lógica de autenticación

---

## 📝 Resumen

### Flujo general:
1. **`.env`** → Credenciales seguras
2. **`supabase_config.dart`** → Conexión con Supabase
3. **`supabase_auth_service.dart`** → Lógica de autenticación
4. **Widgets personalizados** → UI consistente
5. **Validators y Formatters** → Validaciones reutilizables
6. **Constants** → Colores, estilos, mensajes
7. **Pantallas auth** → Login, Register, Password
8. **`main.dart`** → Inicializa todo

### ¿Por qué compartir usuarios con Bomberos?
- Ambas apps usan las mismas credenciales de Supabase
- Ambas acceden a la misma tabla `profiles`
- Un usuario puede usar su cuenta en ambas apps sin registrarse dos veces

---

## 🐛 Troubleshooting Común

### "Error de configuración"
**Problema:** No encuentra el archivo `.env`  
**Solución:** Crear `.env` en la raíz con las credenciales

### "Invalid login credentials"
**Problema:** Email o contraseña incorrectos  
**Solución:** Verificar credenciales o registrar nuevo usuario

### "User already registered"
**Problema:** Email ya existe en la base de datos  
**Solución:** Usar otro email o recuperar contraseña

### "RUT inválido"
**Problema:** RUT no pasa validación módulo 11  
**Solución:** Verificar dígito verificador

---

¿Dudas sobre alguna parte? Consulta la documentación de Flutter o Supabase, o pregunta al equipo. 💧

