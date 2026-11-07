# Caracterización de fallas de infraestructura y ruteo adaptativo ante eventos críticos en la CDMX

Proyecto semestral de Minería de Datos · Licenciatura en Ciencia de Datos · ESCOM-IPN · Grupo 5AV1 · Equipo 3

**Equipo:** Juan De Dios Morales Martínez · Melanie Hernández López · Santiago Alexey Corona Cubeiro
**Profesor:** Roberto Eswart Zagal Flores
**Metodología:** CRISP-DM, organizada en sprints semanales

## Objetivo

Construir un modelo de minería de datos que clasifique el riesgo de falla de infraestructura en cada
zona de la Ciudad de México en cuatro niveles (bajo, medio, alto y crítico) y usar esos niveles como
pesos en un ruteo adaptativo que cambia según el escenario (día seco, día de lluvia, encharcamientos
recientes). Se integran los reportes de SACMEX y las solicitudes del *0311 de 2023.

## Requisitos

- Python 3.11 o superior (el entorno se probó con Python 3.12)
- Git
- PostgreSQL 17 con PostGIS (para las tablas de staging y las capas geográficas)

## Instalación

1. Clonar el repositorio y entrar a la carpeta:

   ```
   git clone https://github.com/MelSurikun/cdmx-infrastructure-risk-routing.git
   cd cdmx-infrastructure-risk-routing
   ```

2. Crear el entorno virtual (se llama `.venv` y git lo ignora):

   ```
   python -m venv .venv
   ```

3. Activar el entorno:

   - Windows (PowerShell): `.\.venv\Scripts\Activate.ps1`
   - Windows (cmd): `.venv\Scripts\activate.bat`
   - macOS o Linux: `source .venv/bin/activate`

   Si PowerShell bloquea el script de activación, correr una sola vez:
   `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

4. Instalar las dependencias:

   ```
   python -m pip install --upgrade pip
   pip install -r requirements.txt
   ```

5. Verificar la instalación:

   ```
   python src/verificar_entorno.py
   ```

   Debe terminar con el mensaje `Entorno listo`. El aviso `missing ScriptRunContext` que imprime
   Streamlit al importarse es normal y se puede ignorar. Si alguna librería aparece como `FALLA`,
   revisar que el entorno esté activado y repetir el paso 4.

6. (Opcional) Registrar el entorno como kernel de Jupyter para los notebooks:

   ```
   python -m ipykernel install --user --name cdmx_riesgo --display-name "cdmx_riesgo"
   ```

## Estructura del repositorio

| Carpeta | Contenido |
| --- | --- |
| `data/raw/` | Archivos originales. No se suben a git; se documenta cómo descargarlos |
| `data/processed/` | Salidas intermedias (celdas_h3.parquet, grafo.graphml, modelado.parquet). No se suben; se regeneran con los scripts |
| `sql/` | Scripts SQL numerados por orden de ejecución (01_crear_tablas.sql, 02_cargar_datos.sql, ...) |
| `notebooks/` | Notebooks numerados por orden de ejecución (01_eda, 05_baseline, 06_modelos, ...) |
| `src/` | Funciones reutilizables: limpieza, variables, ruteo |
| `app/` | App demo en Streamlit (app.py) |
| `docs/` | Objetivo v2, diccionario de variables, bitácora y reporte |
| `requirements.txt` | Dependencias con versión fija |

## Datos

Las fuentes principales provienen del [Portal de Datos Abiertos de la CDMX](https://datos.cdmx.gob.mx/):
Reportes de agua (SACMEX) y Solicitudes *0311 (ADIP / Locatel). Los archivos se guardan en `data/raw/`
y cada uno se documentará con su URL, fecha de descarga y huella SHA-256.

## Flujo de trabajo con Git

Todo el trabajo se hace en una sola rama: `main`. No se crean otras ramas.

Pasos para una tarea:

```
git pull
# ... trabajo ...
git status
git add .
git commit -m "Descripción corta del cambio"
git push origin main
```

Hacer `git pull` antes de empezar y antes de subir evita conflictos con los cambios de los demás.
Una tarea se considera hecha cuando está en `main`, otra persona del equipo la revisó, está enlazada
en su tarjeta de Trello y descrita en 2 a 3 líneas en `docs/bitacora.md`.

## Convenciones

- Nombres de archivos, carpetas y columnas en minúsculas con guion bajo (snake_case), en español, sin guiones medios.
- Coordenadas en EPSG:4326; para distancias en metros se reproyecta a EPSG:6372.
- Fechas en hora local de la CDMX con formato `AAAA-MM-DD hh:mm:ss`.
- Resultados siempre agregados por zona; nunca se publican datos que identifiquen a personas.
