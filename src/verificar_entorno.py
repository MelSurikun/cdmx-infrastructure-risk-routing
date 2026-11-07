"""Verifica que el entorno del proyecto este instalado correctamente.

Uso (con el entorno virtual activado, desde la raiz del repositorio):
    python src/verificar_entorno.py

Importa cada libreria de requirements.txt e imprime su version.
Termina con codigo 1 si alguna libreria no se pudo importar.
"""

import importlib
import sys
from importlib import metadata

# nombre del modulo a importar : nombre del paquete en requirements.txt
LIBRERIAS = {
    "pandas": "pandas",
    "numpy": "numpy",
    "pyarrow": "pyarrow",
    "geopandas": "geopandas",
    "shapely": "shapely",
    "pyproj": "pyproj",
    "pyogrio": "pyogrio",
    "h3": "h3",
    "scipy": "scipy",
    "statsmodels": "statsmodels",
    "sklearn": "scikit-learn",
    "lightgbm": "lightgbm",
    "imblearn": "imbalanced-learn",
    "shap": "shap",
    "mlxtend": "mlxtend",
    "networkx": "networkx",
    "osmnx": "osmnx",
    "folium": "folium",
    "matplotlib": "matplotlib",
    "streamlit": "streamlit",
    "streamlit_folium": "streamlit-folium",
    "psycopg": "psycopg",
    "sqlalchemy": "sqlalchemy",
    "ipykernel": "ipykernel",
}


def main() -> int:
    print(f"Python {sys.version.split()[0]}\n")
    fallas = []
    for modulo, paquete in LIBRERIAS.items():
        try:
            importlib.import_module(modulo)
            version = metadata.version(paquete)
            print(f"  OK     {paquete:<20} {version}")
        except Exception as error:  # se reporta cualquier error de importacion
            fallas.append(paquete)
            print(f"  FALLA  {paquete:<20} {error}")

    print()
    if fallas:
        print(f"Faltan o fallan {len(fallas)} librerias: {', '.join(fallas)}")
        print("Revisa que el entorno este activado y corre: pip install -r requirements.txt")
        return 1
    print(f"Entorno listo: {len(LIBRERIAS)} librerias importadas sin errores.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
