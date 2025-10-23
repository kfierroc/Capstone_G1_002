-- =====================================================
-- SOLUCIÓN PARA INSTRUCCIONES ESPECIALES SIN NUEVOS CAMPOS
-- Usando campos existentes en la base de datos
-- =====================================================

-- OPCIÓN 1: Usar el campo JSONB existente en residencia
-- El campo residencia.instrucciones_especiales ya existe como JSONB
-- Podemos almacenar las instrucciones como:
-- {
--   "general": "Ventanas blindadas, acceso por patio trasero",
--   "emergencia": "Contactar a Juan Pérez al +56912345678",
--   "mascotas": "Perro agresivo en patio trasero"
-- }

-- OPCIÓN 2: Usar el campo VARCHAR existente en registro_v
-- El campo registro_v.instrucciones_especiales ya existe como VARCHAR(1000)
-- Podemos almacenar las instrucciones como JSON string:
-- '{"general": "Ventanas blindadas, acceso por patio trasero"}'

-- OPCIÓN 3: Usar el campo JSONB de residencia con estructura más compleja
-- {
--   "instrucciones": {
--     "general": "Ventanas blindadas",
--     "emergencia": "Contactar a Juan Pérez",
--     "mascotas": "Perro agresivo"
--   },
--   "metadata": {
--     "ultima_actualizacion": "2025-01-27T10:30:00Z",
--     "usuario": "bombero@email.com"
--   }
-- }

-- RECOMENDACIÓN: Usar OPCIÓN 1 (JSONB en residencia)
-- Ventajas:
-- 1. No requiere cambios en el esquema
-- 2. Flexibilidad para agregar diferentes tipos de instrucciones
-- 3. Fácil consulta y actualización
-- 4. Compatible con el código existente

-- Ejemplo de uso:
-- INSERT INTO residencia (id_residencia, direccion, lat, lon, cut_com, instrucciones_especiales)
-- VALUES (1, 'Irrarazabal 91', -33.4489, -70.6693, 13101, 
--         '{"general": "Ventanas blindadas, acceso por patio trasero"}'::jsonb);

-- UPDATE residencia 
-- SET instrucciones_especiales = '{"general": "Nueva instrucción", "emergencia": "Contacto de emergencia"}'::jsonb
-- WHERE id_residencia = 1;

-- SELECT instrucciones_especiales->>'general' as instruccion_general
-- FROM residencia 
-- WHERE id_residencia = 1;
