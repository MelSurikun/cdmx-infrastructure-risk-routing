-- S1 tarea 3 · Staging y limpieza.
-- Produce stg.reportes_agua y stg.solicitudes_0311 (contrato de la seccion 6.4 del documento de contexto):
-- columnas tipadas, periodo 2023, familia de falla y banderas de calidad.
--   psql -U postgres -d cdmx_riesgo -f sql/04_staging.sql
--
-- Reglas (comprobadas contra los conteos de la P1, ver 05_conteos_p1.sql):
--   fila_repetida  fila identica en TODAS las columnas a otra anterior (12,729 en SACMEX; 0 en *0311).
--                  Las repetidas se marcan, no se borran; para analisis usar stg.v_reportes_agua.
--   hueco_abril    dias con captura casi nula: SACMEX 2023-04-12 a 2023-04-30; *0311 2023-04-26 a 2023-04-30.
--   coord_valida   latitud y longitud presentes, distintas de 0 y dentro del rectangulo de la CDMX
--                  (lat 19.0 a 19.6, lon -99.4 a -98.9). Se refinara con el poligono de la CDMX en la tarea 4.
--   edad           entera solo si esta entre 10 y 110 anios; si no, NULL (edad_valida = false).
--   familia        segun stg.mapa_familia; lo que no aparece ahi queda como 'otro'.

\encoding UTF8

-- 1. Mapeo explicito de tipos originales a familias de falla -----------------------------------------
DROP TABLE IF EXISTS stg.mapa_familia CASCADE;
CREATE TABLE stg.mapa_familia (
    fuente         TEXT NOT NULL,      -- 'sacmex' o '0311'
    valor_original TEXT NOT NULL,      -- reporte (SACMEX) o tema_solicitud (*0311)
    familia        TEXT NOT NULL,
    PRIMARY KEY (fuente, valor_original)
);

INSERT INTO stg.mapa_familia (fuente, valor_original, familia) VALUES
    -- SACMEX: evento primario
    ('sacmex', 'Encharcamiento',                           'encharcamiento'),
    -- SACMEX: fallas de agua y drenaje
    ('sacmex', 'Fuga',                                     'fuga'),
    ('sacmex', 'Socavon',                                  'socavon'),
    ('sacmex', 'Hundimiento',                              'socavon'),
    ('sacmex', 'Drenaje Obstruido',                        'otra_drenaje'),
    ('sacmex', 'Brote en aguas negras',                    'otra_drenaje'),
    ('sacmex', 'Coladera sin tapa',                        'otra_drenaje'),
    ('sacmex', 'Boca de tormenta',                         'otra_drenaje'),
    ('sacmex', 'Pozo de visita',                           'otra_drenaje'),
    ('sacmex', 'Rejilla de piso',                          'otra_drenaje'),
    -- *0311: fallas secundarias en la via publica (los cuatro temas del proyecto)
    ('0311',   'BACHEO',                                   'bache'),
    ('0311',   'DESAZOLVE',                                'desazolve'),
    ('0311',   'FUGA DE AGUA',                             'fuga'),
    ('0311',   'MANTENIMIENTO DE COLADERA / ALCANTARILLA', 'coladera');
-- Nota: 'Falta de agua' (SACMEX) es falla del servicio, no de la calle, y queda como 'otro'.
-- 'MANTENIMIENTO DRENAJE' (*0311, 5,721 en 2023) queda como 'otro' para coincidir con la P1.

