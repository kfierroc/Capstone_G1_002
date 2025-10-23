-- Script para verificar y agregar la columna instrucciones_especiales a registro_v
-- Ejecutar este script en Supabase SQL Editor

-- 1. Verificar si la columna existe
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
AND column_name = 'instrucciones_especiales';

-- 2. Si no existe, agregarla
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'registro_v' 
        AND column_name = 'instrucciones_especiales'
    ) THEN
        ALTER TABLE registro_v 
        ADD COLUMN instrucciones_especiales VARCHAR(1000);
        RAISE NOTICE 'Columna instrucciones_especiales agregada exitosamente a registro_v';
    ELSE
        RAISE NOTICE 'Columna instrucciones_especiales ya existe en registro_v';
    END IF;
END $$;

-- 3. Verificar la estructura final de la tabla
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
ORDER BY ordinal_position;
