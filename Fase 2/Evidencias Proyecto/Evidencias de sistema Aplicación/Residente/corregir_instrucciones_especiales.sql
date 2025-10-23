-- Script para corregir la columna instrucciones_especiales
-- Ejecutar en Supabase SQL Editor

-- 1. Verificar si la columna existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'registro_v' 
        AND column_name = 'instrucciones_especiales'
    ) THEN
        -- Agregar la columna si no existe
        ALTER TABLE registro_v 
        ADD COLUMN instrucciones_especiales VARCHAR(1000);
        
        RAISE NOTICE 'Columna instrucciones_especiales agregada exitosamente';
    ELSE
        RAISE NOTICE 'Columna instrucciones_especiales ya existe';
    END IF;
END $$;

-- 2. Verificar la estructura actual
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
ORDER BY ordinal_position;

-- 3. Verificar datos existentes
SELECT 
    id_grupof,
    material,
    tipo,
    estado,
    pisos,
    instrucciones_especiales,
    fecha_ini_r
FROM registro_v 
WHERE id_grupof = 142587000
LIMIT 5;
