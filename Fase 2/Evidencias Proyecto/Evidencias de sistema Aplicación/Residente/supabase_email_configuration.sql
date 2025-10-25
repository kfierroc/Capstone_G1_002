-- =====================================================
-- CONFIGURACIÓN DE SUPABASE PARA ENVÍO DE CORREOS
-- =====================================================

-- 1. Habilitar autenticación por email
-- En el dashboard de Supabase, ve a Authentication > Settings
-- Asegúrate de que "Enable email confirmations" esté activado

-- 2. Configurar plantillas de correo
-- En Authentication > Email Templates, configura:

-- Plantilla de Confirmación de Email:
-- Subject: Confirma tu correo electrónico
-- Body HTML:
/*
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Confirmación de Email</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .logo { width: 80px; height: 80px; background-color: #4CAF50; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; font-weight: bold; }
        h1 { color: #333; margin: 0; }
        .content { margin: 30px 0; }
        p { color: #666; line-height: 1.6; margin: 15px 0; }
        .button { display: inline-block; background-color: #4CAF50; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
        .button:hover { background-color: #45a049; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #999; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🏠</div>
            <h1>Sistema de Emergencias</h1>
        </div>
        
        <div class="content">
            <h2>¡Bienvenido!</h2>
            <p>Gracias por registrarte en nuestro Sistema de Emergencias. Para completar tu registro, necesitamos verificar tu dirección de correo electrónico.</p>
            
            <p>Haz clic en el botón de abajo para confirmar tu email:</p>
            
            <div style="text-align: center;">
                <a href="{{ .ConfirmationURL }}" class="button">Confirmar Email</a>
            </div>
            
            <p>Si el botón no funciona, puedes copiar y pegar este enlace en tu navegador:</p>
            <p style="word-break: break-all; background-color: #f9f9f9; padding: 10px; border-radius: 5px; font-family: monospace;">{{ .ConfirmationURL }}</p>
            
            <p><strong>Importante:</strong> Este enlace expirará en 24 horas por seguridad.</p>
        </div>
        
        <div class="footer">
            <p>Si no solicitaste este registro, puedes ignorar este correo.</p>
            <p>Sistema de Emergencias - Protegiendo a tu comunidad</p>
        </div>
    </div>
</body>
</html>
*/

-- 3. Configurar variables de entorno en Supabase
-- En Settings > API, asegúrate de tener:
-- - Site URL: https://tu-dominio.com (o http://localhost:3000 para desarrollo)
-- - Redirect URLs: https://tu-dominio.com/auth/callback

-- 4. Configurar SMTP (opcional pero recomendado)
-- En Authentication > Settings > SMTP Settings:
-- - Host: smtp.gmail.com (si usas Gmail)
-- - Port: 587
-- - Username: tu-email@gmail.com
-- - Password: tu-contraseña-de-aplicación
-- - Sender name: Sistema de Emergencias
-- - Sender email: tu-email@gmail.com

-- 5. Configurar políticas de seguridad (RLS)
-- Ejecutar estos comandos en el SQL Editor:

-- Habilitar RLS en las tablas principales
ALTER TABLE grupofamiliar ENABLE ROW LEVEL SECURITY;
ALTER TABLE residencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE mascota ENABLE ROW LEVEL SECURITY;

-- Política para grupofamiliar (solo el usuario puede ver sus propios datos)
CREATE POLICY "Users can view own grupo familiar" ON grupofamiliar
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert own grupo familiar" ON grupofamiliar
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can update own grupo familiar" ON grupofamiliar
    FOR UPDATE USING (auth.uid()::text = user_id);

-- Política para residencia
CREATE POLICY "Users can view own residencia" ON residencia
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.user_id = auth.uid()::text 
            AND grupofamiliar.id_grupof = residencia.id_residencia
        )
    );

CREATE POLICY "Users can insert own residencia" ON residencia
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.user_id = auth.uid()::text 
            AND grupofamiliar.id_grupof = residencia.id_residencia
        )
    );

-- 6. Configurar triggers para auditoría (opcional)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger a las tablas principales
CREATE TRIGGER update_grupofamiliar_updated_at BEFORE UPDATE ON grupofamiliar
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_residencia_updated_at BEFORE UPDATE ON residencia
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Configurar índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_grupofamiliar_user_id ON grupofamiliar(user_id);
CREATE INDEX IF NOT EXISTS idx_grupofamiliar_email ON grupofamiliar(email);
CREATE INDEX IF NOT EXISTS idx_residencia_id_residencia ON residencia(id_residencia);
CREATE INDEX IF NOT EXISTS idx_integrante_id_grupof ON integrante(id_grupof);
CREATE INDEX IF NOT EXISTS idx_mascota_id_grupof ON mascota(id_grupof);

-- 8. Configurar funciones de utilidad
CREATE OR REPLACE FUNCTION get_user_grupo_familiar(user_uuid UUID)
RETURNS TABLE (
    id_grupof INTEGER,
    email TEXT,
    nomb_titular TEXT,
    ape_p_titular TEXT,
    telefono_titular TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        gf.id_grupof,
        gf.email,
        gf.nomb_titular,
        gf.ape_p_titular,
        gf.telefono_titular,
        gf.created_at,
        gf.updated_at
    FROM grupofamiliar gf
    WHERE gf.user_id = user_uuid::text;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INSTRUCCIONES DE IMPLEMENTACIÓN
-- =====================================================

/*
PASOS PARA CONFIGURAR SUPABASE:

1. Ve a tu dashboard de Supabase: https://supabase.com/dashboard

2. Selecciona tu proyecto

3. Ve a Authentication > Settings:
   - Activa "Enable email confirmations"
   - Configura "Site URL" y "Redirect URLs"

4. Ve a Authentication > Email Templates:
   - Copia y pega la plantilla HTML de arriba
   - Personaliza el contenido si es necesario

5. Ve a Authentication > Settings > SMTP Settings (opcional):
   - Configura tu proveedor de email preferido
   - Gmail, SendGrid, Mailgun, etc.

6. Ve a SQL Editor:
   - Ejecuta los comandos SQL de arriba
   - Esto configurará las políticas de seguridad y índices

7. Ve a Settings > API:
   - Copia tu "Project URL" y "anon public" key
   - Actualiza tu archivo .env con estos valores

8. Prueba el flujo completo:
   - Registro de usuario
   - Verificación de email
   - Login
   - Acceso a la aplicación

NOTAS IMPORTANTES:
- Las políticas RLS son críticas para la seguridad
- Los índices mejoran el rendimiento
- Las plantillas de email son personalizables
- El SMTP es opcional pero recomendado para producción
*/
