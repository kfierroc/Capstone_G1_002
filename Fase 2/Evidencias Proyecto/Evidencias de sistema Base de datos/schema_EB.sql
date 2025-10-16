-- Instala la extensión pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Extensión PostGIS para soporte geoespacial
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabla de comunas
CREATE TABLE comunas (
    CUT_COM INTEGER PRIMARY KEY NOT NULL,
    COMUNA TEXT NOT NULL,
    CUT_REG INTEGER NOT NULL,
    REGION TEXT NOT NULL,
    CUT_PROV INTEGER NOT NULL,
    PROVINCIA TEXT NOT NULL,
    SUPERFICIE DECIMAL(10,2) NOT NULL,
    geometry geometry(MULTIPOLYGON, 4326) NOT NULL
);

-- Tabla residencia
CREATE TABLE residencia (
  id_residencia SERIAL PRIMARY KEY,
  direccion TEXT UNIQUE NOT NULL,
  lat DECIMAL(16,14) NOT NULL,
  lon DECIMAL(16,14) NOT NULL,
  CUT_COM INTEGER NOT NULL REFERENCES comunas(CUT_COM) ON DELETE CASCADE
);

-- Tabla grupo familiar
CREATE TABLE grupofamiliar(
  id_grupof SERIAL PRIMARY KEY,
  rut_titular VARCHAR(12) NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL CHECK (char_length(password) >= 60),
  fecha_creacion DATE NOT NULL
);

-- Tabla registro vivienda
CREATE TABLE registro_v (
  id_registro SERIAL PRIMARY KEY,
  vigente BOOLEAN NOT NULL,
  estado TEXT NOT NULL,
  material TEXT NOT NULL,
  tipo TEXT NOT NULL,
  fecha_ini_r DATE NOT NULL,
  fecha_fin_r DATE,
  id_residencia INTEGER NOT NULL REFERENCES residencia(id_residencia) ON DELETE CASCADE,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE
);

-- Tabla integrante
CREATE TABLE integrante(
  id_integrante SERIAL PRIMARY KEY,
  activo_i BOOLEAN NOT NULL,
  fecha_ini_i DATE NOT NULL,
  fecha_fin_i DATE,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE
);

-- Tabla info integrante
CREATE TABLE info_integrante(
  id_integrante INTEGER PRIMARY KEY REFERENCES integrante(id_integrante) ON DELETE CASCADE,
  fecha_reg_ii DATE NOT NULL,
  anio_nac INTEGER NOT NULL,
  padecimiento TEXT
);

-- Tabla mascota
CREATE TABLE mascota(
  id_mascota SERIAL PRIMARY KEY,
  nombre_m TEXT NOT NULL,
  especie TEXT NOT NULL,
  tamanio TEXT NOT NULL,
  fecha_reg_m DATE NOT NULL,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof) ON DELETE CASCADE
);

-- Tabla grifo
CREATE TABLE grifo (
  id_grifo SERIAL PRIMARY KEY,
  lat DECIMAL(9,6) NOT NULL,
  lon DECIMAL(9,6) NOT NULL,
  CUT_COM INTEGER NOT NULL REFERENCES comunas(CUT_COM) ON DELETE CASCADE
);

-- Tabla bombero
CREATE TABLE bombero (
  rut_num INTEGER PRIMARY KEY NOT NULL,
  rut_dv CHAR(1) NOT NULL,
  email_b TEXT UNIQUE NOT NULL,
  password_b TEXT NOT NULL CHECK (char_length(password_b) >= 60),
  CONSTRAINT uq_rut UNIQUE (rut_num, rut_dv)
);

-- Tabla info grifo
CREATE TABLE info_grifo (
  id_reg_grifo SERIAL PRIMARY KEY,
  id_grifo INTEGER NOT NULL REFERENCES grifo(id_grifo) ON DELETE CASCADE,
  fecha_registro DATE NOT NULL,
  estado TEXT NOT NULL,
  rut_num INTEGER NOT NULL REFERENCES bombero(rut_num) ON DELETE CASCADE
);
