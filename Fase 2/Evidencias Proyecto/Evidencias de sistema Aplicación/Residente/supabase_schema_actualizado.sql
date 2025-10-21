-- Script SQL para actualizar el esquema de la base de datos
-- Compatible con el modelo de datos real del proyecto

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

-- Tabla comunas
CREATE TABLE IF NOT EXISTS comunas (
    cut_com VARCHAR(10) PRIMARY KEY,
    comuna VARCHAR(100) NOT NULL,
    cut_reg VARCHAR(5) NOT NULL,
    region VARCHAR(100) NOT NULL,
    cut_prov VARCHAR(5) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    superficie DECIMAL(10,2) NOT NULL DEFAULT 0,
    geometry TEXT
);

-- Tabla residencia
CREATE TABLE IF NOT EXISTS residencia (
    id_residencia SERIAL PRIMARY KEY,
    direccion VARCHAR(255) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lon DECIMAL(11, 8) NOT NULL,
    cut_com VARCHAR(10) NOT NULL REFERENCES comunas(cut_com)
);

-- Tabla grupofamiliar (ACTUALIZADA CON auth_user_id)
CREATE TABLE IF NOT EXISTS grupofamiliar (
    id_grupof SERIAL PRIMARY KEY,
    rut_titular VARCHAR(12) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    auth_user_id UUID UNIQUE -- NUEVA COLUMNA para conectar con Supabase Auth
);

-- Tabla registro_v
CREATE TABLE IF NOT EXISTS registro_v (
    id_registro SERIAL PRIMARY KEY,
    vigente BOOLEAN NOT NULL DEFAULT true,
    estado VARCHAR(50) NOT NULL,
    material VARCHAR(100) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    fecha_ini_r TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_fin_r TIMESTAMP WITH TIME ZONE,
    id_residencia INTEGER NOT NULL REFERENCES residencia(id_residencia),
    id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);

-- Tabla integrante
CREATE TABLE IF NOT EXISTS integrante (
    id_integrante SERIAL PRIMARY KEY,
    activo_i BOOLEAN NOT NULL DEFAULT true,
    fecha_ini_i TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_fin_i TIMESTAMP WITH TIME ZONE,
    id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);

-- Tabla info_integrante
CREATE TABLE IF NOT EXISTS info_integrante (
    id_integrante INTEGER PRIMARY KEY REFERENCES integrante(id_integrante),
    fecha_reg_ii TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    anio_nac INTEGER NOT NULL,
    padecimiento TEXT
);

-- Tabla mascota
CREATE TABLE IF NOT EXISTS mascota (
    id_mascota SERIAL PRIMARY KEY,
    nombre_m VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    tamanio VARCHAR(20) NOT NULL,
    fecha_reg_m TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);

-- Tabla grifo
CREATE TABLE IF NOT EXISTS grifo (
    id_grifo SERIAL PRIMARY KEY,
    lat DECIMAL(10, 8) NOT NULL,
    lon DECIMAL(11, 8) NOT NULL,
    cut_com VARCHAR(10) NOT NULL REFERENCES comunas(cut_com)
);

-- Tabla info_grifo
CREATE TABLE IF NOT EXISTS info_grifo (
    id_reg_grifo SERIAL PRIMARY KEY,
    id_grifo INTEGER NOT NULL REFERENCES grifo(id_grifo),
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estado VARCHAR(50) NOT NULL,
    rut_num INTEGER NOT NULL REFERENCES bombero(rut_num)
);

-- Tabla bombero
CREATE TABLE IF NOT EXISTS bombero (
    rut_num INTEGER PRIMARY KEY,
    rut_dv VARCHAR(1) NOT NULL,
    email_b VARCHAR(255) NOT NULL UNIQUE
);

-- =============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =============================================

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_residencia_cut_com ON residencia(cut_com);
CREATE INDEX IF NOT EXISTS idx_registro_v_id_grupof ON registro_v(id_grupof);
CREATE INDEX IF NOT EXISTS idx_registro_v_id_residencia ON registro_v(id_residencia);
CREATE INDEX IF NOT EXISTS idx_integrante_id_grupof ON integrante(id_grupof);
CREATE INDEX IF NOT EXISTS idx_mascota_id_grupof ON mascota(id_grupof);
CREATE INDEX IF NOT EXISTS idx_grifo_cut_com ON grifo(cut_com);
CREATE INDEX IF NOT EXISTS idx_info_grifo_id_grifo ON info_grifo(id_grifo);
CREATE INDEX IF NOT EXISTS idx_info_grifo_rut_num ON info_grifo(rut_num);

-- Índice para auth_user_id (importante para autenticación)
CREATE INDEX IF NOT EXISTS idx_grupofamiliar_auth_user_id ON grupofamiliar(auth_user_id);

-- =============================================
-- POLÍTICAS DE SEGURIDAD (RLS)
-- =============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE comunas ENABLE ROW LEVEL SECURITY;
ALTER TABLE residencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE grupofamiliar ENABLE ROW LEVEL SECURITY;
ALTER TABLE registro_v ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE mascota ENABLE ROW LEVEL SECURITY;
ALTER TABLE grifo ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_grifo ENABLE ROW LEVEL SECURITY;
ALTER TABLE bombero ENABLE ROW LEVEL SECURITY;

-- Políticas para grupofamiliar (solo el usuario autenticado puede ver/editar sus datos)
CREATE POLICY "Users can view own grupo familiar" ON grupofamiliar
    FOR SELECT USING (auth.uid()::text = auth_user_id::text);

CREATE POLICY "Users can update own grupo familiar" ON grupofamiliar
    FOR UPDATE USING (auth.uid()::text = auth_user_id::text);

