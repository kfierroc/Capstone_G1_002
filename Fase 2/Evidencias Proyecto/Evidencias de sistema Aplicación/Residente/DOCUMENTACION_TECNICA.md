# 🏘️ Documentación Técnica - Aplicación Residente

Esta documentación explica de manera sencilla cómo funciona el código de autenticación con Supabase en la aplicación Residente (Sistema de Emergencias).

## 🔐 Sistema de Autenticación Actualizado

### Nuevas Características Implementadas:
1. **Registro en 3 Pasos**: Email/contraseña → Verificación OTP → Wizard completo
2. **Verificación de Email con OTP**: Código de 6 dígitos + opción "Saltar"
3. **Reset de Contraseña con OTP**: Código en lugar de deep links
4. **Diseño Verde Unificado**: Mismo estilo que Bomberos
5. **Validación de Roles**: Previene acceso de bomberos a la app de residentes

## 🔒 Validación de Roles Implementada

**Funcionalidad de seguridad:**
- La app de Residente valida que el usuario **NO** esté registrado como bombero
- Previene acceso cruzado entre aplicaciones
- Mensaje claro: "Este correo está registrado como bombero. Usa la app de bomberos."

**Código:**
```dart
// Verificar que NO es bombero antes de permitir login
final esBombero = await _verificarSiEsBombero(email.trim());
if (esBombero) {
  return AuthResult.error('Está registrado como bombero. Usa la app de bomberos.');
}
```

## 📱 Responsividad Completa

### Mejoras Implementadas:
- **Diseño adaptativo**: Funciona en móvil, tablet y desktop
- **Prevención de overflow**: Todos los widgets optimizados con `isExpanded: true`
- **Grid adaptativo**: 2-4 columnas según ancho de pantalla
- **Contenedor centrado**: Max-width en desktop para mejor legibilidad
- **Dropdown optimizado**: Prevención de overflow en listas largas

---

## 📁 Estructura del Proyecto

```
Residente/
├── lib/
│   ├── config/
│   │   └── supabase_config.dart          # Configuración de Supabase
│   ├── services/
│   │   ├── auth_service.dart             # Servicio de autenticación
│   │   └── database_service.dart         # Servicio de base de datos
│   ├── models/
│   │   ├── family_member.dart            # Modelo de miembro de familia
│   │   ├── pet.dart                      # Modelo de mascota
│   │   └── registration_data.dart        # Modelo de datos de registro
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login.dart                # Pantalla de login
│   │   │   ├── initial_registration_screen.dart    # Paso 1: Email y contraseña
│   │   │   ├── email_verification_screen.dart      # Paso 2: Verificación OTP
│   │   │   ├── password.dart             # Recuperación de contraseña
│   │   │   └── reset_password_with_code_screen.dart # Reset con código OTP
│   │   ├── registration_steps/           # Registro por pasos
│   │   │   ├── step1_create_account.dart # Paso 1: Crear cuenta
│   │   │   ├── step2_holder_data.dart    # Paso 2: Datos del titular
│   │   │   ├── step3_residence_info.dart # Paso 3: Info de residencia
│   │   │   └── step4_housing_details.dart# Paso 4: Detalles de vivienda
│   │   └── home/
│   │       └── resident_home.dart        # Pantalla principal
│   │           └── tabs/                 # Tabs de navegación
│   │               ├── family_tab.dart   # Tab de familia
│   │               ├── pets_tab.dart     # Tab de mascotas
│   │               ├── residence_tab.dart# Tab de residencia
│   │               └── settings_tab.dart # Tab de configuración
│   ├── utils/                            # Utilidades
│   │   ├── validators.dart               # Validadores
│   │   ├── app_styles.dart               # Estilos
│   │   ├── responsive.dart               # Helpers responsivos
│   │   └── input_formatters.dart         # Formateadores
│   └── main.dart                         # Punto de entrada
├── .env                                  # Variables de entorno
└── pubspec.yaml                          # Dependencias
```

---

## 🔧 1. Configuración Inicial (pubspec.yaml)

### ¿Qué hace?
Define las dependencias y configuración del proyecto.

### Código explicado:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.10.2    # Cliente de Supabase
  flutter_dotenv: ^5.1.0        # Variables de entorno
  crypto: ^3.0.3                # Para encriptación
  cupertino_icons: ^1.0.8       # Iconos de iOS

flutter:
  assets:
    - .env                      # Archivo de credenciales
