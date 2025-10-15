-- =====================================================
-- ESQUEMA DE BASE DE DATOS ACTUALIZADO PARA SISTEMA DE BOMBEROS
-- Basado en el modelo de datos del usuario
-- =====================================================
-- Ejecutar este script en el SQL Editor de Supabase

-- =====================================================
-- 1. TABLA DE COMUNAS (Referencia geográfica)
-- =====================================================
CREATE TABLE IF NOT EXISTS comunas (
  cut_com INTEGER PRIMARY KEY NOT NULL,
  comuna TEXT NOT NULL,
  cut_reg INTEGER NOT NULL,
  region TEXT NOT NULL,
  cut_prov INTEGER NOT NULL,
  provincia TEXT NOT NULL,
  superficie NUMERIC NOT NULL,
  geometry GEOMETRY NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TABLA DE GRUPOS FAMILIARES (Residentes principales)
-- =====================================================
CREATE TABLE IF NOT EXISTS grupofamiliar (
  id_grupof UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  
  -- Datos del titular
  rut_titular VARCHAR NOT NULL UNIQUE,
  email VARCHAR NOT NULL UNIQUE,
  password VARCHAR NOT NULL,
  fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,
  
  -- Metadatos
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_rut_titular CHECK (LENGTH(rut_titular) >= 8),
  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_grupofamiliar_user_id ON grupofamiliar(user_id);
CREATE INDEX idx_grupofamiliar_rut_titular ON grupofamiliar(rut_titular);

-- =====================================================
-- 3. TABLA DE RESIDENCIAS
-- =====================================================
CREATE TABLE IF NOT EXISTS residencia (
  id_residencia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_grupof UUID REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE NOT NULL,
  
  -- Información de ubicación
  direccion TEXT NOT NULL,
  lat NUMERIC NOT NULL,
  lon NUMERIC NOT NULL,
  cut_com INTEGER REFERENCES comunas(cut_com) NOT NULL,
  
  -- Detalles de vivienda
  tipo_vivienda TEXT, -- Casa, Departamento, etc.
  numero_pisos INTEGER,
  material_construccion TEXT,
  estado_vivienda TEXT,
  telefono_principal TEXT,
  telefono_alternativo TEXT,
  instrucciones_especiales TEXT,
  
  -- Metadatos
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_coordinates CHECK (lat >= -90 AND lat <= 90 AND lon >= -180 AND lon <= 180)
);

-- Índices
CREATE INDEX idx_residencia_grupof ON residencia(id_grupof);
CREATE INDEX idx_residencia_location ON residencia(lat, lon);
CREATE INDEX idx_residencia_comuna ON residencia(cut_com);

-- =====================================================
-- 4. TABLA DE INTEGRANTES DEL GRUPO FAMILIAR
-- =====================================================
CREATE TABLE IF NOT EXISTS integrante (
  id_integrante UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_grupof UUID REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE NOT NULL,
  
  -- Estado del integrante
  activo_i BOOLEAN NOT NULL DEFAULT true,
  fecha_ini_i DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin_i DATE,
  
  -- Información personal
  rut VARCHAR NOT NULL,
  edad INTEGER NOT NULL,
  anio_nac INTEGER NOT NULL,
  padecimiento TEXT,
  
  -- Metadatos
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_age CHECK (edad >= 18 AND edad <= 150),
  CONSTRAINT valid_birth_year CHECK (anio_nac >= 1900 AND anio_nac <= EXTRACT(YEAR FROM CURRENT_DATE)),
  CONSTRAINT valid_adult_age CHECK (EXTRACT(YEAR FROM CURRENT_DATE) - anio_nac >= 18),
  CONSTRAINT valid_dates CHECK (fecha_fin_i IS NULL OR fecha_fin_i >= fecha_ini_i)
);

-- Índices
CREATE INDEX idx_integrante_grupof ON integrante(id_grupof);
CREATE INDEX idx_integrante_rut ON integrante(rut);
CREATE INDEX idx_integrante_active ON integrante(activo_i);

-- =====================================================
-- 5. TABLA DE MASCOTAS
-- =====================================================
CREATE TABLE IF NOT EXISTS mascota (
  id_mascota UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_grupof UUID REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE NOT NULL,
  
  -- Información de la mascota
  nombre_m TEXT NOT NULL,
  especie TEXT NOT NULL,
  tamanio TEXT NOT NULL,
  fecha_reg_m DATE NOT NULL DEFAULT CURRENT_DATE,
  
  -- Metadatos
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_species CHECK (especie IN ('Perro', 'Gato', 'Otro')),
  CONSTRAINT valid_size CHECK (tamanio IN ('Pequeño', 'Mediano', 'Grande'))
);

-- Índices
CREATE INDEX idx_mascota_grupof ON mascota(id_grupof);

-- =====================================================
-- 6. TABLA DE BOMBEROS (Para futuras funcionalidades)
-- =====================================================
CREATE TABLE IF NOT EXISTS bombero (
  rut_num INTEGER PRIMARY KEY NOT NULL,
  rut_dv BPCHAR NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  email_b TEXT UNIQUE,
  
  -- Información adicional del bombero
  nombre TEXT,
  telefono TEXT,
  cargo TEXT,
  activo BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_bombero_user_id ON bombero(user_id);
CREATE INDEX idx_bombero_email ON bombero(email_b);

-- =====================================================
-- 7. TABLA DE GRIFOS (Para futuras funcionalidades)
-- =====================================================
CREATE TABLE IF NOT EXISTS grifo (
  id_grifo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lat NUMERIC NOT NULL,
  lon NUMERIC NOT NULL,
  cut_com INTEGER REFERENCES comunas(cut_com) NOT NULL,
  
  -- Información del grifo
  direccion TEXT,
  tipo_grifo TEXT,
  capacidad NUMERIC,
  estado_operativo BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_grifo_coordinates CHECK (lat >= -90 AND lat <= 90 AND lon >= -180 AND lon <= 180)
);

-- Índices
CREATE INDEX idx_grifo_location ON grifo(lat, lon);
CREATE INDEX idx_grifo_comuna ON grifo(cut_com);

-- =====================================================
-- 8. TABLA DE INFORMACIÓN DE GRIFOS
-- =====================================================
CREATE TABLE IF NOT EXISTS info_grifo (
  id_reg_grifo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_grifo UUID REFERENCES grifo(id_grifo) ON DELETE CASCADE NOT NULL,
  rut_num INTEGER REFERENCES bombero(rut_num),
  
  fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
  estado TEXT NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_info_grifo_grifo ON info_grifo(id_grifo);
CREATE INDEX idx_info_grifo_bombero ON info_grifo(rut_num);
CREATE INDEX idx_info_grifo_fecha ON info_grifo(fecha_registro);

-- =====================================================
-- 9. TABLA DE REGISTROS DE INCIDENTES
-- =====================================================
CREATE TABLE IF NOT EXISTS registro_v (
  id_registro UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_residencia UUID REFERENCES residencia(id_residencia) NOT NULL,
  id_grupof UUID REFERENCES grupofamiliar(id_grupof) NOT NULL,
  rut_num INTEGER REFERENCES bombero(rut_num),
  
  -- Estado del registro
  vigente BOOLEAN NOT NULL DEFAULT true,
  estado TEXT NOT NULL,
  material TEXT,
  tipo TEXT,
  
  -- Fechas
  fecha_ini_r DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_fin_r DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT valid_incident_dates CHECK (fecha_fin_r IS NULL OR fecha_fin_r >= fecha_ini_r)
);

-- Índices
CREATE INDEX idx_registro_residencia ON registro_v(id_residencia);
CREATE INDEX idx_registro_grupof ON registro_v(id_grupof);
CREATE INDEX idx_registro_bombero ON registro_v(rut_num);
CREATE INDEX idx_registro_vigente ON registro_v(vigente);

-- =====================================================
-- 10. FUNCIÓN PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar updated_at
CREATE TRIGGER update_comunas_updated_at
  BEFORE UPDATE ON comunas
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grupofamiliar_updated_at
  BEFORE UPDATE ON grupofamiliar
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_residencia_updated_at
  BEFORE UPDATE ON residencia
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_integrante_updated_at
  BEFORE UPDATE ON integrante
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mascota_updated_at
  BEFORE UPDATE ON mascota
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bombero_updated_at
  BEFORE UPDATE ON bombero
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grifo_updated_at
  BEFORE UPDATE ON grifo
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_info_grifo_updated_at
  BEFORE UPDATE ON info_grifo
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registro_v_updated_at
  BEFORE UPDATE ON registro_v
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 11. ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE comunas ENABLE ROW LEVEL SECURITY;
ALTER TABLE grupofamiliar ENABLE ROW LEVEL SECURITY;
ALTER TABLE residencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE mascota ENABLE ROW LEVEL SECURITY;
ALTER TABLE bombero ENABLE ROW LEVEL SECURITY;
ALTER TABLE grifo ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_grifo ENABLE ROW LEVEL SECURITY;
ALTER TABLE registro_v ENABLE ROW LEVEL SECURITY;

-- Políticas para COMUNAS (lectura pública)
CREATE POLICY "Todos pueden leer comunas"
  ON comunas FOR SELECT
  USING (true);

-- Políticas para GRUPOFAMILIAR
CREATE POLICY "Los usuarios pueden ver su propio grupo familiar"
  ON grupofamiliar FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear su propio grupo familiar"
  ON grupofamiliar FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden actualizar su propio grupo familiar"
  ON grupofamiliar FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden eliminar su propio grupo familiar"
  ON grupofamiliar FOR DELETE
  USING (auth.uid() = user_id);

-- Políticas para RESIDENCIA
CREATE POLICY "Los usuarios pueden ver sus residencias"
  ON residencia FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = residencia.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden crear residencias"
  ON residencia FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = residencia.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden actualizar sus residencias"
  ON residencia FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = residencia.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden eliminar sus residencias"
  ON residencia FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = residencia.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

-- Políticas para INTEGRANTE
CREATE POLICY "Los usuarios pueden ver sus integrantes"
  ON integrante FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = integrante.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden crear integrantes"
  ON integrante FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = integrante.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden actualizar sus integrantes"
  ON integrante FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = integrante.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden eliminar sus integrantes"
  ON integrante FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = integrante.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

-- Políticas para MASCOTA
CREATE POLICY "Los usuarios pueden ver sus mascotas"
  ON mascota FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = mascota.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden crear mascotas"
  ON mascota FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = mascota.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden actualizar sus mascotas"
  ON mascota FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = mascota.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

CREATE POLICY "Los usuarios pueden eliminar sus mascotas"
  ON mascota FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = mascota.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

-- Políticas para BOMBERO (solo bomberos autenticados)
CREATE POLICY "Los bomberos pueden ver bomberos"
  ON bombero FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bombero b 
      WHERE b.user_id = auth.uid()
    )
  );

-- Políticas para GRIFO (lectura pública para bomberos)
CREATE POLICY "Todos pueden leer grifos"
  ON grifo FOR SELECT
  USING (true);

-- Políticas para INFO_GRIFO (solo bomberos)
CREATE POLICY "Los bomberos pueden ver info de grifos"
  ON info_grifo FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bombero b 
      WHERE b.user_id = auth.uid()
    )
  );

