# 📧 Guía de Configuración: Verificación de Email con Código en Supabase

## 📋 Descripción

Esta guía explica cómo configurar la verificación de correo electrónico con código OTP (One-Time Password) en Supabase para la aplicación Residente.

---

## ✅ Estado de Implementación

**SÍ, está implementado** ✅

La aplicación Residente incluye:
- ✅ Pantalla de verificación de email (`email_verification_screen.dart`)
- ✅ Servicio de autenticación con verificación de código (`unified_auth_service.dart`)
- ✅ Envío de código por email
- ✅ Reenvío de código con cuenta regresiva
- ✅ Validación de código OTP de 6 dígitos
- ✅ Opción de saltar verificación (desarrollo)

---

## 🛠️ Configuración en Supabase

### Paso 1: Acceder a Configuración de Autenticación

1. Inicia sesión en tu proyecto Supabase: https://supabase.com
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Authentication**
4. Haz clic en **Settings** (Configuración)

---

### Paso 2: Configurar Plantillas de Email

#### 2.1. Plantilla de Verificación de Email (Confirm signup)

1. En la sección **Email Templates**
2. Selecciona **Confirm signup** (Confirmar registro)
3. Configura la plantilla:

**Título del Email:**
```
Confirma tu correo electrónico
```

**Contenido del Email:**
```html
<h2>Verificación de Email</h2>

<p>Hola,</p>

<p>Gracias por registrarte en Sistema de Emergencias.</p>

<p>Tu código de verificación es:</p>

<h2 style="background-color: #f0f0f0; padding: 20px; text-align: center; font-family: monospace; letter-spacing: 5px; font-size: 32px;">
{{ .Token }}
</h2>

<p><strong>Este código expira en 10 minutos.</strong></p>

<p>Si no solicitaste este código, puedes ignorar este mensaje.</p>

<hr>

<p style="color: #666; font-size: 12px;">
Este es un email automático, por favor no respondas.
</p>
```

**Configuración adicional:**
- ✅ Habilitar **OTP (One-Time Password)**: Activar esta opción
- ✅ Duración del código: `600` (10 minutos)

---

#### 2.2. Habilitar OTP en Configuración

1. En **Authentication > Settings**
2. Busca la sección **Email Auth**
3. Asegúrate de que esté activado:
   - ✅ **Enable email confirmations**
   - ✅ **Enable OTP/SMS confirmations**

---

### Paso 3: Configurar SMTP (Opcional pero Recomendado)

Por defecto, Supabase usa un servicio de email limitado. Para producción, configura tu propio SMTP.

#### 3.1. Configuración SMTP

1. En **Authentication > Settings**
2. Busca la sección **SMTP Settings**
3. Activa **Enable Custom SMTP**

**Configuración para Gmail:**
```
SMTP Host: smtp.gmail.com
SMTP Port: 465
SMTP User: tu-email@gmail.com
SMTP Password: [App Password de Gmail]
Sender email: tu-email@gmail.com
Sender name: Sistema de Emergencias
```

**Nota:** Para Gmail, necesitas crear una "App Password":
1. Ve a tu cuenta de Google
2. Security > 2-Step Verification > App passwords
3. Genera una contraseña de aplicación
4. Usa esa contraseña en SMTP

**Configuración para otros proveedores:**
- **SendGrid**: https://sendgrid.com
- **Mailgun**: https://mailgun.com
- **Amazon SES**: https://aws.amazon.com/ses/

---

### Paso 4: Configurar URLs de Redirección

1. En **Authentication > Settings**
2. Busca **Site URL** y **Redirect URLs**
3. Configura:

**Site URL:**
```
https://tu-dominio.com
```

**Redirect URLs (Agregar todos):**
```
https://tu-dominio.com/**
https://localhost:3000/**
http://localhost:3000/**
```

---

### Paso 5: Configurar Variables de Entorno (App)