```

### Diferencia con Bomberos y Grifos:
- ✅ Incluye paquete `crypto` para encriptación adicional
- ✅ Configuración optimizada para APKs release
- ✅ Iconos adaptativos configurados

---

## 🔐 2. Archivo de Variables de Entorno (.env)

### ¿Qué hace?
Guarda las credenciales de Supabase.

### Contenido:
```env
SUPABASE_URL=https://tuproyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon-aqui
```

### ⚠️ IMPORTANTE:
Esta app puede usar **las mismas credenciales** que Bomberos y Grifos si quieres compartir usuarios, O puede usar credenciales diferentes si necesitas una base de datos separada.

**Para compartir usuarios:**
```env
# Usar MISMAS credenciales que Bomberos/Grifos
SUPABASE_URL=https://mismo-proyecto.supabase.co
SUPABASE_ANON_KEY=misma-clave-aqui
```

**Para base de datos separada:**
```env
# Usar credenciales DIFERENTES
SUPABASE_URL=https://residente-proyecto.supabase.co
SUPABASE_ANON_KEY=otra-clave-diferente
```

---

## ⚙️ 3. Configuración de Supabase (supabase_config.dart)

### ¿Qué hace?
Lee las credenciales y configura la conexión con Supabase.

### Código explicado:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Lee credenciales del .env
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 'TU_SUPABASE_URL';
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'TU_SUPABASE_ANON_KEY';

  // Inicializar Supabase
  static Future<void> initialize() async {
    try {
      // 1. Cargar archivo .env
      await dotenv.load(fileName: ".env");
      
      // 2. Verificar que las credenciales estén configuradas
      if (!isConfigured) {
        throw Exception(
          'Credenciales de Supabase no configuradas. '
          'Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY.'
        );
      }
      
      // 3. Inicializar Supabase con PKCE (más seguro)
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,  // ← Seguridad adicional
        ),
      );
      
      print('✅ Supabase inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar Supabase: $e');
      rethrow;
    }
  }

  // Acceso al cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  // Acceso al cliente de autenticación
  static GoTrueClient get auth => client.auth;
  
  // Verificar si está configurado correctamente
  static bool get isConfigured {
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    
    return url != null && 
           key != null && 
           url.isNotEmpty && 
           key.isNotEmpty &&
           url != 'TU_SUPABASE_URL' && 
           key != 'TU_SUPABASE_ANON_KEY';
  }
}
```

### ¿Qué es PKCE?
**PKCE** (Proof Key for Code Exchange) es un mecanismo de seguridad adicional:
- Más seguro que el flujo estándar
- Protege contra ataques de interceptación
- Recomendado para apps móviles

### Ventaja de `isConfigured`:
Permite verificar si las credenciales están bien configuradas antes de usar la app.

---

## 🔑 4. Servicio de Autenticación (auth_service.dart)

### ¿Qué hace?
Maneja todas las operaciones de autenticación de forma centralizada.

### Patrón Singleton:

```dart
class AuthService {
  // Solo una instancia
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Acceso al cliente de autenticación
  GoTrueClient get _auth => SupabaseConfig.auth;
  
  // Usuario actual
  User? get currentUser => _auth.currentUser;
  
  // ¿Está autenticado?
  bool get isAuthenticated => currentUser != null;
  
  // Stream de cambios de autenticación (IMPORTANTE)
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}
```

**Diferencia clave:** Esta app usa **Stream** para escuchar cambios de autenticación en tiempo real.

---

### 4.1. Registro de Usuario

```dart
Future<AuthResult> signUp({
  required String email,
  required String password,
  Map<String, dynamic>? metadata,  // ← Datos adicionales
}) async {
  try {
    print('🔍 AuthService.signUp - Iniciando...');
    
    // PASO 1: Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      print('❌ Email o contraseña vacíos');
      return AuthResult.error('Email y contraseña son requeridos');
    }

    if (password.length < 6) {
      print('❌ Contraseña muy corta');
      return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
    }

    if (!_isValidEmail(email)) {
      print('❌ Email inválido');
      return AuthResult.error('Email inválido');
    }

    print('✅ Validaciones pasadas');
    print('📧 Email: $email');
    print('📝 Metadata: $metadata');

    // PASO 2: Registrar en Supabase
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: metadata,  // ← Datos adicionales (nombre, etc.)
    );

    print('📦 Response recibido');
    print('👤 User: ${response.user?.id}');
    print('🔓 Session: ${response.session != null}');

    if (response.user == null) {
      print('❌ Usuario es null');
      return AuthResult.error('Error al crear la cuenta');
    }

    print('✅ Usuario creado: ${response.user!.id}');
    
    // PASO 3: Retornar resultado
    return AuthResult.success(
      user: AppUser.fromSupabaseUser(response.user!),
      message: 'Cuenta creada exitosamente',
    );
    
  } on AuthException catch (e) {
    print('❌ AuthException:');
    print('   - Message: ${e.message}');
    print('   - Status Code: ${e.statusCode}');
    
    // Traducir error al español
    final errorMsg = _getAuthErrorMessage(e);
    return AuthResult.error(errorMsg);
    
  } catch (e) {
    print('❌ Excepción inesperada: $e');
    return AuthResult.error('Error inesperado: ${e.toString()}');
  }
}
```

