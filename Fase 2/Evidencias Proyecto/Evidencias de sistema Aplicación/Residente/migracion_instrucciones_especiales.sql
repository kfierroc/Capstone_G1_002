-- MIGRACIÓN: Agregar columna instrucciones_especiales a registro_v
-- Ejecutar este script en Supabase SQL Editor

-- 1. Agregar columna instrucciones_especiales como VARCHAR para JSON
ALTER TABLE registro_v 
ADD COLUMN IF NOT EXISTS instrucciones_especiales VARCHAR(1000);

-- 2. Verificar que la columna se agregó correctamente
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
AND column_name = 'instrucciones_especiales';

-- 3. Verificar la estructura completa de registro_v
\d registro_v;
