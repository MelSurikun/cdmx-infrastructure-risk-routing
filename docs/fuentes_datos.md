# Fuentes de datos

Los archivos originales se guardan en `data/raw/` y no se suben a git. Para reproducir el proyecto hay que
descargarlos del [Portal de Datos Abiertos de la CDMX](https://datos.cdmx.gob.mx/) con el mismo nombre y comprobar
su huella SHA-256 (en PowerShell: `Get-FileHash data/raw/<archivo> -Algorithm SHA256`).

| Archivo | Conjunto | Publica | Página del conjunto en el portal | Fecha de descarga | Filas | Columnas | SHA-256 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `ReportesAgua20222024.csv` | Reportes de agua (2022 a 2024) | SACMEX | https://datos.cdmx.gob.mx/dataset/reportes-de-agua | 2026-09-16 | 313,756 | 12 | `b4598427aa4669259678428946a84d94341d2372d312f9c5fcc79ea35be6d809` |
| `locatel0311-2023.csv` | Solicitudes *0311 Locatel (2023) | ADIP | https://datos.cdmx.gob.mx/dataset/0311 | 2026-09-16 | 569,362 | 16 | `487bd22dc9b49f89316f79cb752a239c2838a82714f6214fd32b23271e2396a9` |

Ambos archivos vienen en UTF-8 sin BOM, separados por comas, con encabezado y con los faltantes escritos como `NA`.

Otros archivos que hay en `data/raw/` pero que no se usan: `ReportesAgua20182021.csv` (su esquema de columnas
es distinto al de 2022 a 2024) y `locatel0311-2019.csv` a `locatel0311-2022.csv` y `locatel0311-2024.csv`
(el periodo principal es 2023; ver la P1, sección de selección de datos).
