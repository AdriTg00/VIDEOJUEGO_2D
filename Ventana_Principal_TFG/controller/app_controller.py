from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre
from services.configuracion_service import ConfiguracionService


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


def log_to_file(msg: str):
    try:
        base_dir = get_base_dir()
        log_path = os.path.join(base_dir, "launcher.log")
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(msg + "\n")
    except Exception:
        pass


# =========================================================
# CONTROLADOR PRINCIPAL
# =========================================================

class AppController:
    def __init__(self):
        log_to_file("=== ARRANQUE DEL LAUNCHER ===")

        # -----------------------------
        # Estado global mínimo
        # -----------------------------
        self.app_state = {
            "language": "Español",
            "usuario": None
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
        self.configuracion_service = ConfiguracionService()


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

        self.carg_partidas.partida_seleccionada.connect(
            self._on_partida_seleccionada
        )

        # -----------------------------
        # Arranque
        # -----------------------------
        self._decidir_pantalla_inicial()


    # =====================================================
    # USUARIO
    # =====================================================

    def _decidir_pantalla_inicial(self):
        if self.app_state["usuario"]:
            log_to_file("Usuario detectado, mostrando launcher")
            self.mostrar_launcher()
        else:
            log_to_file("No hay usuario, mostrando introducción de nombre")
            self.mostrar_introducir_nombre()


    def _cargar_usuario_local(self):
        user_file = get_user_file()
        if not os.path.exists(user_file):
            log_to_file("No existe usuario_local.json")
            return

        try:
            with open(user_file, "r", encoding="utf-8") as f:
                datos = json.load(f)
            self.app_state["usuario"] = datos.get("id")
            log_to_file(f"Usuario cargado: {self.app_state['usuario']}")
        except Exception as e:
            log_to_file(f"Error leyendo usuario_local.json: {e}")


    def _on_nombre_validado(self, user_id):
        log_to_file(f"Nombre validado: {user_id}")
        self.app_state["usuario"] = user_id

        try:
            with open(get_user_file(), "w", encoding="utf-8") as f:
                json.dump({"id": user_id}, f, indent=4)
        except Exception as e:
            log_to_file(f"Error guardando usuario_local.json: {e}")

        self.mostrar_launcher()


    # =====================================================
    # VENTANAS
    # =====================================================

    def mostrar_launcher(self):
        self.introducir_nombre.hide()
        self.launcher.show()
        self.launcher.raise_()
        self.launcher.activateWindow()


    def mostrar_introducir_nombre(self):
        self.introducir_nombre.setWindowModality(Qt.ApplicationModal)
        self.introducir_nombre.show()


    def mostrar_partidas_guardadas(self):
        log_to_file("Abriendo ventana de partidas guardadas")
        self.carg_partidas.setWindowModality(Qt.ApplicationModal)
        self.carg_partidas.show()


    def mostrar_configuracion(self):
        self.config_window.setWindowModality(Qt.ApplicationModal)
        self.config_window.show()


    # =====================================================
    # ACCIONES
    # =====================================================

    def abrir_nueva_partida(self):
        if not self.app_state["usuario"]:
            self.mostrar_introducir_nombre()
            return

        if self.juego_lanzado:
            log_to_file("Intento de nueva partida ignorado (ya lanzado)")
            return

        log_to_file("🔥 ACCIÓN: Nueva partida")
        self.juego_lanzado = True

        try:
            self._lanzar_juego_nuevo()
        except Exception as e:
            self.juego_lanzado = False
            QMessageBox.critical(self.launcher, "Error", str(e))


    def _on_partida_seleccionada(self, partida: dict):
        log_to_file(f"📦 PARTIDA SELECCIONADA: {partida}")

        if self.juego_lanzado:
            log_to_file("Carga ignorada (juego ya lanzado)")
            return

        if not partida or "id" not in partida:
            QMessageBox.critical(self.launcher, "Error", "Partida no válida")
            return

        self._lanzar_juego_con_partida(partida)


    # =====================================================
    # LANZAR JUEGO
    # =====================================================

    def _lanzar_juego_con_partida(self, partida: dict):
        self.juego_lanzado = True
        log_to_file(f"🟢 LANZANDO PARTIDA GUARDADA: {partida.get('id')}")

        base_dir = get_base_dir()
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")
        log_to_file(f"📍 RUTA TOKEN (CARGA): {token_path}")

        # 🔑 CARGAR CONFIGURACIÓN
        config = self.configuracion_service.cargar_configuracion()

        if not config:
            log_to_file("⚠ Configuración NULL, usando valores por defecto")
        else:
            log_to_file(
                "⚙ Configuración cargada: "
                f"musica={config.volumen_musica}, "
                f"sfx={config.volumen_sfx}, "
                f"res={config.resolucion}, "
                f"modo={config.modo_pantalla}"
            )

        token_data = {
            "launched_by": "launcher",
            "user": self.app_state["usuario"],
            "load_partida": partida,
            "configuracion": {
                "volumen_musica": config.volumen_musica,
                "volumen_sfx": config.volumen_sfx,
                "resolucion": config.resolucion,
                "modo_pantalla": config.modo_pantalla
            }
        }

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        log_to_file("📄 TOKEN FINAL (CARGA):")
        log_to_file(json.dumps(token_data, indent=2))

        juego_exe = os.path.join(game_dir, "Juego.exe")
        log_to_file(f"🎮 Ejecutando juego: {juego_exe}")

        subprocess.Popen([juego_exe], cwd=game_dir)
        self.launcher.close()



    def _lanzar_juego_nuevo(self):
        log_to_file("🔥 LANZANDO NUEVA PARTIDA")

        base_dir = get_base_dir()
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")
        log_to_file(f"📍 RUTA TOKEN (NUEVA): {token_path}")

        # 🔑 CARGAR CONFIGURACIÓN
        config = self.configuracion_service.cargar_configuracion()

        if not config:
            log_to_file("⚠ Configuración NULL, usando valores por defecto")
        else:
            log_to_file(
                "⚙ Configuración cargada: "
                f"musica={config.volumen_musica}, "
                f"sfx={config.volumen_sfx}, "
                f"res={config.resolucion}, "
                f"modo={config.modo_pantalla}"
            )

        token_data = {
            "launched_by": "launcher",
            "user": self.app_state["usuario"],
            "configuracion": {
                "volumen_musica": config.volumen_musica,
                "volumen_sfx": config.volumen_sfx,
                "resolucion": config.resolucion,
                "modo_pantalla": config.modo_pantalla
            }
        }

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        log_to_file("📄 TOKEN FINAL (NUEVA):")
        log_to_file(json.dumps(token_data, indent=2))

        juego_exe = os.path.join(game_dir, "Juego.exe")
        log_to_file(f"🎮 Ejecutando juego: {juego_exe}")

        subprocess.Popen([juego_exe], cwd=game_dir)
        self.launcher.close()


