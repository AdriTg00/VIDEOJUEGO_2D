import os
import sys

def get_base_dir():
    """
    Devuelve la ruta base correcta tanto:
    - en desarrollo
    - como en ejecutable PyInstaller
    """
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
