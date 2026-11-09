-- S1 tarea 3 · Carga masiva de los CSV de data/raw/ (ver docs/fuentes_datos.md).
-- Las rutas son relativas: ejecutar desde la raiz del repo.
--   psql -U postgres -d cdmx_riesgo -f sql/02_cargar_datos.sql
-- Los valores faltantes vienen escritos como NA en ambos archivos.

\encoding UTF8

TRUNCATE raw.reportes_agua;
\copy raw.reportes_agua FROM 'data/raw/ReportesAgua20222024.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL 'NA')

TRUNCATE raw.solicitudes_0311;
\copy raw.solicitudes_0311 FROM 'data/raw/locatel0311-2023.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8', NULL 'NA')

-- Resultado esperado:
--   COPY 313756 (raw.reportes_agua)
--   COPY 569362 (raw.solicitudes_0311)