**Características especiales:**
- ✅ **Logs detallados** para debugging
- ✅ **Metadata** para guardar nombre, teléfono, etc.
- ✅ **Manejo robusto de errores** con traducción

---

### 4.2. Inicio de Sesión

```dart
Future<AuthResult> signIn({
  required String email,
  required String password,
}) async {
  try {
    // Validaciones
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.error('Email y contraseña son requeridos');
    }

    // Iniciar sesión en Supabase
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      return AuthResult.error('Error al iniciar sesión');
    }

    return AuthResult.success(
      user: AppUser.fromSupabaseUser(response.user!),
      message: 'Sesión iniciada exitosamente',
    );
  } on AuthException catch (e) {
    return AuthResult.error(_getAuthErrorMessage(e));
  } catch (e) {
    return AuthResult.error('Error inesperado: ${e.toString()}');
  }
}
```

**Flujo:**
1. Validar campos
2. Enviar a Supabase
3. Supabase valida credenciales
4. Si es correcto → Retorna usuario y token
5. Si es incorrecto → Retorna error traducido

---

### 4.3. Recuperación de Contraseña

```dart
Future<AuthResult> resetPassword({required String email}) async {
  try {
    if (email.isEmpty) {
      return AuthResult.error('Email es requerido');
    }

    if (!_isValidEmail(email)) {
      return AuthResult.error('Email inválido');
    }

    // Enviar email de recuperación
    await _auth.resetPasswordForEmail(email);

    return AuthResult.success(
      user: null,
      message: 'Se ha enviado un email para restablecer tu contraseña',
    );
  } on AuthException catch (e) {
    return AuthResult.error(_getAuthErrorMessage(e));
  } catch (e) {
    return AuthResult.error('Error inesperado: ${e.toString()}');
  }
}
```

---

### 4.3.5. Verificación de Email con Código OTP

```dart
Future<AuthResult> verifyEmailCode(String code) async {
  try {
    // Verificar código OTP de 6 dígitos
    final response = await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: currentUser?.email ?? '',
      token: code.trim(),
    );
    
    if (response.user != null) {
      return AuthResult.success(null);
    } else {
      return AuthResult.error('Código de verificación inválido');
    }
  } on AuthException catch (e) {
    return AuthResult.error('Error: ${e.message}');
  }
}
```

### 4.3.6. Reenviar Código de Verificación

```dart
Future<AuthResult> resendEmailVerification({required String email}) async {
  try {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
    return AuthResult.success(null);
  } on AuthException catch (e) {
    return AuthResult.error('Error al reenviar código');
  }
}
```

### 4.3.7. Reset de Contraseña con Código OTP

```dart
Future<AuthResult> resetPassword(String email) async {
  // Enviar código OTP
  await _client.auth.signInWithOtp(
    email: email.trim(),
    shouldCreateUser: false, // No crear usuario nuevo
  );
  return AuthResult.success(null);
}

Future<AuthResult> resetPasswordWithCode({
  required String email,
  required String code,
  required String newPassword,
}) async {
  // Verificar código OTP
  final response = await _client.auth.verifyOTP(
    type: OtpType.recovery,
    email: email.trim(),
    token: code.trim(),
  );

  if (response.user != null) {
    // Actualizar contraseña
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    await _client.auth.signOut(); // Cerrar sesión
    return AuthResult.success(null);
  } else {
    return AuthResult.error('Código inválido');
  }
}
```

### 4.4. Traducción de Errores (Mejorada)

