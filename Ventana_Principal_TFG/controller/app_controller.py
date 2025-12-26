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
    else:
        return os.path.abspath(
            os.path.join(os.path.dirname(__file__), "..", "..")
        )


def get_user_file():
    return os.path.join(get_base_dir(), "usuario_local.json")


# =========================================================
# CONTROLADOR PRINCIPAL
# =========================================================

class AppController:
    def __init__(self):
        # -----------------------------
        # Estado global
        # -----------------------------
        self.app_state = {
            "language": "Español",
            "usuario": None
        }

        self.user_id = None
        self.juego_lanzado = False

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

        # CLAVE: conectar selección de partida
        self.carg_partidas.partida_seleccionada.connect(
            self._on_partida_seleccionada
        )

        # -----------------------------
        # Arranque
        # -----------------------------
        self.comprobar_usuario_local()

    # =========================================================
    # USUARIO
    # =========================================================

    def comprobar_usuario_local(self):
        user_file = get_user_file()

        if os.path.exists(user_file):
            try:
                with open(user_file, "r", encoding="utf-8") as f:
                    datos = json.load(f)

                user_id = datos.get("id")
                if user_id:
                    self.user_id = user_id
                    self.app_state["usuario"] = user_id
                    self.mostrar_launcher()
                    return
            except Exception as e:
                print("[AppController] Error leyendo usuario_local.json:", e)

        self.mostrar_introducir_nombre()

    def _on_nombre_validado(self, user_id):
        self.user_id = user_id
        self.app_state["usuario"] = user_id

        try:
            with open(get_user_file(), "w", encoding="utf-8") as f:
                json.dump({"id": user_id}, f, indent=4)
        except Exception as e:
            print("[AppController] Error guardando usuario_local.json:", e)

        self.mostrar_launcher()

    def _cargar_usuario_local(self):
        user_file = get_user_file()

        if os.path.exists(user_file):
            try:
                with open(user_file, "r", encoding="utf-8") as f:
                    datos = json.load(f)

                user_id = datos.get("id")
                self.app_state["usuario"] = user_id
                self.user_id = user_id
            except Exception:
                pass

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
        if not self.app_state.get("usuario"):
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

    def _on_partida_seleccionada(self, partida_id):
       

        service = PartidasService()
        jugador = self.app_state["usuario"]

        try:
            partidas = service.obtener_partidas(jugador)
            partida = next(p for p in partidas if p["id"] == partida_id)
        except Exception as e:
            QMessageBox.critical(self.launcher, "Error", str(e))
            return

        self._lanzar_juego_con_partida(partida)

    # =========================================================
    # LANZAR JUEGO
    # =========================================================
    def _lanzar_juego_con_partida(self, partida):
        base_dir = get_base_dir()

        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")
        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "launched_by": "launcher",
                    "user": self.app_state["usuario"],
                    "load_partida": partida
                },
                f,
                indent=4
            )

        juego_exe = os.path.join(game_dir, "Juego.exe")
        #Prueba
        print("[LAUNCHER] Lanzando juego")
        print("[LAUNCHER] Usuario:", self.app_state["usuario"])
        print("[LAUNCHER] Load partida:", partida)
        print("[LAUNCHER] Token path:", token_path)

        subprocess.Popen([juego_exe], cwd=game_dir)

        self.launcher.close()

    

    def _lanzar_juego(self, partida_id=None):
        base_dir = get_base_dir()

        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_data = {
            "launched_by": "launcher",
            "user": self.app_state["usuario"]
        }

        if partida_id:
            token_data["load_partida_id"] = partida_id

        token_path = os.path.join(runtime_dir, "launch_token.json")
        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        juego_exe = os.path.join(game_dir, "Juego.exe")
        if not os.path.exists(juego_exe):
            raise RuntimeError(f"No se encontró el juego en:\n{juego_exe}")

        subprocess.Popen([juego_exe], cwd=game_dir)

        self.launcher.close()
