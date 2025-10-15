# Configuración de Emails en Supabase

## Problema Identificado

El sistema de recuperación de contraseña no envía emails porque:

1. **Supabase usa un proveedor de email básico** por defecto (limitado)
2. **Está diseñado para desarrollo**, no para producción
3. **Puede tener restricciones** en el envío de emails

## Solución: Configurar SMTP Personalizado

### Paso 1: Configurar Proveedor SMTP en Supabase

1. **Ve a tu proyecto de Supabase**
2. **Navega a Settings > Authentication**
3. **Busca la sección "SMTP Settings"**
4. **Habilita "Enable custom SMTP"**

### Paso 2: Configurar Gmail (Recomendado para desarrollo)

```env
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP User: tu-email@gmail.com
SMTP Pass: tu-contraseña-de-aplicación
SMTP Admin Email: tu-email@gmail.com
SMTP Sender Name: Sistema de Emergencias
```

### Paso 3: Configurar Contraseña de Aplicación en Gmail

1. **Ve a tu cuenta de Google**
2. **Seguridad > Verificación en 2 pasos**
3. **Contraseñas de aplicaciones**
4. **Generar nueva contraseña**
5. **Usar esta contraseña en SMTP Pass**

### Paso 4: Configurar Templates de Email (Opcional)

En Supabase, puedes personalizar los templates de email:

1. **Settings > Authentication > Email Templates**
2. **Selecciona "Reset Password"**
3. **Personaliza el contenido del email**

## Configuración Alternativa: Mailgun/SendGrid

Para producción, considera usar:

### Mailgun
```env
SMTP Host: smtp.mailgun.org
SMTP Port: 587
SMTP User: postmaster@tu-dominio.mailgun.org
SMTP Pass: tu-api-key
```

### SendGrid
```env
SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP User: apikey
SMTP Pass: tu-sendgrid-api-key
```

## Verificación de Configuración

### 1. Probar desde el Dashboard de Supabase

1. **Ve a Authentication > Users**
2. **Crea un usuario de prueba**
3. **Usa "Send recovery email"**
4. **Verifica que llegue el email**

### 2. Probar desde la Aplicación

```dart
// El código ya está corregido para usar el servicio real
final result = await _authService.resetPassword(
  email: 'usuario@ejemplo.com',
);

if (result.isSuccess) {
  print('✅ Email enviado correctamente');
} else {
  print('❌ Error: ${result.message}');
}
```

## Troubleshooting

### Error: "Email not confirmed"
- **Causa**: El email no está confirmado en Supabase
- **Solución**: Confirmar email manualmente en el dashboard

### Error: "Rate limit exceeded"
- **Causa**: Demasiados intentos de envío
- **Solución**: Esperar unos minutos antes de intentar de nuevo

### Error: "SMTP configuration invalid"
- **Causa**: Credenciales SMTP incorrectas
- **Solución**: Verificar host, puerto, usuario y contraseña

## Configuración de URL de Redirección

### Paso Importante: Configurar URL de Reset Password

1. **Ve a tu proyecto de Supabase**
2. **Settings > Authentication > URL Configuration**
3. **En "Redirect URLs" agrega:**
   ```
   http://localhost:3000/reset-password
   ```
   (Para desarrollo local)

4. **Para producción, agrega tu dominio:**
   ```
   https://tu-dominio.com/reset-password
   ```

### Configuración de Desarrollo vs Producción

### Desarrollo (Gmail)
```env
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP User: tu-email-desarrollo@gmail.com
SMTP Pass: contraseña-de-aplicación
Redirect URL: http://localhost:3000/reset-password
```

### Producción (Servicio Profesional)
```env
SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP User: apikey
SMTP Pass: tu-api-key-producción
Redirect URL: https://tu-dominio.com/reset-password
```

## Logs y Monitoreo

### Verificar Logs en Supabase
1. **Dashboard > Logs**
2. **Filtrar por "Auth"**
3. **Buscar errores relacionados con email**

### Mensajes de Error Comunes
- `user_recovery_denied`: Email no encontrado o no confirmado
- `smtp_error`: Problema con configuración SMTP
- `rate_limit_exceeded`: Demasiados intentos

## Próximos Pasos

1. **Configurar SMTP personalizado** en Supabase
2. **Probar envío de emails** desde el dashboard
3. **Verificar que los emails lleguen** correctamente
4. **Configurar templates** personalizados (opcional)

## Notas Importantes

- **Gmail tiene límites** de envío (500 emails/día)
- **Para producción**, usa servicios profesionales como SendGrid
- **Los emails pueden ir a spam** inicialmente
- **Verifica la configuración** antes de lanzar a usuarios reales
