-- Script para agregar la columna instrucciones_especiales a registro_v
-- Ejecutar este script en la base de datos de Supabase

ALTER TABLE registro_v 
ADD COLUMN IF NOT EXISTS instrucciones_especiales VARCHAR(1000);

-- Verificar que la columna se agregó correctamente
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
AND column_name = 'instrucciones_especiales';
