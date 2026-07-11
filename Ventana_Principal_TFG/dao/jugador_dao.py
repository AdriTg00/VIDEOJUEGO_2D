import requests
from config import API_BASE_URL


class JugadorDAO:
    def __init__(self):
        # Reutilizamos la sesión para keep-alive
        self.session = requests.Session()
        self.default_timeout = 60

    # -----------------------------
    # Crear jugador
    # -----------------------------
    def crear_usuario(self, nombre: str):
        resp = self.session.post(
            f"{API_BASE_URL}/jugadores/crear",
            json={"nombre": nombre},
            timeout=self.default_timeout
        )
        resp.raise_for_status()
        return resp.json()

    # -----------------------------
    # Obtener estadísticas globales
    # 🔑 CLAVE PARA EL WIDGET
    # -----------------------------
    def obtener_estadisticas(self, jugador_id: str):
        resp = self.session.get(
            f"{API_BASE_URL}/jugadores/{jugador_id}",
            timeout=self.default_timeout
        )

        if resp.status_code != 200:
            return None

        data = resp.json()

        # 🔑 Si el backend devuelve {} → tratamos como None
        if not data:
            return None

        return data
