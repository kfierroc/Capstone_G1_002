CREATE TABLE residencia (
  id_residencia INTEGER PRIMARY KEY NOT NULL,
  direccion TEXT UNIQUE NOT NULL,
  lat DECIMAL(12,6) NOT NULL,
  lon DECIMAL(12,6) NOT NULL,
  CUT_COM INTEGER NOT NULL REFERENCES comunas(CUT_COM)
);

CREATE TABLE grupofamiliar(
  id_grupof INTEGER PRIMARY KEY NOT NULL,
  rut_titular varchar(12) NOT NULL,
  telefono_titular VARCHAR(13) NOT NULL,
  CHECK (telefono_titular ~ '^\+56[2-9][0-9]{8,9}$'),
  email TEXT UNIQUE NOT NULL,
  fecha_creacion DATE NOT NULL
);

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
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);

CREATE TABLE integrante(
  id_integrante INTEGER PRIMARY KEY NOT NULL,
  activo_i BOOLEAN NOT NULL,
  fecha_ini_i DATE NOT NULL,
  fecha_fin_i DATE,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);

CREATE TABLE info_integrante(
  id_integrante INTEGER PRIMARY KEY NOT NULL REFERENCES integrante(id_integrante),
  fecha_reg_ii DATE NOT NULL,
  anio_nac INTEGER NOT NULL,
  padecimiento TEXT
);
CREATE TABLE mascota(
  id_mascota INTEGER PRIMARY KEY,
  nombre_m TEXT NOT NULL,
  especie TEXT NOT NULL,
  tamanio TEXT NOT NULL,
  fecha_reg_m DATE NOT NULL,
  id_grupof INTEGER NOT NULL REFERENCES grupofamiliar(id_grupof)
);




CREATE TABLE grifo (
  id_grifo SERIAL PRIMARY KEY,
  lat DECIMAL(12,6) NOT NULL,
  lon DECIMAL(12,6) NOT NULL,
  CUT_COM INTEGER NOT NULL REFERENCES comunas(CUT_COM)
);

CREATE TABLE bombero (
  rut_num INTEGER PRIMARY KEY NOT NULL,
  rut_dv CHAR(1) NOT NULL,
  compania VARCHAR(4) NOT NULL,
  nomb_bombero varchar(50) NOT NULL,
  ape_p_bombero varchar(50) NOT NULL,
  email_b TEXT UNIQUE NOT NULL,
  is_admin BOOLEAN,

  CUT_COM INTEGER NOT NULL REFERENCES comunas(CUT_COM),

  CONSTRAINT uq_rut UNIQUE (rut_num, rut_dv)
);

CREATE TABLE info_grifo (
  id_reg_grifo SERIAL PRIMARY KEY,
  id_grifo INTEGER NOT NULL REFERENCES grifo(id_grifo),
  fecha_registro DATE NOT NULL,
  estado TEXT NOT NULL,
  nota varchar(100),
  rut_num INTEGER NOT NULL REFERENCES bombero(rut_num)
);