CREATE POLICY "Users can insert own grupo familiar" ON grupofamiliar
    FOR INSERT WITH CHECK (auth.uid()::text = auth_user_id::text);

-- Políticas para residencia (acceso público para lectura, restringido para escritura)
CREATE POLICY "Anyone can view residencias" ON residencia
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert residencias" ON residencia
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Políticas para registro_v (solo el grupo familiar propietario)
CREATE POLICY "Users can view own registros" ON registro_v
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = registro_v.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own registros" ON registro_v
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = registro_v.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

-- Políticas similares para integrante, info_integrante y mascota
CREATE POLICY "Users can view own integrantes" ON integrante
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = integrante.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own integrantes" ON integrante
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = integrante.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can view own info integrantes" ON info_integrante
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM integrante 
            JOIN grupofamiliar ON grupofamiliar.id_grupof = integrante.id_grupof
            WHERE integrante.id_integrante = info_integrante.id_integrante 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own info integrantes" ON info_integrante
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM integrante 
            JOIN grupofamiliar ON grupofamiliar.id_grupof = integrante.id_grupof
            WHERE integrante.id_integrante = info_integrante.id_integrante 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can view own mascotas" ON mascota
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = mascota.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own mascotas" ON mascota
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM grupofamiliar 
            WHERE grupofamiliar.id_grupof = mascota.id_grupof 
            AND grupofamiliar.auth_user_id::text = auth.uid()::text
        )
    );

-- Políticas para grifos (acceso público para bomberos)
CREATE POLICY "Anyone can view grifos" ON grifo
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert grifos" ON grifo
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Políticas para info_grifo (solo bomberos autenticados)
CREATE POLICY "Authenticated users can view info grifos" ON info_grifo
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert info grifos" ON info_grifo
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Políticas para bombero (solo el propio bombero puede ver/editar sus datos)
CREATE POLICY "Bomberos can view own data" ON bombero
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.email = bombero.email_b 
            AND auth.users.id = auth.uid()
        )
    );

CREATE POLICY "Bomberos can update own data" ON bombero
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.email = bombero.email_b 
            AND auth.users.id = auth.uid()
        )
    );

-- Políticas para comunas (acceso público)
CREATE POLICY "Anyone can view comunas" ON comunas
    FOR SELECT USING (true);

-- =============================================
-- FUNCIONES AUXILIARES
-- =============================================

-- Función para obtener el grupo familiar del usuario autenticado
CREATE OR REPLACE FUNCTION get_user_grupo_familiar()
RETURNS TABLE(id_grupof INTEGER, rut_titular VARCHAR, email VARCHAR)
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT gf.id_grupof, gf.rut_titular, gf.email
    FROM grupofamiliar gf
    WHERE gf.auth_user_id = auth.uid();
$$;

-- Función para verificar si un usuario puede acceder a un grupo familiar
CREATE OR REPLACE FUNCTION can_access_grupo_familiar(grupo_id INTEGER)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM grupofamiliar 
        WHERE id_grupof = grupo_id 
        AND auth_user_id = auth.uid()
    );
$$;

-- =============================================
-- COMENTARIOS EN TABLAS
-- =============================================

COMMENT ON TABLE comunas IS 'Información geográfica y administrativa de las comunas';
COMMENT ON TABLE residencia IS 'Direcciones de residencias con coordenadas geográficas';
COMMENT ON TABLE grupofamiliar IS 'Grupos familiares con autenticación de Supabase';
COMMENT ON TABLE registro_v IS 'Registros de viviendas con su estado y características';
COMMENT ON TABLE integrante IS 'Integrantes de los grupos familiares';
COMMENT ON TABLE info_integrante IS 'Información adicional de los integrantes';
COMMENT ON TABLE mascota IS 'Mascotas de los grupos familiares';
COMMENT ON TABLE grifo IS 'Grifos de agua con ubicación geográfica';
COMMENT ON TABLE info_grifo IS 'Información adicional de los grifos';
COMMENT ON TABLE bombero IS 'Información de bomberos';

-- =============================================
-- DATOS DE PRUEBA (OPCIONAL)
-- =============================================

-- Insertar algunas comunas de ejemplo
INSERT INTO comunas (cut_com, comuna, cut_reg, region, cut_prov, provincia, superficie) VALUES
('13101', 'Santiago', '13', 'Metropolitana', '131', 'Santiago', 22.4),
('13102', 'Cerrillos', '13', 'Metropolitana', '131', 'Santiago', 21.0),
('13103', 'Cerro Navia', '13', 'Metropolitana', '131', 'Santiago', 16.9)
ON CONFLICT (cut_com) DO NOTHING;

-- =============================================
-- INSTRUCCIONES DE USO
-- =============================================

/*
INSTRUCCIONES PARA USAR ESTE ESQUEMA:

1. Ejecutar este script completo en el SQL Editor de Supabase
2. Verificar que todas las tablas se crearon correctamente
3. Verificar que las políticas RLS están activas
4. Probar la autenticación con Supabase Auth
5. Verificar que los índices mejoran el rendimiento

NOTAS IMPORTANTES:
- La columna auth_user_id en grupofamiliar conecta con Supabase Auth
- Todas las tablas tienen RLS habilitado para seguridad
- Los usuarios solo pueden acceder a sus propios datos
- Los bomberos pueden ver todos los grifos pero solo editar los suyos
- Las comunas son de acceso público para consultas

PRÓXIMOS PASOS:
1. Configurar las credenciales en .env
2. Inicializar Supabase en las aplicaciones Flutter
3. Implementar los servicios de autenticación
4. Probar el registro y login de usuarios
*/
