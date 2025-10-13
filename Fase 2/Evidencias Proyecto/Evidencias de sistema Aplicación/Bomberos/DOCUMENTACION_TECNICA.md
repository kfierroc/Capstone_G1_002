# 🚒 Documentación Técnica - Aplicación Bomberos

Esta documentación explica de manera sencilla cómo funciona el código de autenticación con Supabase en la aplicación Bomberos.

## 📁 Estructura del Proyecto

```
Bomberos/
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
- El archivo `.env` contiene información sensible que no debe subirse a Git

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

### ¿Por qué es importante?
- Mantiene las credenciales fuera del código fuente
- Facilita cambiar de proyecto sin modificar el código
- Está en `.gitignore`, así no se sube accidentalmente a GitHub

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
      throw Exception('Las credenciales no están configuradas');
    }
    
    // Conecta con Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Proporciona acceso al cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
```

### Flujo de ejecución:
1. La app inicia → `main.dart` llama a `SupabaseConfig.initialize()`
2. Se leen las credenciales del archivo `.env`
3. Se valida que existan (si no, muestra error)
4. Se establece la conexión con Supabase
5. Ahora podemos usar `SupabaseConfig.client` en toda la app

---

## 🔑 4. Servicio de Autenticación (supabase_auth_service.dart)

### ¿Qué hace?
Maneja todas las operaciones de autenticación: login, registro, recuperación de contraseña, etc.

### Patrón Singleton:
```dart
class SupabaseAuthService {
  // Singleton: solo existe una instancia
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();
  
  // Acceso al cliente de Supabase
  SupabaseClient get _client => SupabaseConfig.client;
}
```

**¿Por qué Singleton?** Para que todos los componentes de la app usen la misma instancia del servicio.

### 4.1. Iniciar Sesión

```dart
Future<AuthResult> signInWithPassword({
  required String email,
  required String password,
}) async {
  try {
    // Intenta iniciar sesión en Supabase
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      // Obtiene datos adicionales del perfil
      final profile = await _getUserProfile(response.user!.id);
      
      // Retorna éxito con los datos del usuario
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
    // Traduce errores de Supabase al español
    return AuthResult.error(_translateAuthError(e.message));
  }
}
```

**Flujo:**
1. Usuario ingresa email y contraseña
2. Se envían a Supabase para validación
3. Si es correcto, Supabase devuelve el usuario
4. Se obtienen datos adicionales de la tabla `profiles`
5. Se retorna todo junto en un `AuthResult`

### 4.2. Registrar Usuario

```dart
Future<AuthResult> signUp({
  required String email,
  required String password,
  required String fullName,
  required String rut,
  required String company,
}) async {
  try {
    // PASO 1: Registrar usuario en Supabase Auth
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    if (response.user != null) {
      // PASO 2: Guardar datos adicionales en tabla profiles
      try {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName.trim(),
          'rut': rut.trim(),
          'fire_company': company.trim(),
          'email': email.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });

        return AuthResult.success(UserData(...));
      } on PostgrestException catch (e) {
        // Si falla guardar el perfil, eliminar el usuario de Auth
        await _client.auth.signOut();
        return AuthResult.error('Error al guardar el perfil');
      }
    }
  } on AuthException catch (e) {
    return AuthResult.error(_translateAuthError(e.message));
  }
}
```

**Flujo:**
1. Usuario llena formulario de registro
2. Se crea cuenta en Supabase Auth (tabla `auth.users`)
3. Se guardan datos adicionales en tabla `profiles`
4. Si algo falla en paso 3, se elimina la cuenta del paso 2
5. Se retorna éxito o error

### 4.3. Recuperar Contraseña

```dart
Future<AuthResult> resetPassword(String email) async {
  try {
    // Envía email con enlace de recuperación
    await _client.auth.resetPasswordForEmail(email.trim());
    return AuthResult.success(null);
  } on AuthException catch (e) {
    return AuthResult.error(_translateAuthError(e.message));
  }
}
```

