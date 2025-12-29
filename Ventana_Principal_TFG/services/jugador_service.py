from dao.jugador_dao import JugadorDAO
import json
import os


class JugadorService:
    LOCAL_FILE = "usuario_local.json"

    def __init__(self, dao: JugadorDAO = None):
        self.dao = dao if dao is not None else JugadorDAO()

    # -----------------------------
    # Crear jugador (login)
    # -----------------------------
    def crear_usuario(self, nombre):
        datos = self.dao.crear_usuario(nombre)
        self.guardar_local(datos)
        return datos

    # -----------------------------
    # Obtener estadísticas (widget)
    # 🔑 CLAVE
    # -----------------------------
    def obtener_estadisticas_jugador(self, jugador_id: str):
        """
        Devuelve un dict con las estadísticas del jugador
        o None si no existen
        """
        stats = self.dao.obtener_estadisticas(jugador_id)

        # 🔍 DEBUG defensivo
        if not stats:
            return None

        return stats


    # -----------------------------
    # Local storage
    # -----------------------------
    def existe_local(self):
        return os.path.exists(self.LOCAL_FILE)

    def cargar_local(self):
        with open(self.LOCAL_FILE, "r", encoding="utf-8") as f:
            return json.load(f)

    def guardar_local(self, datos):
        with open(self.LOCAL_FILE, "w", encoding="utf-8") as f:
            json.dump(datos, f, indent=4)
