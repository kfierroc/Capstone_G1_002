-- Script completo de migración para agregar instrucciones_especiales a registro_v
-- Ejecutar este script en la base de datos de Supabase

-- 1. Agregar la columna instrucciones_especiales si no existe
ALTER TABLE registro_v 
ADD COLUMN IF NOT EXISTS instrucciones_especiales VARCHAR(1000);

-- 2. Verificar que la columna se agregó correctamente
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
AND column_name = 'instrucciones_especiales';

-- 3. Verificar la estructura completa de la tabla registro_v
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'registro_v'
ORDER BY ordinal_position;

-- 4. Verificar que hay datos en registro_v
SELECT COUNT(*) as total_registros, 
       COUNT(instrucciones_especiales) as con_instrucciones
FROM registro_v 
WHERE vigente = true;
