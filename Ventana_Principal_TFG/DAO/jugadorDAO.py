# jugadorDAO.py (REEMPLAZAR/ACTUALIZAR)
import requests

BASE_URL = "https://flask-server-9ymz.onrender.com"

class JugadorDAO:
    def __init__(self):
        # Reutilizamos la sesión para keep-alive y menor latencia
        self.session = requests.Session()
        # Timeout por defecto para todas las peticiones (segundos)
        self.default_timeout = 25

    def crear_usuario(self, nombre: str):
        resp = self.session.post(
            f"{BASE_URL}/jugadores/crear",
            json={"nombre": nombre},
            timeout=self.default_timeout
        )
        resp.raise_for_status()
        # Si tu backend devuelve algo particular, ajusta aquí
        return resp.json()

    def obtener_partidas(self, jugador_id):
        r = self.session.get(
            f"{BASE_URL}/partidas/{jugador_id}",
            timeout=self.default_timeout
        )
        r.raise_for_status()
        return r.json()