**Flujo:**
1. Usuario ingresa su email
2. Supabase envía un correo con enlace de recuperación
3. Usuario hace clic en el enlace y crea nueva contraseña

### 4.4. Traducción de Errores

```dart
String _translateAuthError(String error) {
  if (error.contains('Invalid login credentials')) {
    return 'Credenciales incorrectas. Verifica tu email y contraseña.';
  } else if (error.contains('User already registered')) {
    return 'Este correo electrónico ya está registrado.';
  } else if (error.contains('Password should be at least')) {
    return 'La contraseña debe tener al menos 6 caracteres.';
  }
  // ... más traducciones
  return error;
}
```

**¿Por qué?** Supabase devuelve errores en inglés, esta función los traduce al español.

---

## 📱 5. Pantalla de Login (login.dart)

### ¿Qué hace?
Muestra la interfaz donde el usuario ingresa sus credenciales.

### Estructura:
```dart
class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();
  
  // Estado de carga
  bool _isLoading = false;
}
```

### Función de Login:

```dart
Future<void> _login() async {
  // 1. Validar que los campos estén correctos
  if (_formKey.currentState!.validate()) {
    // 2. Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Llamar al servicio de autenticación
      final authService = SupabaseAuthService();
      final result = await authService.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 4. Verificar el resultado
      if (mounted) {
        if (result.isSuccess) {
          // ✅ Login exitoso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${result.user!.fullName}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navegar a la pantalla principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // ❌ Error en login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error de autenticación'),
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 5. Ocultar indicador de carga
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
```

### Flujo completo:
1. Usuario ingresa email y contraseña
2. Presiona "Iniciar Sesión"
3. Se validan los campos (no vacíos, email válido, etc.)
4. Se muestra spinner de carga
5. Se llama a `SupabaseAuthService.signInWithPassword()`
6. Si es exitoso → Navega a HomeScreen
7. Si falla → Muestra mensaje de error
8. Se oculta el spinner de carga

---

## 📝 6. Pantalla de Registro (register.dart)

### ¿Qué hace?
Permite crear una cuenta nueva con validación de RUT chileno.

### Validación de RUT:

```dart
String? _validateRut(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu RUT';
  }

  // Limpiar formato (quitar puntos y guión)
  String cleanRut = value.replaceAll('.', '').replaceAll('-', '').toUpperCase();

  if (cleanRut.length < 8) {
    return 'RUT inválido';
  }

  // Separar número y dígito verificador
  String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
  String verifier = cleanRut.substring(cleanRut.length - 1);

  // Calcular dígito verificador
  int sum = 0;
  int multiplier = 2;

  for (int i = rutNumber.length - 1; i >= 0; i--) {
    sum += int.parse(rutNumber[i]) * multiplier;
    multiplier = multiplier == 7 ? 2 : multiplier + 1;
  }

  int mod = 11 - (sum % 11);
  String calculatedVerifier = mod == 11 ? '0' : mod == 10 ? 'K' : mod.toString();

  // Verificar que coincida
  if (verifier != calculatedVerifier) {
    return 'RUT inválido';
  }

  return null; // RUT válido
}
```

