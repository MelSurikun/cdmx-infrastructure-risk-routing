-- S1 tarea 3 · Criterio de hecho: los conteos del staging coinciden con los de la P1.
--   psql -U postgres -d cdmx_riesgo -f sql/05_conteos_p1.sql
-- Cada fila compara la cifra publicada en la P1 con la obtenida; todas deben decir 'coincide'.

\encoding UTF8

WITH obtenido AS (
    SELECT 'sacmex_total_crudo' AS indicador, 313756::NUMERIC AS esperado,
           (SELECT COUNT(*) FROM raw.reportes_agua)::NUMERIC AS obtenido
    UNION ALL
    SELECT 'sacmex_filas_repetidas', 12729,
           (SELECT COALESCE(SUM(n - 1), 0) FROM (
                SELECT COUNT(*) AS n FROM raw.reportes_agua
                GROUP BY folio_incidente, fecha_registro_incidente, id_reporte, fecha_reporte,
                         hora_reporte, clasificacion, reporte, medio_recepcion,
                         alcaldia_catalogo, colonia_catalogo, longitud, latitud) g)
    UNION ALL
    SELECT 'sacmex_incidentes', 255146,
           (SELECT COUNT(DISTINCT folio_incidente) FROM raw.reportes_agua)
    UNION ALL
    SELECT 'sacmex_fuera_de_bbox', 153,
           (SELECT COUNT(*) FROM raw.reportes_agua
             WHERE latitud NOT BETWEEN 19.0 AND 19.6 OR longitud NOT BETWEEN -99.4 AND -98.9)
    UNION ALL
    SELECT 'sacmex_2023_sin_repetidas', 130839, (SELECT COUNT(*) FROM stg.v_reportes_agua)
    UNION ALL
    SELECT 'sacmex_2023_encharcamiento', 1582,
           (SELECT COUNT(*) FROM stg.v_reportes_agua WHERE familia = 'encharcamiento')
    UNION ALL
    SELECT 'sacmex_2023_fuga', 44872,
           (SELECT COUNT(*) FROM stg.v_reportes_agua WHERE familia = 'fuga')
    UNION ALL
    SELECT 'sacmex_2023_socavon', 648,
           (SELECT COUNT(*) FROM stg.v_reportes_agua WHERE familia = 'socavon')
    UNION ALL
    SELECT 'sacmex_2023_otra_drenaje', 11419,
           (SELECT COUNT(*) FROM stg.v_reportes_agua WHERE familia = 'otra_drenaje')
    UNION ALL
    SELECT '0311_total', 569362, (SELECT COUNT(*) FROM stg.solicitudes_0311)
    UNION ALL
    SELECT '0311_folios_unicos', 569362, (SELECT COUNT(DISTINCT id_folio) FROM raw.solicitudes_0311)
    UNION ALL
    SELECT '0311_bache', 26120,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE familia = 'bache')
    UNION ALL
    SELECT '0311_desazolve', 25859,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE familia = 'desazolve')
    UNION ALL
    SELECT '0311_fuga', 25060,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE familia = 'fuga')
    UNION ALL
    SELECT '0311_coladera', 15475,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE familia = 'coladera')
    UNION ALL
    SELECT '0311_cuatro_temas', 92514,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE familia <> 'otro')
    UNION ALL
    SELECT '0311_pct_par_completo', 37.29,
           (SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE latitud IS NOT NULL AND longitud IS NOT NULL
                                                    AND latitud <> 0 AND longitud <> 0) / COUNT(*), 2)
              FROM stg.solicitudes_0311)
    UNION ALL
    SELECT '0311_edad_valida', 47029,
           (SELECT COUNT(*) FROM stg.solicitudes_0311 WHERE edad_valida)
)
SELECT indicador, esperado, obtenido,
       CASE WHEN esperado = obtenido THEN 'coincide' ELSE 'NO COINCIDE' END AS resultado
FROM obtenido;

\echo '=== Banderas (informativo, sin cifra de la P1) ==='
SELECT 'sacmex' AS fuente,
       COUNT(*) FILTER (WHERE hueco_abril)      AS en_hueco_abril,
       COUNT(*) FILTER (WHERE coord_valida)     AS con_coord_valida,
       ROUND(100.0 * COUNT(*) FILTER (WHERE coord_valida) / COUNT(*), 2) AS pct_coord_valida
FROM stg.v_reportes_agua
UNION ALL
SELECT '0311',
       COUNT(*) FILTER (WHERE hueco_abril),
       COUNT(*) FILTER (WHERE coord_valida),
       ROUND(100.0 * COUNT(*) FILTER (WHERE coord_valida) / COUNT(*), 2)
FROM stg.solicitudes_0311;
