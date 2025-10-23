-- Script para verificar si la migración se ejecutó correctamente
-- Ejecutar en Supabase SQL Editor

-- 1. Verificar si la columna instrucciones_especiales existe
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
AND column_name = 'instrucciones_especiales';

-- 2. Verificar la estructura completa de registro_v
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'registro_v' 
ORDER BY ordinal_position;

-- 3. Verificar si hay datos en registro_v
SELECT COUNT(*) as total_registros FROM registro_v;

-- 4. Verificar un registro específico (reemplazar con un id_grupof real)
SELECT id_grupof, material, tipo, estado, pisos, instrucciones_especiales
FROM registro_v 
WHERE id_grupof = 142587000
LIMIT 1;
