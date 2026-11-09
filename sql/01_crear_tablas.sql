-- S1 tarea 3 · Crea los esquemas y las tablas crudas (copia fiel de los CSV de origen).
-- raw: datos tal como vienen del portal. stg: datos limpios (ver 04_staging.sql).
-- Ejecutar desde la raiz del repo:
--   psql -U postgres -d cdmx_riesgo -f sql/01_crear_tablas.sql

\encoding UTF8

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;

-- Dataset A: Reportes de agua SACMEX 2022-2024 (evento primario y fallas de agua y drenaje)
DROP TABLE IF EXISTS raw.reportes_agua CASCADE;
CREATE TABLE raw.reportes_agua (
    folio_incidente          TEXT,              -- agrupa varios reportes del mismo incidente
    fecha_registro_incidente DATE,
    id_reporte               TEXT,
    fecha_reporte            DATE,
    hora_reporte             TIME,
    clasificacion            TEXT,              -- Agua Potable / Drenaje / Agua Tratada
    reporte                  TEXT,              -- 20 tipos (Fuga, Encharcamiento, ...)
    medio_recepcion          TEXT,
    alcaldia_catalogo        TEXT,
    colonia_catalogo         TEXT,
    longitud                 DOUBLE PRECISION,
    latitud                  DOUBLE PRECISION
);

-- Dataset B: Solicitudes *0311 Locatel 2023 (fallas secundarias en la via publica)
DROP TABLE IF EXISTS raw.solicitudes_0311 CASCADE;
CREATE TABLE raw.solicitudes_0311 (
    id_folio                TEXT,               -- unico por solicitud
    fecha_solicitud         DATE,
    hora_solicitud          TIME,
    tipo_de_entrada         TEXT,               -- canal (8 valores)
    tema_solicitud          TEXT,               -- 49 temas
    sexo                    TEXT,
    edad                    TEXT,               -- texto: trae valores imposibles, se depura en staging
    colonia_solicitud       TEXT,
    alcaldia_solicitud      TEXT,
    codigo_postal_solicitud TEXT,               -- texto para conservar el cero inicial (04300)
    estatus                 TEXT,
    fecha_concluido         DATE,
    alcaldia_catalogo       TEXT,
    colonia_catalogo        TEXT,
    longitud                DOUBLE PRECISION,
    latitud                 DOUBLE PRECISION
);
