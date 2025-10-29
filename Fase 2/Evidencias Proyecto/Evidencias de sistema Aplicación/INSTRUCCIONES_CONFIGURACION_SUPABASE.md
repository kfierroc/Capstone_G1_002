# 🔧 Configuración Rápida de Supabase para Envío de Emails

## ⚠️ IMPORTANTE: Configuración Requerida en Supabase

Para que se envíen emails al crear cuentas, DEBES configurar Supabase siguiendo estos pasos:

### 1️⃣ Habilitar Confirmación de Email (OBLIGATORIO)

1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Authentication** → **Settings**
4. **ACTIVA** la opción **"Enable email confirmations"** ⚠️ (Sin esto NO se envían emails)
5. Selecciona **"Link"** como método de confirmación (NO OTP)
6. **ACTIVA** también **"Require email verification to sign in"** o **"Confirmar email para iniciar sesión"** (Si existe esta opción)

**Con esta configuración:**
- ✅ Los usuarios recibirán un email al registrarse
- ✅ NO podrán iniciar sesión hasta confirmar su email
- ✅ Al hacer clic en el enlace, se verificará automáticamente
- ✅ Después podrán iniciar sesión normalmente

### 2️⃣ Configurar URLs de Redirección

En **Authentication** → **URL Configuration**, agrega:

**Site URL:**
```
https://residente.firedata.app
```

**Redirect URLs (agrega TODAS estas líneas):**
```
https://residente.firedata.app/**
https://residente.firedata.app/verify
https://residente.firedata.app/reset-password
https://bomberos.firedata.app/**
https://bomberos.firedata.app/verify
https://bomberos.firedata.app/reset-password
```

**Importante:** Cada URL debe estar en una línea separada. Sin estas URLs configuradas, los enlaces del correo NO funcionarán correctamente.

### 3️⃣ Personalizar el Email Template

#### Email de Confirmación de Registro

1. Ve a **Authentication** → **Email Templates**
2. Selecciona la plantilla **"Confirm signup"**
3. Reemplaza el contenido con:

```html
<h2>Bienvenido a FireData</h2>

<p>Haz clic en el botón para verificar tu correo electrónico:</p>

<p><a href="{{ .ConfirmationURL }}" style="display: inline-block; padding: 12px 24px; background-color: #EF4444; color: white; text-decoration: none; border-radius: 8px; font-weight: bold;">Confirmar mi correo</a></p>

<p>Este enlace expirará en 1 hora.</p>

<p>Si no solicitaste este registro, puedes ignorar este correo.</p>
```

#### Email de Recuperación de Contraseña

1. En **Authentication** → **Email Templates**
2. Selecciona la plantilla **"Reset password"**
3. Reemplaza el contenido con:

```html
<h2>Recuperar Contraseña - FireData</h2>

<p>Haz clic en el botón para restablecer tu contraseña:</p>

<p><a href="{{ .ConfirmationURL }}" style="display: inline-block; padding: 12px 24px; background-color: #EF4444; color: white; text-decoration: none; border-radius: 8px; font-weight: bold;">Restablecer contraseña</a></p>

<p>Este enlace expirará en 1 hora.</p>

<p>Si no solicitaste este cambio, puedes ignorar este correo de forma segura.</p>
```

### 4️⃣ Configurar SMTP (IMPORTANTE para producción)

En el plan gratuito de Supabase, los emails tienen límites muy estrictos (2 por hora). Para producción, configura SMTP:

1. Ve a **Project Settings** → **Auth** → **SMTP Settings**
2. Haz clic en **"Configure SMTP"**
3. Usa un servicio gratuito como **SendGrid** o **Resend**:

**SendGrid (Gratis):**
- Crea cuenta en sendgrid.com
- Ve a Settings → API Keys → Create API Key
- Usa estos datos:
  - Host: `smtp.sendgrid.net`
  - Port: `587`
  - Username: `apikey`
  - Password: `tu-api-key-aqui`
  - Sender email: `noreply@firedata.app` (o tu email verificado)

### 5️⃣ Configurar Recuperación de Contraseña

Para que la recuperación de contraseña funcione correctamente:

1. Ve a **Authentication** → **URL Configuration**
2. En **Redirect URLs**, agrega estas URLs adicionales:
```
https://residente.firedata.app/reset-password
https://bomberos.firedata.app/reset-password
```

**Importante:** Estas URLs son diferentes de las de verificación y deben configurarse por separado.

### 6️⃣ Flujo Correcto de Recuperación de Contraseña

Cuando un usuario solicita recuperar su contraseña:

1. **Usuario ingresa email** → Presiona "Enviar Email"
2. **Pantalla de confirmación** → "Hemos enviado un enlace de recuperación a tu email"
3. **Usuario espera** → Mientras hace clic en el enlace del correo ✅
4. **Supabase detecta el evento** → `AuthChangeEvent.passwordRecovery`
5. **AuthRouter maneja el evento** → Navega a pantalla de nueva contraseña
6. **Usuario ingresa nueva contraseña** → ¡Listo!

**NO se navega inmediatamente a la pantalla de nueva contraseña después de enviar el email.** La app espera a que el usuario haga clic en el enlace.

### 7️⃣ Probar el Envío

Después de configurar:

1. Ejecuta la app de Residente o Bomberos
2. Intenta crear una cuenta
3. Verifica tu correo (revisa también spam)
4. Haz clic en el enlace recibido
5. La app debería abrir automáticamente

**Probar recuperación de contraseña:**
1. Ve a "Olvidé mi contraseña"
2. Ingresa tu email
3. **IMPORTANTE:** NO te redirige inmediatamente - muestra confirmación
4. Revisa tu correo y haz clic en el enlace
5. **AHORA SÍ** se abre la pantalla de nueva contraseña

---

## 🐛 Si NO se envían emails

### Verificación en Supabase:
1. Ve a **Authentication** → **Users**
2. Revisa si el usuario se creó correctamente
3. Si el usuario existe pero dice "Unconfirmed", el email no se envió

### Causas Comunes:
- ❌ "Enable email confirmations" no está activado
- ❌ Límite de emails alcanzado (plan gratuito: 2/hora)
- ❌ Email en carpeta de spam
- ❌ URLs de redirección no configuradas correctamente

### Solución Temporal:
Si necesitas probar sin SMTP:
1. Solicita reset de contraseña (también envía email)
2. Espera 1 hora entre pruebas
3. Configura SMTP para producción

---

## ✅ Resumen del Flujo de Recuperación de Contraseña

**Comportamiento correcto:**

1. ✅ Usuario ingresa email en "Olvidé mi contraseña"
2. ✅ Presiona "Enviar Email"
3. ✅ **Muestra pantalla de confirmación** ("Revisa tu correo...")
4. ✅ **NO navega inmediatamente** a la pantalla de nueva contraseña
5. ✅ Usuario hace clic en el enlace del correo
6. ✅ Supabase detecta el evento `passwordRecovery`
7. ✅ AuthRouter redirige automáticamente a pantalla de nueva contraseña
8. ✅ Usuario ingresa nueva contraseña y confirma
9. ✅ Contraseña actualizada y sesión cerrada

**Si la app navega inmediatamente a la pantalla de nueva contraseña después de enviar el email, el flujo está INCORRECTO y necesita ajustarse.**

---

**Después de configurar, reinicia la app y vuelve a intentar crear una cuenta.**