```dart
String _getAuthErrorMessage(AuthException error) {
  print('🔍 Analizando error:');
  print('   - Status Code: ${error.statusCode}');
  print('   - Message: ${error.message}');
  
  switch (error.statusCode) {
    case '400':
      if (error.message.toLowerCase().contains('email')) {
        return 'Email inválido o ya registrado';
      }
      return 'Credenciales inválidas: ${error.message}';
      
    case '401':
      return 'Email o contraseña incorrectos';
      
    case '422':
      return 'Email ya registrado';
      
    case '429':
      return 'Demasiados intentos. Intenta más tarde';
      
    default:
      // Análisis inteligente del mensaje
      if (error.message.toLowerCase().contains('email')) {
        return 'Problema con el email: ${error.message}';
      } else if (error.message.toLowerCase().contains('password')) {
        return 'La contraseña no cumple con los requisitos';
      } else if (error.message.toLowerCase().contains('user already registered')) {
        return 'Este email ya está registrado';
      } else if (error.message.toLowerCase().contains('email not confirmed')) {
        return 'Debes confirmar tu email. Revisa tu bandeja';
      } else {
        // Devolver mensaje completo para diagnóstico
        return 'Error: ${error.message}';
      }
  }
}
```

**Ventajas:**
- Traduce errores al español
- Analiza el contenido del mensaje
- Proporciona mensajes amigables
- Incluye diagnóstico detallado

---

### 4.5. Modelo AppUser

```dart
class AppUser {
  final String id;
  final String email;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.metadata,
    this.createdAt,
  });

  // Crear AppUser desde User de Supabase
  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      metadata: user.userMetadata,    // ← Datos adicionales
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  // Obtener nombre desde metadata
  String get name => metadata?['name'] ?? email.split('@')[0];

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
```

**¿Qué es metadata?**
Son datos adicionales que se guardan con el usuario:
```dart
metadata = {
  'name': 'Juan Pérez',
  'phone': '+56912345678',
  'address': 'Calle 123',
}
```

---

### 4.6. Clase AuthResult

```dart
class AuthResult {
  final bool isSuccess;
  final AppUser? user;
  final String? message;  // ← Mensaje de éxito
  final String? error;    // ← Mensaje de error

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });

  // Resultado exitoso
  factory AuthResult.success({
    required AppUser? user,
    String? message,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  // Resultado con error
  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
```

**Uso:**
```dart
final result = await authService.signIn(...);

if (result.isSuccess) {
  print('✅ ${result.message}');
  print('Usuario: ${result.user!.name}');
} else {
  print('❌ ${result.error}');
}
```

---

## 🚀 5. Punto de Entrada (main.dart)

### ¿Qué hace?
Inicializa la app y configura navegación automática basada en autenticación.

### Código explicado:

```dart
void main() async {
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación (solo vertical)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar Supabase
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    print('Error al inicializar Supabase: $e');
    // Continuar incluso si falla (útil en desarrollo)
  }
  
  runApp(const MyApp());
}
```

---

### Verificador de Autenticación (AuthChecker)

```dart
class _AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // IMPORTANTE: Usar StreamBuilder para escuchar cambios
    return StreamBuilder(
      stream: AuthService().authStateChanges,  // ← Stream de cambios
      builder: (context, snapshot) {
        // Mientras carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Verificar si hay sesión activa
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          // ✅ Usuario autenticado → Home
          return const ResidentHomeScreen();
        }
        
        // ❌ No autenticado → Login
        return const LoginScreen();
      },
    );
  }
}
```

### ¿Por qué StreamBuilder?

**Ventajas:**
1. **Navegación automática**: Cuando el usuario inicia sesión, automáticamente va a Home
2. **Cierre de sesión automático**: Si se cierra sesión, automáticamente va a Login
3. **Sincronización**: Si el token expira, automáticamente expulsa al usuario
4. **Menos código**: No necesitas `Navigator.push()` manual

**Flujo:**
```
App inicia
    ↓
StreamBuilder escucha cambios de auth
    ↓
¿Hay sesión?
    ↓
Sí → Muestra ResidentHomeScreen
No → Muestra LoginScreen
    ↓
Usuario hace login
    ↓
Stream detecta cambio
    ↓
Automáticamente cambia a ResidentHomeScreen
```

---

## 📱 6. Pantalla de Login

### Código simplificado:

```dart
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          // Mostrar mensaje de bienvenida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${result.user!.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          // NO NECESITA NAVEGAR MANUALMENTE
          // El StreamBuilder en main.dart lo hace automáticamente
        } else {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error de autenticación'),
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

**Nota importante:** No usa `Navigator.push()` porque el `StreamBuilder` detecta el cambio de autenticación y navega automáticamente.

---

## 📋 7. Registro en 3 Pasos (Actualizado)

### ¿Qué es?
El registro se divide en 3 pasos principales:

```
Paso 1: Crear Cuenta (Email y contraseña)
   ↓