-- Políticas para REGISTRO_V
CREATE POLICY "Los usuarios pueden ver sus registros"
  ON registro_v FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM grupofamiliar 
      WHERE grupofamiliar.id_grupof = registro_v.id_grupof 
      AND grupofamiliar.user_id = auth.uid()
    )
  );

-- =====================================================
-- 12. VISTAS ÚTILES
-- =====================================================

-- Vista combinada de grupo familiar con información completa
CREATE OR REPLACE VIEW grupofamiliar_completo AS
SELECT 
  gf.*,
  r.id_residencia,
  r.direccion,
  r.lat,
  r.lon,
  c.comuna,
  c.region,
  c.provincia,
  (SELECT COUNT(*) FROM integrante i WHERE i.id_grupof = gf.id_grupof AND i.activo_i = true) AS integrantes_activos,
  (SELECT COUNT(*) FROM mascota m WHERE m.id_grupof = gf.id_grupof) AS mascotas_count
FROM grupofamiliar gf
LEFT JOIN residencia r ON r.id_grupof = gf.id_grupof
LEFT JOIN comunas c ON c.cut_com = r.cut_com;

-- Vista de integrantes con información del grupo familiar
CREATE OR REPLACE VIEW integrante_completo AS
SELECT 
  i.*,
  gf.rut_titular,
  gf.fecha_creacion as fecha_creacion_grupo
