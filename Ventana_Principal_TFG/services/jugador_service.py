from dao.jugador_dao import JugadorDAO
from utils.paths import get_base_dir
import json
import os


class JugadorService:
    def __init__(self, dao: JugadorDAO = None):
        self.dao = dao if dao is not None else JugadorDAO()

    def _local_path(self):
        return os.path.join(get_base_dir(), "usuario_local.json")

    def crear_usuario(self, nombre):
        datos = self.dao.crear_usuario(nombre)
        self.guardar_local(datos)
        return datos

    def obtener_estadisticas_jugador(self, jugador_id: str):
        stats = self.dao.obtener_estadisticas(jugador_id)
        if not stats:
            return None
        return stats

    def existe_local(self):
        return os.path.exists(self._local_path())

    def cargar_local(self):
        with open(self._local_path(), "r", encoding="utf-8") as f:
            return json.load(f)

    def guardar_local(self, datos):
        with open(self._local_path(), "w", encoding="utf-8") as f:
            json.dump(datos, f, indent=4)
