-- S1 tarea 3 · Verificacion de la carga cruda (adaptado del Anexo B.3 de la P1).
--   psql -U postgres -d cdmx_riesgo -f sql/03_verificacion.sql

\encoding UTF8

\echo '=== raw.reportes_agua ==='
SELECT COUNT(*) AS total_registros FROM raw.reportes_agua;              -- 313,756

SELECT MIN(fecha_reporte) AS fecha_min, MAX(fecha_reporte) AS fecha_max,
       COUNT(DISTINCT date_trunc('month', fecha_reporte)) AS meses_distintos
FROM raw.reportes_agua;

SELECT ROUND(100.0 * COUNT(latitud) / COUNT(*), 2)           AS pct_lat_no_nula,
       ROUND(100.0 * COUNT(alcaldia_catalogo) / COUNT(*), 2) AS pct_alcaldia_no_nula,
       ROUND(100.0 * COUNT(colonia_catalogo) / COUNT(*), 2)  AS pct_colonia_no_nula
FROM raw.reportes_agua;

SELECT COUNT(*) AS fuera_de_bbox_cdmx                                   -- 153
FROM raw.reportes_agua
WHERE latitud IS NOT NULL
  AND (latitud NOT BETWEEN 19.0 AND 19.6 OR longitud NOT BETWEEN -99.4 AND -98.9);

SELECT COUNT(*) - COUNT(DISTINCT folio_incidente) AS filas_con_folio_incidente_repetido,
       COUNT(DISTINCT folio_incidente)            AS incidentes             -- 255,146
FROM raw.reportes_agua;

\echo '=== raw.solicitudes_0311 ==='
SELECT COUNT(*) AS total_registros FROM raw.solicitudes_0311;           -- 569,362

SELECT MIN(fecha_solicitud) AS fecha_min, MAX(fecha_solicitud) AS fecha_max,
       COUNT(DISTINCT date_trunc('month', fecha_solicitud)) AS meses_distintos
FROM raw.solicitudes_0311;

SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE latitud IS NOT NULL AND latitud <> 0) / COUNT(*), 2)
           AS pct_con_latitud,                                          -- 38.03
       ROUND(100.0 * COUNT(*) FILTER (WHERE latitud IS NOT NULL AND longitud IS NOT NULL
                                        AND latitud <> 0 AND longitud <> 0) / COUNT(*), 2)
           AS pct_par_completo,                                         -- 37.29
       ROUND(100.0 * COUNT(alcaldia_solicitud) / COUNT(*), 2)      AS pct_alcaldia_declarada,  -- 45.64
       ROUND(100.0 * COUNT(codigo_postal_solicitud) / COUNT(*), 2) AS pct_codigo_postal        -- 91.48
FROM raw.solicitudes_0311;

SELECT COUNT(DISTINCT tema_solicitud)         AS temas_distintos,       -- 49
       COUNT(*) - COUNT(DISTINCT id_folio)    AS folios_duplicados      -- 0
FROM raw.solicitudes_0311;

SELECT tema_solicitud, COUNT(*) AS n
FROM raw.solicitudes_0311
GROUP BY tema_solicitud
ORDER BY n DESC
LIMIT 10;