**Algoritmo de validación:**
1. Limpia el formato (12.345.678-9 → 123456789)
2. Separa número (12345678) y verificador (9)
3. Aplica algoritmo módulo 11
4. Compara resultado con el verificador ingresado

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
            SnackBar(
              content: Text('¡Registro exitoso! Bienvenido ${result.user!.fullName}'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navegar a home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al registrar'),
              backgroundColor: Colors.red,
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

## 🚀 7. Punto de Entrada (main.dart)

### ¿Qué hace?
Es lo primero que se ejecuta cuando se abre la app.

### Código explicado:

```dart
Future<void> main() async {
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Cargar archivo .env
    await dotenv.load(fileName: ".env");
    
    // 2. Inicializar Supabase
    await SupabaseConfig.initialize();
    
    // 3. Ejecutar la app
    runApp(const MyApp());
  } catch (e) {
    // Si hay error, mostrar pantalla de error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                Text('Error de configuración'),
                Text('No se pudo cargar el archivo .env'),
              ],
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
  @override
  Widget build(BuildContext context) {
    // Verificar si hay sesión activa
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Usuario autenticado → Ir a Home
      return const HomeScreen();
    } else {
      // Usuario no autenticado → Ir a Login
      return const LoginScreen();
    }
  }
}
```

**Flujo al abrir la app:**
1. Se carga el archivo `.env`
2. Se inicializa Supabase
3. Se verifica si hay sesión activa
4. Si hay sesión → Muestra HomeScreen
5. Si no hay sesión → Muestra LoginScreen

---

## 🔄 Flujo Completo de Autenticación

### Registro de Usuario:
```
Usuario llena formulario
    ↓
Se validan los datos (RUT, email, etc.)
    ↓
Se llama a SupabaseAuthService.signUp()
    ↓
Se crea cuenta en Supabase Auth
    ↓
Se guardan datos en tabla profiles
    ↓
Se inicia sesión automáticamente
    ↓
Se navega a HomeScreen
```

### Inicio de Sesión:
```
Usuario ingresa email y contraseña
    ↓
Se llama a SupabaseAuthService.signInWithPassword()
    ↓
Supabase valida las credenciales
    ↓
Si es correcto, retorna token de sesión
    ↓
Se obtienen datos del perfil
    ↓
Se navega a HomeScreen
```

### Persistencia de Sesión:
```
App se cierra
    ↓
App se abre de nuevo
    ↓
main.dart verifica si hay sesión
    ↓
Si hay sesión → Va directo a HomeScreen
Si no hay sesión → Muestra LoginScreen
```

---

## 🗄️ Estructura de la Base de Datos

### Tabla: `auth.users` (Supabase)
Manejada automáticamente por Supabase:
- `id` - UUID único
- `email` - Email del usuario
- `encrypted_password` - Contraseña encriptada
- `last_sign_in_at` - Última vez que inició sesión

### Tabla: `profiles` (Nuestra tabla)
Datos adicionales que creamos nosotros:
- `id` - UUID (referencia a auth.users)
- `full_name` - Nombre completo
- `rut` - RUT chileno
- `fire_company` - Compañía de bomberos
- `email` - Email (duplicado para búsquedas rápidas)
- `created_at` - Fecha de creación
- `updated_at` - Fecha de actualización

---

## 🔒 Seguridad

### Row Level Security (RLS):
```sql
-- Los usuarios solo pueden ver su propio perfil
CREATE POLICY "Ver propio perfil"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Los usuarios solo pueden editar su propio perfil
CREATE POLICY "Editar propio perfil"
ON profiles FOR UPDATE
USING (auth.uid() = id);
```

**¿Qué significa?** Aunque alguien intente acceder a la base de datos directamente, solo podrá ver y modificar sus propios datos.

---

## 📝 Resumen

1. **`.env`** → Guarda las credenciales de forma segura
2. **`supabase_config.dart`** → Lee el `.env` y conecta con Supabase
3. **`supabase_auth_service.dart`** → Maneja login, registro y recuperación
4. **`login.dart`** → Interfaz de inicio de sesión
5. **`register.dart`** → Interfaz de registro con validación de RUT
6. **`password.dart`** → Recuperación de contraseña
7. **`main.dart`** → Inicializa todo y verifica sesión

**La app Grifos usa exactamente el mismo código**, por eso ambas comparten usuarios.

---

## 🎓 Conceptos Clave

- **Singleton**: Patrón que asegura que solo existe una instancia de una clase
- **async/await**: Forma de manejar operaciones asíncronas (como llamadas a API)
- **try/catch**: Manejo de errores
- **StatefulWidget**: Widget que puede cambiar su estado (como mostrar un spinner)
- **Future**: Representa un valor que estará disponible en el futuro
- **Row Level Security**: Seguridad a nivel de fila en la base de datos

---

¿Tienes dudas sobre alguna parte específica? Revisa la documentación de Supabase o consulta con el equipo. 🚒

