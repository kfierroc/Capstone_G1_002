-- Script para verificar y crear funciones de búsqueda necesarias para la app de Bomberos
-- Ejecutar este script en Supabase SQL Editor

-- 1. Verificar si la función search_residencias_nearby existe
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'search_residencias_nearby';

-- 2. Crear la función search_residencias_nearby si no existe
CREATE OR REPLACE FUNCTION search_residencias_nearby(
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE(
    id_residencia INTEGER,
    direccion TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    distance_km DOUBLE PRECISION,
    grupo_familiar JSONB,
    integrantes JSONB,
    mascotas JSONB,
    registro_v JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id_residencia,
        r.direccion,
        r.lat,
        r.lon,
        -- Calcular distancia aproximada en km usando fórmula de Haversine
        (6371 * acos(
            cos(radians(lat)) * 
            cos(radians(r.lat)) * 
            cos(radians(r.lon) - radians(lon)) + 
            sin(radians(lat)) * 
            sin(radians(r.lat))
        )) AS distance_km,
        -- Construir JSON del grupo familiar
        (
            SELECT jsonb_build_object(
                'id_grupof', gf.id_grupof,
                'rut_titular', gf.rut_titular,
                'nomb_titular', gf.nomb_titular,
                'ape_p_titular', gf.ape_p_titular,
                'telefono_titular', gf.telefono_titular,
                'email', gf.email,
                'fecha_creacion', gf.fecha_creacion
            )
            FROM grupofamiliar gf
            WHERE gf.id_grupof = rv.id_grupof
        ) AS grupo_familiar,
        -- Construir JSON de integrantes
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id_integrante', i.id_integrante,
                    'activo_i', i.activo_i,
                    'fecha_ini_i', i.fecha_ini_i,
                    'edad', CASE 
                        WHEN ii.anio_nac IS NOT NULL 
                        THEN EXTRACT(YEAR FROM CURRENT_DATE) - ii.anio_nac
                        ELSE NULL 
                    END,
                    'anio_nacimiento', ii.anio_nac,
                    'padecimientos', CASE 
                        WHEN ii.padecimiento IS NOT NULL 
                        THEN string_to_array(ii.padecimiento, ',')
                        ELSE ARRAY[]::TEXT[]
                    END
                )
            )
            FROM integrante i
            LEFT JOIN info_integrante ii ON i.id_integrante = ii.id_integrante
            WHERE i.id_grupof = rv.id_grupof AND i.activo_i = true
        ) AS integrantes,
        -- Construir JSON de mascotas
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id_mascota', m.id_mascota,
                    'nombre_m', m.nombre_m,
                    'especie', m.especie,
                    'tamanio', m.tamanio,
                    'fecha_reg_m', m.fecha_reg_m
                )
            )
            FROM mascota m
            WHERE m.id_grupof = rv.id_grupof
        ) AS mascotas,
        -- Construir JSON del registro_v
        jsonb_build_object(
            'material', rv.material,
            'tipo', rv.tipo,
            'estado', rv.estado,
            'pisos', rv.pisos,
            'instrucciones_especiales', rv.instrucciones_especiales,
            'fecha_ini_r', rv.fecha_ini_r
        ) AS registro_v
    FROM residencia r
    INNER JOIN registro_v rv ON r.id_residencia = rv.id_residencia
    WHERE rv.vigente = true
    AND (
        6371 * acos(
            cos(radians(lat)) * 
            cos(radians(r.lat)) * 
            cos(radians(r.lon) - radians(lon)) + 
            sin(radians(lat)) * 
            sin(radians(r.lat))
        )
    ) <= radius_km
    ORDER BY distance_km;
END;
$$;

-- 3. Verificar que la función se creó correctamente
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'search_residencias_nearby';

-- 4. Probar la función con coordenadas de ejemplo (Santiago, Chile)
-- SELECT * FROM search_residencias_nearby(-33.4489, -70.6693, 10.0);
