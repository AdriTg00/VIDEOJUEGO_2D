import os
import json
import subprocess
from services.configuracion_service import ConfiguracionService


class GameLauncher:
    def __init__(self, session_manager):
        self.session = session_manager
        self.config_service = ConfiguracionService()
        self.juego_lanzado = False

    def _base_dir(self):
        return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

    def lanzar_nueva(self):
        self._lanzar()

    def lanzar_con_partida(self, partida: dict):
        self._lanzar(partida)

    # -----------------------------
    # Core
    # -----------------------------
    def _lanzar(self, partida: dict | None = None):
        if self.juego_lanzado:
            return

        self.juego_lanzado = True

        base_dir = self._base_dir()
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        token_path = os.path.join(runtime_dir, "launch_token.json")

        config = self.config_service.cargar_configuracion()

        token_data = {
            "launched_by": "launcher",
            "user": self.session.state["usuario"],
            "configuracion": {
                "volumen_musica": config.volumen_musica,
                "volumen_sfx": config.volumen_sfx,
                "resolucion": config.resolucion,
                "modo_pantalla": config.modo_pantalla
            }
        }

        if partida:
            token_data["load_partida"] = partida

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token_data, f, indent=4)

        juego_exe = os.path.join(game_dir, "Juego.exe")
        subprocess.Popen([juego_exe], cwd=game_dir)