1. En tu aplicación Flutter Residente
2. Abre el archivo `.env`
3. Verifica que tenga:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
```

---

## 🔍 Verificación de Funcionamiento

### 1. Probar en la App

1. Abre la app Residente
2. Ve a **Registrarse**
3. Completa el paso 1 (crear cuenta)
4. Deberías ver la pantalla de verificación
5. Revisa tu correo (incluye carpeta SPAM)
6. Ingresa el código recibido

### 2. Verificar en Supabase

1. Ve a **Authentication > Users**
2. Busca el usuario recién registrado
3. Verifica que el estado sea:
   - **Email Confirmed**: `false` (antes de verificar)
   - **Email**: El correo que usaste

### 3. Probar Reenvío

1. En la pantalla de verificación
2. Espera el conteo regresivo de 60 segundos
3. Haz clic en **Reenviar código**
4. Revisa tu correo nuevamente

---

## 📱 Código de la Implementación

### 1. Envío de Código (Automatic)

**Archivo:** `Residente/lib/services/unified_auth_service.dart`

```dart
Future<AuthResult> registerWithEmail(
  String email,
  String password, {
  bool sendEmailVerification = false,
}) async {
  final response = await _client.auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: sendEmailVerification ? 'https://tu-app.com/verify' : null,
  );
  // ...
}
```

### 2. Verificación de Código

**Archivo:** `Residente/lib/services/unified_auth_service.dart`

```dart
Future<AuthResult> verifyEmailCode(String code) async {
  final response = await _client.auth.verifyOTP(
    type: OtpType.signup,
    token: code,
    email: currentUser.email!,
  );
  // ...
}
```

### 3. Reenvío de Código

**Archivo:** `Residente/lib/services/unified_auth_service.dart`

```dart
Future<void> resendEmailVerification({String? email}) async {
  await _client.auth.resend(
    type: OtpType.signup,
    email: emailToUse,
  );
}
```

---

## 🐛 Troubleshooting

### Problema 1: No llega el email

**Causas posibles:**
1. Email en carpeta SPAM
2. Límite de emails de Supabase excedido (200/día en plan gratis)
3. SMTP no configurado

**Solución:**
- Verifica carpeta SPAM
- Configura SMTP personalizado
- Revisa límites en **Authentication > Settings > Email Auth**

### Problema 2: Código expirado

**Causa:**
- El código expira después de 10 minutos

**Solución:**
- Usa el botón "Reenviar código" para obtener uno nuevo
- Espera los 60 segundos del countdown

### Problema 3: Código inválido

**Causas posibles:**
1. Código incorrecto ingresado
2. Usuario no existe en Supabase
3. Token de OTP incorrecto

**Solución:**
- Verifica que el código tenga exactamente 6 dígitos
- Asegúrate de que el usuario esté registrado
- Revisa logs en Supabase: **Logs > Auth Logs**

### Problema 4: Error "OTP not enabled"

**Causa:**
- OTP no está habilitado en configuración de Supabase

**Solución:**
1. Ve a **Authentication > Settings**
2. Activa **Enable OTP/SMS confirmations**
3. Guarda cambios

---

## 📊 Monitoreo

### Ver Emails Enviados

1. Ve a **Authentication > Users**
2. Selecciona un usuario
3. Revisa el historial de emails enviados

### Ver Logs de Autenticación

1. Ve a **Logs**
2. Selecciona **Auth Logs**
3. Revisa intentos de verificación

### Ver Estadísticas

1. Ve a **Dashboard**
2. Busca **Authentication** en el panel
3. Revisa:
   - Emails enviados
   - Emails confirmados
   - Intentos fallidos

---

## 🔐 Seguridad

### Buenas Prácticas

1. ✅ **Código de 6 dígitos**: Balance entre seguridad y usabilidad
2. ✅ **Expiración de 10 minutos**: Previene reutilización
3. ✅ **Límite de reenvíos**: Cuenta regresiva de 60 segundos
4. ✅ **Validación en backend**: Supabase valida el código
5. ✅ **No exponer token**: El código solo se usa una vez

### Consideraciones

- ⚠️ **SMTP personalizado**: Necesario para producción
- ⚠️ **Rate limiting**: Supabase limita emails (200/día en gratis)
- ⚠️ **Backup de códigos**: Los códigos no se almacenan localmente

---

## 📝 Plantilla Personalizada Completa

Para una plantilla más completa y profesional:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px;">
  
  <div style="max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
    
    <!-- Logo -->
    <div style="text-align: center; margin-bottom: 30px;">
      <h1 style="color: #2196F3; margin: 0;">Sistema de Emergencias</h1>
    </div>
    
    <!-- Título -->
    <h2 style="color: #333; margin-top: 0;">¡Bienvenido! 🎉</h2>
    
    <!-- Mensaje -->
    <p style="color: #666; line-height: 1.6;">
      Gracias por registrarte en nuestro sistema. Para completar tu registro, 
      verifica tu correo electrónico ingresando el siguiente código:
    </p>
    
    <!-- Código -->
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0;">
      <p style="color: white; margin: 0 0 10px 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">
        Tu código de verificación
      </p>
      <p style="color: white; font-size: 36px; font-weight: bold; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">
        {{ .Token }}
      </p>
    </div>
    
    <!-- Advertencia -->
    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;">
      <p style="color: #856404; margin: 0; font-size: 14px;">
        ⏰ <strong>Importante:</strong> Este código expira en 10 minutos. 
        Si no solicitaste este código, puedes ignorar este mensaje.
      </p>
    </div>
    
    <!-- Instrucciones -->
    <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
      <h3 style="color: #333; font-size: 16px; margin-bottom: 10px;">¿Cómo usar este código?</h3>
      <ol style="color: #666; line-height: 1.8; padding-left: 20px;">
        <li>Abre la aplicación en tu dispositivo</li>
        <li>Ingresa el código de 6 dígitos mostrado arriba</li>
        <li>Presiona "Verificar" para completar tu registro</li>
      </ol>
    </div>
    
    <!-- Footer -->
    <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee; text-align: center;">
      <p style="color: #999; font-size: 12px; margin: 0;">
        © 2024 Sistema de Emergencias. Todos los derechos reservados.
      </p>
      <p style="color: #999; font-size: 12px; margin: 10px 0 0 0;">
        Este es un email automático, por favor no respondas.
      </p>
    </div>
    
  </div>
  
</body>
</html>
```

---

## ✅ Checklist de Configuración

Usa este checklist para asegurarte de que todo esté configurado:

- [ ] OTP habilitado en **Authentication > Settings**
- [ ] Email confirmations habilitado
- [ ] Plantilla "Confirm signup" configurada
- [ ] Código `{{ .Token }}` incluido en plantilla
- [ ] SMTP personalizado configurado (producción)
- [ ] Site URL configurado en Supabase
- [ ] Redirect URLs configuradas
- [ ] Variables `.env` actualizadas en la app
- [ ] Probar registro con email válido
- [ ] Verificar recepción de email
- [ ] Probar ingreso de código
- [ ] Verificar cuenta regresiva de reenvío

---

## 📞 Soporte

Si después de seguir esta guía aún tienes problemas:

1. **Revisa los logs** en Supabase: **Logs > Auth Logs**
2. **Verifica la configuración** en la consola de Supabase
3. **Consulta la documentación oficial**: https://supabase.com/docs/guides/auth

---

**Última actualización:** Diciembre 2024
**Versión de Supabase:** v2.x
**Versión de Flutter:** ^3.9.0

