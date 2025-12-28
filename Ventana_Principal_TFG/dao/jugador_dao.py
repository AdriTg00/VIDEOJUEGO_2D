import requests

BASE_URL = "https://flask-server-9ymz.onrender.com"


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
            f"{BASE_URL}/jugadores/crear",
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
            f"{BASE_URL}/jugadores/obtener",
            params={"jugador_id": jugador_id},
            timeout=self.default_timeout
        )

        if resp.status_code == 404:
            return None

        resp.raise_for_status()
        return resp.json()