Paso 2: Verificar Email (Código OTP de 6 dígitos + opción "Saltar")
   ↓
Paso 3: Wizard de Registro Completo
   ↓
¡Registro Completo!
```

### Nuevo Flujo de Verificación con OTP
- **Envío automático**: Código de 6 dígitos al email
- **Validación**: Código correcto o botón "Saltar"
- **Countdown**: Botón de reenvío con countdown de 60 segundos
- **Diseño**: Estilo verde unificado con diseño de Bomberos

### Estructura:

```dart
// Modelo que guarda datos de todos los pasos
class RegistrationData {
  // Paso 1: Cuenta
  String? email;
  String? password;
  
  // Paso 2: Titular
  String? name;
  String? rut;
  String? phone;
  
  // Paso 3: Residencia
  String? address;
  String? block;
  String? department;
  
  // Paso 4: Vivienda
  int? numRooms;
  int? numBathrooms;
  bool? hasGarden;
}
```

### Navegación entre pasos:

```dart
// Step1 → Step2
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Step2HolderData(
      registrationData: registrationData,  // Pasar datos
    ),
  ),
);

// Step2 → Step3
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Step3ResidenceInfo(
      registrationData: registrationData,  // Pasar datos acumulados
    ),
  ),
);
```

**Ventajas:**
- Formularios más cortos y manejables
- Usuario no se abruma
- Puede volver atrás y corregir
- Datos se van acumulando

---

## 🏠 8. Pantalla Principal (ResidentHomeScreen)

### Estructura con Tabs:

```dart
class ResidentHomeScreen extends StatefulWidget {
  @override
  _ResidentHomeScreenState createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;  // Tab actual

