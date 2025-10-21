-- Script SQL para extender el esquema de residencia
-- Agregar campos faltantes a la tabla residencia

-- =============================================
-- EXTENSIÓN DE TABLA RESIDENCIA
-- =============================================

-- Agregar campos de contacto y detalles de vivienda
ALTER TABLE residencia ADD COLUMN IF NOT EXISTS telefono_principal VARCHAR(20);
ALTER TABLE residencia ADD COLUMN IF NOT EXISTS numero_pisos INTEGER;
ALTER TABLE residencia ADD COLUMN IF NOT EXISTS instrucciones_especiales TEXT;

-- Agregar campos de auditoría
ALTER TABLE residencia ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE residencia ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear trigger para actualizar updated_at automáticamente
DROP TRIGGER IF EXISTS update_residencia_updated_at ON residencia;
CREATE TRIGGER update_residencia_updated_at
    BEFORE UPDATE ON residencia
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- VERIFICACIÓN DEL ESQUEMA ACTUALIZADO
-- =============================================

-- Verificar que las columnas se agregaron correctamente
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'residencia'
ORDER BY ordinal_position;

-- =============================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =============================================

COMMENT ON COLUMN residencia.telefono_principal IS 'Teléfono principal de contacto de la residencia';
COMMENT ON COLUMN residencia.numero_pisos IS 'Número de pisos de la vivienda';
COMMENT ON COLUMN residencia.instrucciones_especiales IS 'Instrucciones especiales para acceso o ubicación';
COMMENT ON COLUMN residencia.created_at IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN residencia.updated_at IS 'Fecha y hora de última actualización del registro';
