from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre
from services.partidaService import PartidasService

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
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def get_user_file():
    return os.path.join(get_base_dir(), "usuario_local.json")


# =========================================================
# CONTROLADOR PRINCIPAL
# =========================================================

class AppController:
    def __init__(self):
        # -----------------------------
        # Estado global mínimo
        # -----------------------------
        self.app_state = {
            "language": "Español",
            "usuario": None  # jugador_id
        }

        self.juego_lanzado = False

        # -----------------------------
        # Usuario local
        # -----------------------------
        self._cargar_usuario_local()

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

        # 🔑 CLAVE: ID de partida seleccionada
        self.carg_partidas.partida_seleccionada.connect(
            self._on_partida_seleccionada
        )

        # -----------------------------
        # Arranque
        # -----------------------------
        self._decidir_pantalla_inicial()

    # =========================================================
    # USUARIO
    # =========================================================

    def _decidir_pantalla_inicial(self):
        if self.app_state["usuario"]:
            self.mostrar_launcher()
        else:
            self.mostrar_introducir_nombre()

    def _cargar_usuario_local(self):
        user_file = get_user_file()
        if not os.path.exists(user_file):
            return

        try:
            with open(user_file, "r", encoding="utf-8") as f:
                datos = json.load(f)
            self.app_state["usuario"] = datos.get("id")
        except Exception as e:
            print("[AppController] Error leyendo usuario_local.json:", e)

    def _on_nombre_validado(self, user_id):
        self.app_state["usuario"] = user_id

        try:
            with open(get_user_file(), "w", encoding="utf-8") as f:
                json.dump({"id": user_id}, f, indent=4)
        except Exception as e:
            print("[AppController] Error guardando usuario_local.json:", e)

        self.mostrar_launcher()

    # =========================================================
    # VENTANAS
    # =========================================================

    def mostrar_launcher(self):
        self.introducir_nombre.hide()
        self.launcher.show()
        self.launcher.raise_()
        self.launcher.activateWindow()
        

    def mostrar_introducir_nombre(self):
        self.introducir_nombre.setWindowModality(Qt.ApplicationModal)
        self.introducir_nombre.show()

    def mostrar_partidas_guardadas(self):
        self.carg_partidas.setWindowModality(Qt.ApplicationModal)
        self.carg_partidas.show()

    def mostrar_configuracion(self):
        self.config_window.setWindowModality(Qt.ApplicationModal)
        self.config_window.show()

    # =========================================================
    # ACCIONES
    # =========================================================

    def abrir_nueva_partida(self):
        if not self.app_state["usuario"]:
            self.mostrar_introducir_nombre()
            return

        if self.juego_lanzado:
            return

        self.juego_lanzado = True
        try:
            self._lanzar_juego()
        except Exception as e:
            QMessageBox.critical(self.launcher, "Error", str(e))
            self.juego_lanzado = False

    def _on_partida_seleccionada(self, partida_id: str):
        jugador = self.app_state["usuario"]
        service = PartidasService()

        try:
            partidas = service.obtener_partidas(jugador)
        except Exception as e:
            QMessageBox.critical(self.launcher, "Error", str(e))
            return

        partida = next((p for p in partidas if p.get("id") == partida_id), None)

        print("[DEBUG] Partida seleccionada:", partida)

        if not partida:
            QMessageBox.critical(self.launcher, "Error", "Partida no encontrada")
            return

        self._lanzar_juego_con_partida(partida)

    # =========================================================
    # LANZAR JUEGO
    # =========================================================

    def _lanzar_juego_con_partida(self, partida: dict):
        base_dir = get_base_dir()
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")

        token_data = {
            "launched_by": "launcher",
            "user": self.app_state["usuario"],
            "load_partida": partida
        }

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        print("[LAUNCHER] Token creado:", token_data)

        juego_exe = os.path.join(game_dir, "Juego.exe")
        if not os.path.exists(juego_exe):
            raise RuntimeError(f"No se encontró el juego en:\n{juego_exe}")

        subprocess.Popen([juego_exe], cwd=game_dir)
        self.launcher.close()

    def _lanzar_juego(self):
        base_dir = get_base_dir()
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")

        token_data = {
            "launched_by": "launcher",
            "user": self.app_state["usuario"]
        }

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        juego_exe = os.path.join(game_dir, "Juego.exe")
        if not os.path.exists(juego_exe):
            raise RuntimeError(f"No se encontró el juego en:\n{juego_exe}")

        subprocess.Popen([juego_exe], cwd=game_dir)
        self.launcher.close()
