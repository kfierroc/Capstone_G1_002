-- =====================================================
-- SCRIPT DE PRUEBA PARA INSTRUCCIONES ESPECIALES
-- Usando el campo JSONB existente en residencia
-- =====================================================

-- 1. Verificar que el campo instrucciones_especiales existe en residencia
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'residencia' 
AND column_name = 'instrucciones_especiales';

-- 2. Insertar una residencia con instrucciones especiales usando JSONB
INSERT INTO residencia (
  id_residencia, 
  direccion, 
  lat, 
  lon, 
  cut_com, 
  numero_pisos,
  instrucciones_especiales
) VALUES (
  999999999, -- ID único para prueba
  'Calle de Prueba 123',
  -33.448890,
  -70.669270,
  13101, -- Comuna válida
  2,
  '{"general": "Ventanas blindadas, acceso por patio trasero, perro agresivo"}'::jsonb
) ON CONFLICT (id_residencia) DO UPDATE SET
  instrucciones_especiales = EXCLUDED.instrucciones_especiales;

-- 3. Verificar que se guardó correctamente
SELECT 
  id_residencia,
  direccion,
  instrucciones_especiales,
  instrucciones_especiales->>'general' as instruccion_general
FROM residencia 
WHERE id_residencia = 999999999;

-- 4. Actualizar las instrucciones especiales
UPDATE residencia 
SET instrucciones_especiales = '{"general": "Nueva instrucción: Contactar a Juan Pérez al +56912345678"}'::jsonb
WHERE id_residencia = 999999999;

-- 5. Verificar la actualización
SELECT 
  id_residencia,
  direccion,
  instrucciones_especiales->>'general' as instruccion_general
FROM residencia 
WHERE id_residencia = 999999999;

-- 6. Limpiar las instrucciones especiales (establecer como null)
UPDATE residencia 
SET instrucciones_especiales = null
WHERE id_residencia = 999999999;

-- 7. Verificar que se limpiaron
SELECT 
  id_residencia,
  direccion,
  instrucciones_especiales
FROM residencia 
WHERE id_residencia = 999999999;

-- 8. Limpiar datos de prueba
DELETE FROM residencia WHERE id_residencia = 999999999;

-- =====================================================
-- VENTAJAS DE ESTA SOLUCIÓN:
-- =====================================================
-- ✅ No requiere agregar nuevos campos a la base de datos
-- ✅ Usa el campo JSONB existente en residencia
-- ✅ Flexibilidad para agregar diferentes tipos de instrucciones
-- ✅ Fácil consulta y actualización
-- ✅ Compatible con el código existente
-- ✅ Soporte nativo de PostgreSQL para JSONB
-- =====================================================