FROM integrante i
JOIN grupofamiliar gf ON gf.id_grupof = i.id_grupof;

-- =====================================================
-- 13. FUNCIÓN PARA CREAR GRUPO FAMILIAR COMPLETO
-- =====================================================
CREATE OR REPLACE FUNCTION crear_grupo_familiar_completo(
  p_user_id UUID,
  p_rut_titular VARCHAR,
  p_direccion TEXT,
  p_lat NUMERIC,
  p_lon NUMERIC,
  p_cut_com INTEGER,
  p_tipo_vivienda TEXT DEFAULT NULL,
  p_telefono_principal TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_id_grupof UUID;
BEGIN
  -- Crear grupo familiar
  INSERT INTO grupofamiliar (user_id, rut_titular)
  VALUES (p_user_id, p_rut_titular)
  RETURNING id_grupof INTO v_id_grupof;
  
  -- Crear residencia
  INSERT INTO residencia (
    id_grupof, direccion, lat, lon, cut_com, 
    tipo_vivienda, telefono_principal
  )
  VALUES (
    v_id_grupof, p_direccion, p_lat, p_lon, p_cut_com,
    p_tipo_vivienda, p_telefono_principal
  );
  
  RETURN v_id_grupof;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- FIN DEL ESQUEMA ACTUALIZADO
-- =====================================================

-- Verificar que todo se creó correctamente
SELECT 'Esquema actualizado creado exitosamente' AS status;
