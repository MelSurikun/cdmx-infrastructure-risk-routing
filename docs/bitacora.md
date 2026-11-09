# Bitácora del proyecto

Registro breve de lo que se hizo en cada tarea (requisito de la Definición de Hecho).
Formato: fecha, sprint y tarea, responsable, 2 a 3 líneas.

## 2026-11-06 · S1 tarea 2 · Repositorio y entorno · Melanie

Se creó la estructura de carpetas del repositorio (data, sql, notebooks, src, app, docs) y se
ajustó el .gitignore para no subir datos originales ni intermedios. Se fijaron las versiones de las
librerías en requirements.txt (entorno con venv) y se agregó src/verificar_entorno.py para comprobar
la instalación. El README explica la instalación paso a paso y el flujo de trabajo, todo en la rama main.

## 2026-11-08 · S1 tarea 3 · Staging y limpieza · Melanie

Se agregaron los scripts sql/01 a sql/05: carga cruda de SACMEX 2022 a 2024 y *0311 2023 en el esquema raw, y
staging en el esquema stg con familia de falla (tabla stg.mapa_familia) y banderas fila_repetida (fila idéntica
completa, 12,729), hueco_abril y coord_valida. sql/05_conteos_p1.sql compara cada conteo con la P1; las fuentes y
sus huellas SHA-256 quedan en docs/fuentes_datos.md.
Los dos CSV de esta tarea (ReportesAgua20222024.csv y locatel0311-2023.csv) están en un ZIP en la carpeta
PROYECTO del Drive del equipo. Hay que descomprimirlo dentro de data/raw/ de la copia local del repo, sin
subcarpetas y con los mismos nombres de archivo, antes de correr los scripts.