-- 2. Reportes de agua SACMEX ---------------------------------------------------------------------------
DROP TABLE IF EXISTS stg.reportes_agua CASCADE;
CREATE TABLE stg.reportes_agua AS
WITH numeradas AS (
    SELECT r.*,
           ROW_NUMBER() OVER (
               PARTITION BY folio_incidente, fecha_registro_incidente, id_reporte, fecha_reporte,
                            hora_reporte, clasificacion, reporte, medio_recepcion,
                            alcaldia_catalogo, colonia_catalogo, longitud, latitud
               ORDER BY id_reporte
           ) AS n_copia
    FROM raw.reportes_agua r
)
SELECT
    ROW_NUMBER() OVER (ORDER BY n.fecha_reporte, n.hora_reporte, n.id_reporte)::BIGINT AS id_stg,
    n.id_reporte,
    n.folio_incidente,
    n.fecha_registro_incidente,
    n.fecha_reporte,
    n.hora_reporte,
    (n.fecha_reporte + n.hora_reporte)::TIMESTAMP                   AS fecha_hora,
    n.clasificacion,
    n.reporte,
    COALESCE(m.familia, 'otro')                                     AS familia,
    n.medio_recepcion,
    n.alcaldia_catalogo,
    n.colonia_catalogo,
    n.latitud,
    n.longitud,
    (n.n_copia > 1)                                                 AS fila_repetida,
    (n.fecha_reporte BETWEEN DATE '2023-04-12' AND DATE '2023-04-30') AS hueco_abril,
    COALESCE(n.latitud IS NOT NULL AND n.longitud IS NOT NULL
             AND n.latitud <> 0 AND n.longitud <> 0
             AND n.latitud  BETWEEN 19.0  AND 19.6
             AND n.longitud BETWEEN -99.4 AND -98.9, FALSE)         AS coord_valida
FROM numeradas n
LEFT JOIN stg.mapa_familia m
       ON m.fuente = 'sacmex' AND m.valor_original = n.reporte
WHERE n.fecha_reporte >= DATE '2023-01-01'
  AND n.fecha_reporte <  DATE '2024-01-01';

ALTER TABLE stg.reportes_agua ADD PRIMARY KEY (id_stg);
CREATE INDEX ON stg.reportes_agua (fecha_hora);
CREATE INDEX ON stg.reportes_agua (familia);

-- Vista sin filas repetidas: es la que deben usar la integracion (hechos_evento) y los analisis.
CREATE OR REPLACE VIEW stg.v_reportes_agua AS
SELECT * FROM stg.reportes_agua WHERE NOT fila_repetida;

-- 3. Solicitudes *0311 ---------------------------------------------------------------------------------
DROP TABLE IF EXISTS stg.solicitudes_0311 CASCADE;
CREATE TABLE stg.solicitudes_0311 AS
SELECT
    s.id_folio,
    s.fecha_solicitud,
    s.hora_solicitud,
    (s.fecha_solicitud + s.hora_solicitud)::TIMESTAMP               AS fecha_hora,
    s.tipo_de_entrada,
    s.tema_solicitud,
    COALESCE(m.familia, 'otro')                                     AS familia,
    s.estatus,
    s.fecha_concluido,
    s.sexo,                                                         -- solo para analisis agregados
    e.edad,
    (e.edad IS NOT NULL)                                            AS edad_valida,
    s.alcaldia_solicitud,
    s.colonia_solicitud,
    s.codigo_postal_solicitud,
    s.alcaldia_catalogo,
    s.colonia_catalogo,
    s.latitud,
    s.longitud,
    FALSE                                                           AS fila_repetida,  -- id_folio es unico
    (s.fecha_solicitud BETWEEN DATE '2023-04-26' AND DATE '2023-04-30') AS hueco_abril,
    COALESCE(s.latitud IS NOT NULL AND s.longitud IS NOT NULL
             AND s.latitud <> 0 AND s.longitud <> 0
             AND s.latitud  BETWEEN 19.0  AND 19.6
             AND s.longitud BETWEEN -99.4 AND -98.9, FALSE)         AS coord_valida
FROM raw.solicitudes_0311 s
-- CASE anidado: el cast a entero solo se intenta si el texto es numerico
CROSS JOIN LATERAL (
    SELECT CASE WHEN s.edad ~ '^[0-9]{1,3}$'
                THEN CASE WHEN s.edad::INT BETWEEN 10 AND 110 THEN s.edad::INT END
           END AS edad
) e
LEFT JOIN stg.mapa_familia m
       ON m.fuente = '0311' AND m.valor_original = s.tema_solicitud
WHERE s.fecha_solicitud >= DATE '2023-01-01'
  AND s.fecha_solicitud <  DATE '2024-01-01';

ALTER TABLE stg.solicitudes_0311 ADD PRIMARY KEY (id_folio);
CREATE INDEX ON stg.solicitudes_0311 (fecha_hora);
CREATE INDEX ON stg.solicitudes_0311 (familia);

ANALYZE stg.reportes_agua;
ANALYZE stg.solicitudes_0311;
