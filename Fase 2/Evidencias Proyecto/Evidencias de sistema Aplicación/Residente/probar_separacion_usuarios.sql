-- =====================================================
-- SCRIPT DE PRUEBA PARA SEPARACIÓN DE USUARIOS
-- Verificar que bomberos y residentes están separados
-- =====================================================

-- 1. Verificar estructura de las tablas
SELECT 'BOMBERO' as tabla, COUNT(*) as total FROM bombero
UNION ALL
SELECT 'GRUPOFAMILIAR' as tabla, COUNT(*) as total FROM grupofamiliar;

-- 2. Verificar emails duplicados entre bomberos y residentes
SELECT 
    b.email_b as email_bombero,
    g.email as email_residente,
    'CONFLICTO' as estado
FROM bombero b
INNER JOIN grupofamiliar g ON b.email_b = g.email
LIMIT 10;

-- 3. Verificar si hay usuarios registrados en ambas tablas
SELECT 
    COALESCE(b.email_b, g.email) as email,
    CASE 
        WHEN b.email_b IS NOT NULL AND g.email IS NOT NULL THEN 'AMBOS'
        WHEN b.email_b IS NOT NULL THEN 'SOLO_BOMBERO'
        WHEN g.email IS NOT NULL THEN 'SOLO_RESIDENTE'
    END as tipo_usuario
FROM bombero b
FULL OUTER JOIN grupofamiliar g ON b.email_b = g.email
ORDER BY tipo_usuario, email;

-- 4. Crear usuarios de prueba para verificar la separación
-- NOTA: Estos son solo para testing, no usar en producción

-- Usuario de prueba para bombero
INSERT INTO bombero (
    rut_num, rut_dv, compania, nomb_bombero, ape_p_bombero, 
    email_b, cut_com, fecha_ingreso
) VALUES (
    12345678, '9', 'Primera Compañía', 'Juan', 'Pérez',
    'bombero.test@example.com', 13101, '2025-01-27'
) ON CONFLICT (rut_num) DO NOTHING;

-- Usuario de prueba para residente
INSERT INTO grupofamiliar (
    id_grupof, rut_titular, nomb_titular, ape_p_titular, 
    telefono_titular, email, fecha_creacion
) VALUES (
    999999999, '98765432-1', 'María', 'González',
    '+56987654321', 'residente.test@example.com', '2025-01-27'
) ON CONFLICT (id_grupof) DO NOTHING;

-- 5. Verificar que los usuarios de prueba están separados
SELECT 'BOMBERO_TEST' as tipo, email_b as email FROM bombero WHERE email_b = 'bombero.test@example.com'
UNION ALL
SELECT 'RESIDENTE_TEST' as tipo, email as email FROM grupofamiliar WHERE email = 'residente.test@example.com';

-- 6. Limpiar usuarios de prueba (ejecutar después de las pruebas)
-- DELETE FROM bombero WHERE email_b = 'bombero.test@example.com';
-- DELETE FROM grupofamiliar WHERE email = 'residente.test@example.com';

-- =====================================================
-- RESULTADOS ESPERADOS:
-- =====================================================
-- 1. No debe haber emails duplicados entre bomberos y residentes
-- 2. Cada usuario debe aparecer solo en una tabla
-- 3. Los mensajes de error deben ser específicos para cada tipo
-- =====================================================
