from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QMessageBox

import os
import json
import sys
import subprocess


# =========================================================
# UTILIDADES
# =========================================================

def get_base_dir():
    """
    Devuelve el directorio base de ejecución:
    - En ejecutable (PyInstaller): carpeta donde está Launcher.exe
    - En desarrollo: raíz del proyecto
    """
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    else:
        return os.path.abspath(
            os.path.join(os.path.dirname(__file__), "..", "..")
        )


def get_user_file():
    """
    Ruta absoluta al archivo de usuario persistente
    """
    return os.path.join(get_base_dir(), "usuario_local.json")


# =========================================================
# CONTROLADOR PRINCIPAL
# =========================================================

class AppController:
    def __init__(self):
        # -----------------------------
        # Estado global de la app
        # -----------------------------
        self.app_state = {
            "language": "Español",
            "usuario": None
        }

        self.user_id = None
        self.nombre_jugador = None

        # Flag para evitar doble lanzamiento
        self.juego_lanzado = False

        # -----------------------------
        # Ventanas
        # -----------------------------
        self.launcher = launcher(self.app_state)
        self.config_window = configuracion(self.app_state)
        self.carg_partidas = cargar(self.app_state)
        self.introducir_nombre = introducirNombre(self.app_state)

        # -----------------------------
        # Señales
        # -----------------------------
        self.introducir_nombre.nombre_validado.connect(
            self._on_nombre_validado,
            type=Qt.QueuedConnection
        )

        self.launcher.abrir_config_signal.connect(self.mostrar_configuracion)
        self.launcher.abrir_cargar_signal.connect(self.mostrar_partidas_guardadas)
        self.launcher.abrir_nueva_signal.connect(self.abrir_nueva_partida)

        self.launcher.idioma_cambiado.connect(self.config_window.apply_language)
        self.launcher.idioma_cambiado.connect(self.carg_partidas.apply_language)
        self.launcher.idioma_cambiado.connect(self.introducir_nombre.apply_language)

        # -----------------------------
        # Arranque
        # -----------------------------
        self.comprobar_usuario_local()

    # =========================================================
    # ARRANQUE Y USUARIO
    # =========================================================

    def comprobar_usuario_local(self):
        user_file = get_user_file()

        if os.path.exists(user_file):
            try:
                with open(user_file, "r", encoding="utf-8") as f:
                    datos = json.load(f)

                user_id = datos.get("id")
                print("Usuario ya registrado:", user_id)

                self.user_id = user_id
                self.nombre_jugador = user_id
                self.app_state["usuario"] = user_id

                self.mostrar_launcher()

            except Exception as e:
                print("[AppController] Error leyendo usuario_local.json:", e)
                self.mostrar_introducir_nombre()
        else:
            self.mostrar_introducir_nombre()

    def _on_nombre_validado(self, user_id):
        print("[AppController] Usuario validado:", user_id)

        self.user_id = user_id
        self.nombre_jugador = user_id
        self.app_state["usuario"] = user_id

        try:
            with open(get_user_file(), "w", encoding="utf-8") as f:
                json.dump({"id": user_id}, f, indent=4)
        except Exception as e:
            print("[AppController] Error guardando usuario_local.json:", e)

        self.mostrar_launcher()

    # =========================================================
    # MOSTRAR VENTANAS
    # =========================================================

    def mostrar_launcher(self):
        try:
            self.introducir_nombre.hide()
        except Exception:
            pass

        if not self.launcher.isVisible():
            self.launcher.show()

        self.launcher.raise_()
        self.launcher.activateWindow()

    def mostrar_introducir_nombre(self):
        self.introducir_nombre.setWindowModality(Qt.ApplicationModal)
        self.introducir_nombre.show()
        self.introducir_nombre.raise_()
        self.introducir_nombre.activateWindow()

    def mostrar_partidas_guardadas(self):
        self.carg_partidas.setWindowModality(Qt.ApplicationModal)
        self.carg_partidas.show()

    def mostrar_configuracion(self):
        self.config_window.setWindowModality(Qt.ApplicationModal)
        self.config_window.show()

    # =========================================================
    # ACCIONES DEL LAUNCHER
    # =========================================================

    def abrir_nueva_partida(self):
        if not self.app_state.get("usuario"):
            self.mostrar_introducir_nombre()
            return

        if self.juego_lanzado:
            return

        self.juego_lanzado = True

        try:
            self.lanzar_juego()
        except Exception as e:
            QMessageBox.critical(
                self.launcher,
                "Error al iniciar el juego",
                str(e)
            )
            self.juego_lanzado = False

    def lanzar_juego(self):
        base_dir = get_base_dir()

        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")
        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "launched_by": "launcher",
                    "user": self.app_state.get("usuario")
                },
                f,
                indent=4
            )

        juego_exe = os.path.join(game_dir, "Juego.exe")

        if not os.path.exists(juego_exe):
            raise RuntimeError(
                f"No se encontró el ejecutable del juego en:\n{juego_exe}"
            )

        subprocess.Popen(
            [juego_exe],
            cwd=game_dir
        )

        # Cerrar launcher definitivamente
        self.launcher.close()
        sys.exit(0)
