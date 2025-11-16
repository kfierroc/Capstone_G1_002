-- =====================================================
-- ESQUEMA DE BASE DE DATOS PARA SISTEMA DE BOMBEROS
-- Compatible con Supabase Auth y aplicaciones Flutter
-- =====================================================

-- Tabla comunas (usando cut_com como ID estándar)
CREATE TABLE comunas (
  cut_com INTEGER PRIMARY KEY NOT NULL,
  comuna TEXT NOT NULL,
  out_reg INTEGER NOT NULL,
  region TEXT NOT NULL,
  out_prov INTEGER NOT NULL,
  provincia TEXT NOT NULL,
  superficie NUMERIC NOT NULL,
  geometry GEOMETRY NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla residencia (con campos adicionales requeridos por las apps)
CREATE TABLE residencia (
  id_residencia INTEGER PRIMARY KEY NOT NULL,
  direccion TEXT UNIQUE NOT NULL,
  lat DECIMAL(9,6) NOT NULL,
  lon DECIMAL(9,6) NOT NULL,
  cut_com INTEGER NOT NULL REFERENCES comunas(cut_com),
  
  -- Campos adicionales requeridos por las aplicaciones
  telefono_principal VARCHAR(20),
  numero_pisos INTEGER,
  instrucciones_especiales JSONB,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla grupofamiliar (solo con id estándar)
CREATE TABLE grupofamiliar(
  id_grupof INTEGER PRIMARY KEY NOT NULL,
  rut_titular VARCHAR(12) NOT NULL,
  telefono_titular VARCHAR(13) NOT NULL,
  CHECK (telefono_titular ~ '^\+56[2-9][0-9]{8,9}$'),
  email TEXT UNIQUE NOT NULL,
  fecha_creacion DATE NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla registro_v (correcta)
CREATE TABLE registro_v (
  id_registro INTEGER PRIMARY KEY NOT NULL,
  vigente BOOLEAN NOT NULL,
  estado TEXT NOT NULL,
  material TEXT NOT NULL,
  tipo TEXT NOT NULL,
  pisos INTEGER NOT NULL,
  fecha_ini_r DATE NOT NULL,
  fecha_fin_r DATE,
  id_residencia INTEGER NOT NULL REFERENCES residencia(id_residencia),
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof),
  instrucciones_especiales VARCHAR(1000), -- Campo agregado para instrucciones especiales
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla integrante (correcta)
CREATE TABLE integrante(
  id_integrante INTEGER PRIMARY KEY NOT NULL,
  activo_i BOOLEAN NOT NULL,
  fecha_ini_i DATE NOT NULL,
  fecha_fin_i DATE,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla info_integrante (correcta)
CREATE TABLE info_integrante(
  id_integrante INTEGER PRIMARY KEY NOT NULL REFERENCES integrante(id_integrante),
  fecha_reg_ii DATE NOT NULL,
  anio_nac INTEGER NOT NULL,
  padecimiento TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla mascota (correcta)
CREATE TABLE mascota(
  id_mascota INTEGER PRIMARY KEY,
  nombre_m TEXT NOT NULL,
  especie TEXT NOT NULL,
  tamanio TEXT NOT NULL,
  fecha_reg_m DATE NOT NULL,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla grifo (usando cut_com como estándar)
CREATE TABLE grifo (
  id_grifo SERIAL PRIMARY KEY,
  lat DECIMAL(9,6) NOT NULL,
  lon DECIMAL(9,6) NOT NULL,
  cut_com INTEGER NOT NULL REFERENCES comunas(cut_com),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla bombero (solo con id estándar, sin auth_user_id)
CREATE TABLE bombero (
  rut_num INTEGER PRIMARY KEY NOT NULL,
  rut_dv CHAR(1) NOT NULL,
  compania VARCHAR(4) NOT NULL,
  nomb_bombero VARCHAR(50) NOT NULL,
  ape_p_bombero VARCHAR(50) NOT NULL,
  email_b TEXT UNIQUE NOT NULL,
  cut_com INTEGER NOT NULL REFERENCES comunas(cut_com),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT uq_rut UNIQUE (rut_num, rut_dv)
);

-- Tabla info_grifo (correcta)
CREATE TABLE info_grifo (
  id_reg_grifo SERIAL PRIMARY KEY,
  id_grifo INTEGER NOT NULL REFERENCES grifo(id_grifo),
  fecha_registro DATE NOT NULL,
  estado TEXT NOT NULL,
  rut_num INTEGER NOT NULL REFERENCES bombero(rut_num),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_residencia_cut_com ON residencia(cut_com);
CREATE INDEX idx_registro_v_id_grupof ON registro_v(id_grupof);
CREATE INDEX idx_registro_v_id_residencia ON registro_v(id_residencia);
CREATE INDEX idx_grifo_cut_com ON grifo(cut_com);
CREATE INDEX idx_bombero_cut_com ON bombero(cut_com);

-- =====================================================
-- POLÍTICAS RLS (Row Level Security)
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE comunas ENABLE ROW LEVEL SECURITY;
ALTER TABLE residencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE grupofamiliar ENABLE ROW LEVEL SECURITY;
ALTER TABLE registro_v ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE mascota ENABLE ROW LEVEL SECURITY;
ALTER TABLE grifo ENABLE ROW LEVEL SECURITY;
ALTER TABLE bombero ENABLE ROW LEVEL SECURITY;
ALTER TABLE info_grifo ENABLE ROW LEVEL SECURITY;

-- Políticas para grupofamiliar (acceso público para lectura, autenticado para escritura)
CREATE POLICY "Anyone can view grupo familiar" ON grupofamiliar
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert grupo familiar" ON grupofamiliar
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update grupo familiar" ON grupofamiliar
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Políticas para bombero (acceso público para lectura, autenticado para escritura)
CREATE POLICY "Anyone can view bombero data" ON bombero
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert bombero data" ON bombero
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update bombero data" ON bombero
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Políticas para grifo e info_grifo (bomberos pueden leer/escribir)
CREATE POLICY "Bomberos can view grifos" ON grifo
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Bomberos can insert grifos" ON grifo
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Bomberos can view info grifo" ON info_grifo
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Bomberos can insert info grifo" ON info_grifo
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');