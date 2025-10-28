# Configuración de Verificación de Email con Código OTP en Supabase

Este documento detalla paso a paso cómo configurar Supabase para que funcione la verificación de correo electrónico con código OTP en tu aplicación Flutter.

## Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Paso 1: Acceder al Panel de Supabase](#paso-1-acceder-al-panel-de-supabase)
3. [Paso 2: Configurar Authentication](#paso-2-configurar-authentication)
4. [Paso 3: Configurar Email Templates](#paso-3-configurar-email-templates)
5. [Paso 4: Configurar URLs de Redirección](#paso-4-configurar-urls-de-redirección)
6. [Paso 5: Configurar Límites de Email](#paso-5-configurar-límites-de-email)
7. [Paso 6: Probar la Configuración](#paso-6-probar-la-configuración)
8. [Paso 7: Configurar Reset de Contraseña con Código OTP](#paso-7-configurar-reset-de-contraseña-con-código-otp)
9. [Solución de Problemas](#solución-de-problemas)
10. [Costos y Límites del Plan Gratuito](#costos-y-límites-del-plan-gratuito)

---

## Requisitos Previos

- Tener una cuenta en Supabase (crear una en [https://supabase.com](https://supabase.com))
- Tener un proyecto creado en Supabase
- Conocer la URL de tu proyecto: `https://tu-proyecto.supabase.co`
- Tener las credenciales de tu proyecto (anon key y service role key)

---

## Paso 1: Acceder al Panel de Supabase

1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto desde el listado

---

## Paso 2: Configurar Authentication

### 2.1 Habilitar Confirmación de Email

1. En el panel izquierdo, haz clic en **Authentication** (🔐)
2. Ve a la sección **Settings** o **Configuración**
3. Busca la opción **"Enable email confirmations"** o **"Habilitar confirmaciones de email"**
4. **Activa** esta opción (toggle)

### 2.2 Configurar el Método de Confirmación

1. En la misma sección, busca **"Email confirmation type"** o **"Tipo de confirmación de email"**
2. Selecciona **"OTP (One-Time Password)"** o **"Código de un solo uso"**
   - Esto hará que Supabase envíe un código de 6 dígitos en lugar de un enlace

### 2.3 Configurar Timeout de Código

1. Busca **"OTP expiration time"** o **"Tiempo de expiración OTP"**
2. Configura el tiempo que estará válido el código (recomendado: 3600 segundos = 1 hora)

**Captura de pantalla esperada:**
```
☑️ Enable email confirmations
📧 Email confirmation type: [OTP (One-Time Password)] ▼
⏱️ OTP expiration time: [3600] segundos
```

---

## Paso 3: Configurar Email Templates

Los templates de email controlan el contenido que reciben los usuarios.

### 3.1 Acceder a Email Templates

1. En **Authentication** → **Settings**
2. Haz scroll hacia abajo hasta encontrar **"Email Templates"** o **"Plantillas de Email"**
3. Busca la plantilla **"Confirm signup"** o **"Confirmar registro"**

### 3.2 Personalizar el Template

El código actual del template debería verse así:

```html
<h2>Confirma tu correo electrónico</h2>

<p>Sigue este enlace para confirmar tu usuario:</p>
<p><a href="{{ .ConfirmationURL }}">Confirmar mi correo</a></p>
```

**Reemplázalo con el siguiente código para OTP:**

```html
<h2>Confirma tu correo electrónico</h2>

<p>Tu código de verificación es:</p>

<h1 style="font-size: 32px; letter-spacing: 5px; text-align: center; padding: 20px; background-color: #f0f0f0; border-radius: 8px;">
{{ .Token }}
</h1>

<p>Este código expirará en 1 hora.</p>

<p>Si no solicitaste este código, puedes ignorar este correo.</p>
```

### 3.3 Variables Disponibles

- `{{ .Token }}` - El código OTP de 6 dígitos
- `{{ .Email }}` - El correo electrónico del usuario
- `{{ .SiteURL }}` - URL de tu sitio
- `{{ .ConfirmationURL }}` - URL de confirmación (no se usa para OTP)

### 3.4 Guardar los Cambios

1. Haz clic en **"Save"** o **"Guardar"** al final de la página
2. Espera a que aparezca el mensaje de confirmación

---

## Paso 4: Configurar URLs de Redirección

Aunque uses OTP, es necesario configurar URLs permitidas para seguridad.

### 4.1 Site URL

1. En **Authentication** → **URL Configuration**
2. En **"Site URL"**, escribe la URL de tu aplicación:
   - Para desarrollo: `http://localhost:3000` o tu URL local
   - Para producción: Tu URL de producción

### 4.2 Redirect URLs

1. En **"Redirect URLs"**, agrega las URLs permitidas:

```
http://localhost:3000/**
http://localhost:3000/auth/callback
com.tuapp://**/*
https://tu-dominio.com/**
```

**Nota:** Si usas deep links en Flutter, agrega tu scheme personalizado (ej: `com.firedata://**`)

### 4.3 Configurar Email Redirect To (Opcional)

1. Busca **"Email redirect to"** o **"Redirección de email"**
2. Configura la URL a la que se redirigirá después de confirmar:
   ```
   com.tuapp://auth/verify
   ```

---

## Paso 5: Configurar Límites de Email

En el plan gratuito, Supabase tiene límites estrictos de envío de emails.

### 5.1 Límites del Plan Gratuito

- **2 emails por hora por usuario**
- Disponibilidad: "Mejor esfuerzo" (no garantizada)
- No recomendado para producción

### 5.2 Configurar SMTP Externo (Recomendado para Producción)

Para producción, configura un servidor SMTP externo:

1. En **Project Settings** (⚙️) → **Auth** → **SMTP Settings**
2. Haz clic en **"Configure SMTP"**
3. Ingresa los datos de tu proveedor SMTP:

**Ejemplo con Gmail:**
```
Host: smtp.gmail.com
Port: 587
Username: tu-email@gmail.com
Password: tu-app-password
Sender email: tu-email@gmail.com
Sender name: Tu App Name
```

**Ejemplo con SendGrid (Gratis hasta 100 emails/día):**
```
Host: smtp.sendgrid.net
Port: 587
Username: apikey
Password: tu-api-key
Sender email: verified-sender@tu-dominio.com
```

4. Haz clic en **"Save"** o **"Guardar"**

### 5.3 Verificar Configuración SMTP

1. Haz clic en **"Send test email"** para verificar que funciona
2. Revisa tu bandeja de entrada (y spam)

---

## Paso 6: Probar la Configuración

### 6.1 Crear Usuario de Prueba desde Supabase

1. Ve a **Authentication** → **Users**
2. Haz clic en **"Add User"** o **"Agregar Usuario"**
3. Ingresa un email de prueba
4. Genera una contraseña
5. Haz clic en **"Create User"**

### 6.2 Enviar Código de Verificación Manualmente

1. En la lista de usuarios, encuentra el usuario que creaste
2. Haz clic en los **tres puntos** (⋮) al lado del usuario
3. Selecciona **"Send confirmation email"**
4. Revisa el correo del usuario
5. Verifica que recibiste el código OTP de 6 dígitos

### 6.3 Probar desde tu App Flutter

1. Ejecuta tu aplicación Flutter
2. Intenta registrarte con un correo válido
3. Verifica que recibiste el correo con el código
4. Ingresa el código en la pantalla de verificación
5. Confirma que puedes continuar con el registro

---

## Paso 7: Configurar Reset de Contraseña con Código OTP

### 7.1 Configurar Template de Email para Reset de Contraseña

1. En **Authentication** → **Email Templates**, busca el template **"Password reset"**
2. Personaliza el template con el siguiente código:

```html
<h2>Recupera tu contraseña</h2>

<p>Tu código de verificación es:</p>

<h1 style="font-size: 32px; letter-spacing: 5px; text-align: center; padding: 20px; background-color: #f0f0f0; border-radius: 8px;">
{{ .Token }}
</h1>

<p>Este código expirará en 1 hora.</p>

<p>Si no solicitaste recuperar tu contraseña, puedes ignorar este correo.</p>
```

### 7.2 Habilitar Reset de Contraseña por Código

1. En **Authentication** → **Settings**
2. Busca **"Password reset"** o **"Recuperación de contraseña"**
3. Configura como **"OTP (One-Time Password)"** en lugar de URL

**Nota importante:** El parámetro `shouldCreateUser: false` en el código garantiza que **solo se envíen códigos a emails que ya están registrados**, evitando ataques de enumeración.

### 7.3 Flujo Completo de Reset de Contraseña

El flujo implementado es:

1. **Usuario ingresa su email** en "Olvidé mi contraseña"
2. **Supabase verifica** que el email esté registrado (gracias a `shouldCreateUser: false`)
3. **Se envía código OTP** de 6 dígitos al email
4. **Usuario ingresa el código** y su nueva contraseña
5. **Supabase verifica el código** y actualiza la contraseña
6. **Usuario es redirigido al login**

### 7.4 Ventajas de este Método

✅ **Más seguro:** No requiere deep links
✅ **Más simple:** No necesita configuración de Android/iOS
✅ **Mejor UX:** Usuario ve el código directamente en el email
✅ **Verificación automática:** Solo emails registrados reciben códigos

---

## Solución de Problemas

### ❌ No recibo el correo de verificación

**Causas posibles:**

1. **Límite de emails alcanzado** (plan gratuito: 2/hora)
   - **Solución:** Espera 1 hora o configura SMTP externo

2. **Email en la carpeta de spam**
   - **Solución:** Revisa la carpeta de spam o correo no deseado

3. **Template de email mal configurado**
   - **Solución:** Revisa que el template tenga `{{ .Token }}` y esté configurado correctamente

4. **Confirmación de email deshabilitada**
   - **Solución:** Ve a Authentication → Settings y activa "Enable email confirmations"

5. **Código expirado**
   - **Solución:** Solicita un nuevo código (haz clic en "Reenviar código")

### ❌ El código no funciona

**Causas posibles:**

1. **Código expirado** (por defecto expira en 1 hora)
   - **Solución:** Solicita un nuevo código

2. **Código incorrecto**
   - **Solución:** Verifica que ingresaste el código correcto (6 dígitos)

3. **Usuario ya verificado**
   - **Solución:** Inicia sesión directamente

### ❌ Error "Rate limit exceeded"

**Causa:** Has enviado demasiados correos en poco tiempo

**Solución:**
1. Espera 1 hora
2. Configura SMTP externo para mayor límite
3. Aumenta el tiempo de espera entre reenvíos en tu app

---

## Costos y Límites del Plan Gratuito

### ✅ Incluido Gratis

- **Verificación de email con código OTP:** ✓ GRATIS
- **Reset de contraseña:** ✓ GRATIS
- **Autenticación de usuarios:** ✓ GRATIS
- **Hasta 50,000 usuarios activos:** ✓ GRATIS

### ⚠️ Limitaciones

- **2 correos por hora** por usuario
- **Disponibilidad:** "Mejor esfuerzo" (no garantizada en picos de carga)
- **Sin soporte por email**

### 💰 Opciones para Producción

#### Opción 1: SMTP Externo (Recomendado)

**Gratis:**
- **SendGrid:** 3,000 emails/mes gratis
- **Resend:** 3,000 emails/mes gratis
- **Mailgun:** 100 emails/día gratis (3 meses)

**Pago:**
- **SendGrid:** $15/mes por 40,000 emails
- **Resend:** $20/mes por 50,000 emails

**Configuración:** Ve a **Project Settings** → **Auth** → **SMTP Settings**

#### Opción 2: Plan Pro de Supabase

- **Precio:** $25/mes
- **Incluye:** 
  - 500K monthly active users
  - Email delivery garantizado
  - Soporte prioritario
  - Menos límites de rate

---

## Configuración Final Recomendada

Para el mejor balance costo/funcionalidad en desarrollo:

1. ✅ Usa el plan gratuito de Supabase
2. ✅ Configura SendGrid o Resend (gratis)
3. ✅ Activa "Email confirmation type: OTP"
4. ✅ Personaliza el template de email con el código
5. ✅ Configura redirect URLs para deep links

**Para producción:**

1. ✅ Configura SMTP con SendGrid o Resend
2. ✅ Verifica tu dominio
3. ✅ Aumenta los límites de timeout si es necesario
4. ✅ Considera el plan Pro si superas los 50K usuarios

---

## Checklist Final

Antes de pasar a producción, verifica:

- [ ] "Enable email confirmations" está activado
- [ ] "Email confirmation type" está configurado como "OTP"
- [ ] El template de email muestra `{{ .Token }}`
- [ ] Se configuró SMTP externo (para producción)
- [ ] Se probó envío y recepción de código
- [ ] Las URLs de redirección están configuradas
- [ ] El botón "Reenviar código" funciona
- [ ] El botón "Saltar verificación" funciona
- [ ] Se probó el flujo completo de registro

---

## Recursos Adicionales

- [Documentación de Supabase Auth](https://supabase.com/docs/guides/auth)
- [Email Templates de Supabase](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Configuración de OTP](https://supabase.com/docs/guides/auth/auth-passwordless)
- [Dashboard de Supabase](https://app.supabase.com)

---

## Contacto y Soporte

Si tienes problemas con la configuración:

1. Revisa este documento completo
2. Consulta la documentación oficial de Supabase
3. Busca en [Stack Overflow](https://stackoverflow.com/questions/tagged/supabase)
4. Únete a la [Discord de Supabase](https://discord.supabase.com)

---

**Última actualización:** Enero 2025
**Versión:** 1.0