  final List<Widget> _tabs = [
    const FamilyTab(),      // Tab 0: Familia
    const PetsTab(),        // Tab 1: Mascotas
    const ResidenceTab(),   // Tab 2: Residencia
    const SettingsTab(),    // Tab 3: Configuración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Residencia'),
      ),
      body: _tabs[_currentIndex],  // ← Mostrar tab actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Familia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Residencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 Flujo Completo de Autenticación

### Flujo de Registro:

```
Usuario abre app
    ↓
StreamBuilder detecta: No hay sesión
    ↓
Muestra LoginScreen
    ↓
Usuario presiona "Regístrate"
    ↓
Navega a RegisterScreen
    ↓
Usuario completa wizard de registro:
  - Paso 1: Email y contraseña
  - Paso 2: Datos personales
  - Paso 3: Dirección
  - Paso 4: Detalles de vivienda
    ↓
Se envía todo a Supabase
    ↓
Supabase crea usuario en auth.users
    ↓
Se guardan datos adicionales en BD
    ↓
Sesión se crea automáticamente
    ↓
StreamBuilder detecta: Nueva sesión
    ↓
Automáticamente muestra ResidentHomeScreen
```

### Flujo de Login:

```
Usuario abre app (ya registrado)
    ↓
StreamBuilder detecta: No hay sesión
    ↓
Muestra LoginScreen
    ↓
Usuario ingresa email y contraseña
    ↓
AuthService.signIn()
    ↓
Supabase valida credenciales
    ↓
Si es correcto: Crea sesión
    ↓
StreamBuilder detecta: Nueva sesión
    ↓
Automáticamente navega a ResidentHomeScreen
```

### Flujo de Persistencia:

```
Usuario cierra la app
    ↓
Supabase guarda token localmente
    ↓
Usuario abre la app de nuevo
    ↓
StreamBuilder verifica token
    ↓
Si es válido: Muestra ResidentHomeScreen directamente
Si expiró: Muestra LoginScreen
```

---

## 🆚 Diferencias con Bomberos y Grifos

| Aspecto | Bomberos/Grifos | Residente |
|---------|----------------|-----------|
| **Navegación** | Manual con Navigator.push | Automática con StreamBuilder |
| **Registro** | Formulario único | Wizard multi-paso |
| **AuthService** | supabase_auth_service.dart | auth_service.dart |
| **Usuario** | UserData | AppUser |
| **Metadata** | No usa | Sí usa (nombre, teléfono, etc.) |
| **PKCE** | No configurado | Sí configurado (más seguro) |
| **Logs** | Básicos | Detallados para debugging |
| **Estructura** | Más simple | Más modular (tabs, steps) |

---

## 🔒 Seguridad Adicional

### PKCE (Proof Key for Code Exchange):

```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,  // ← Seguridad adicional
  ),
);
```

**¿Qué hace PKCE?**
- Genera un código secreto único por cada login
- El código solo lo conoce la app y el servidor
- Previene ataques de intercepción de tokens
- Estándar OAuth 2.0 para apps móviles

---

## 📊 Base de Datos

### Si comparte usuarios con Bomberos/Grifos:

Usa las mismas tablas:
- `auth.users` - Usuarios de Supabase
- `profiles` - Perfiles adicionales

### Si tiene BD separada:

Puede tener tablas adicionales:
```sql
-- Residencias
CREATE TABLE residences (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  address TEXT,
  block TEXT,
  department TEXT,
  ...
);

-- Miembros de familia
CREATE TABLE family_members (
  id UUID PRIMARY KEY,
  residence_id UUID REFERENCES residences(id),
  name TEXT,
  age INT,
  ...
);

-- Mascotas
CREATE TABLE pets (
  id UUID PRIMARY KEY,
  residence_id UUID REFERENCES residences(id),
  name TEXT,
  species TEXT,
  ...
);
```

---

## 🐛 Troubleshooting

### Error: "Credenciales no configuradas"

**Problema:** No encuentra el archivo `.env`  
**Solución:**
```bash
# Crear archivo .env en la raíz
echo "SUPABASE_URL=tu-url" > .env
echo "SUPABASE_ANON_KEY=tu-clave" >> .env
```

### Error: "Email ya registrado"

**Problema:** El email ya existe en la BD  
**Solución:** Usar otro email o recuperar contraseña

### La navegación no funciona automáticamente

**Problema:** StreamBuilder no detecta cambios  
**Verificar:**
1. Que AuthService retorne el stream correcto
2. Que el widget use StreamBuilder
3. Que no haya errores en el login

---

## 📝 Resumen

### Componentes principales:

1. **`.env`** → Credenciales (pueden ser compartidas o separadas)
2. **`supabase_config.dart`** → Configuración con PKCE
3. **`auth_service.dart`** → Autenticación con logs detallados
4. **`AppUser` y `AuthResult`** → Modelos de datos
5. **`main.dart`** → StreamBuilder para navegación automática
6. **Registro por pasos** → Wizard multi-paso
7. **Tabs** → Navegación entre secciones

### Flujo resumido:

```
App inicia → StreamBuilder escucha → Muestra Login/Home según sesión
Usuario hace login → AuthService.signIn() → Stream detecta cambio → Auto-navega
```

---

## 🎓 Conceptos Clave

### 1. StreamBuilder:
```dart
// Escucha cambios en tiempo real
StreamBuilder(
  stream: AuthService().authStateChanges,
  builder: (context, snapshot) {
    // Se ejecuta cada vez que cambia el stream
  },
)
```

### 2. Metadata:
```dart
// Datos adicionales del usuario
signUp(
  email: 'usuario@ejemplo.com',
  password: 'pass123',
  metadata: {
    'name': 'Juan',
    'phone': '+56912345678',
  },
);
```

### 3. Wizard Multi-Paso:
```dart
// Navegación secuencial con datos acumulados
Step1 → registrationData → Step2 → registrationData → Step3 → ...
```

### 4. PKCE:
```dart
// Seguridad adicional para apps móviles
authOptions: FlutterAuthClientOptions(
  authFlowType: AuthFlowType.pkce,
),
```

---

## 🎨 Diseño Verde Unificado

### Características del Diseño
- **Gradiente verde**: `Colors.green.shade400` a `Colors.green.shade700`
- **Círculos blancos**: Contenedores circulares con iconos en verde
- **Sombras suaves**: BoxShadow para profundidad
- **Formularios blancos**: Contenedores blancos con bordes redondeados
- **Botones verdes**: Botones principales en verde con texto blanco

### Pantallas con Diseño Verde
- ✅ `initial_registration_screen.dart` - Paso 1 de registro
- ✅ `email_verification_screen.dart` - Verificación con OTP
- ✅ `reset_password_with_code_screen.dart` - Reset de contraseña

### Consistencia Entre Apps
Ambas aplicaciones (Bomberos y Residente) ahora usan el mismo estilo visual en las pantallas de autenticación, mejorando la experiencia del usuario.

---

¿Tienes dudas? Revisa los logs detallados en la consola o consulta la documentación de Supabase. 🏘️

