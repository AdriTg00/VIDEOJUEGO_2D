from utils.paths import get_base_dir
import os
import json
import subprocess
from services.configuracion_service import ConfiguracionService


class GameLauncher:
    def __init__(self, session_manager):
        self.session = session_manager
        self.config_service = ConfiguracionService()
        self.juego_lanzado = False

    def lanzar(self, partida=None):
        if self.juego_lanzado:
            return
        self.juego_lanzado = True

        base_dir = get_base_dir()   # 🔑 AQUÍ ESTÁ LA CLAVE
        game_dir = os.path.join(base_dir, "game")
        runtime_dir = os.path.join(base_dir, "runtime")
        os.makedirs(runtime_dir, exist_ok=True)

        juego_exe = os.path.join(game_dir, "Juego.exe")
        if not os.path.exists(juego_exe):
            raise FileNotFoundError(f"No se encuentra el ejecutable: {juego_exe}")

        token_path = os.path.join(runtime_dir, "launch_token.json")

        config = self.config_service.cargar_configuracion()

        token = {
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
            token["load_partida"] = partida

        with open(token_path, "w", encoding="utf-8") as f:
            json.dump(token, f, indent=4)

        subprocess.Popen([juego_exe], cwd=game_dir)
