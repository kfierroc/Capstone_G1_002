-- Script para probar el guardado de datos
-- Ejecutar en Supabase SQL Editor

-- 1. Verificar datos actuales del grupo 142587000
SELECT 
    'grupofamiliar' as tabla,
    id_grupof,
    rut_titular,
    telefono_titular,
    email
FROM grupofamiliar 
WHERE id_grupof = 142587000

UNION ALL

SELECT 
    'registro_v' as tabla,
    id_grupof::text,
    material,
    tipo,
    instrucciones_especiales
FROM registro_v 
WHERE id_grupof = 142587000;

-- 2. Actualizar manualmente para probar
UPDATE grupofamiliar 
SET telefono_titular = '+56932425644'
WHERE id_grupof = 142587000;

UPDATE registro_v 
SET instrucciones_especiales = '{"general": "Ventanas blindadas, Puerta de seguridad"}'
WHERE id_grupof = 142587000;

-- 3. Verificar los cambios
SELECT 
    'DESPUÉS DE ACTUALIZAR' as estado,
    g.telefono_titular,
    r.instrucciones_especiales
FROM grupofamiliar g
LEFT JOIN registro_v r ON g.id_grupof = r.id_grupof
WHERE g.id_grupof = 142587000;
