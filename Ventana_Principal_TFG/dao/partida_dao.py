import requests
from config import API_BASE_URL

class PartidasDAO:
    def __init__(self):
        self.session = requests.Session()
        self.default_timeout = 25

    def obtener_partidas(self, nombre):
        r = self.session.get(
            f"{API_BASE_URL}/partidas/obtener",
            params={"jugador": nombre},
            timeout=self.default_timeout
        )
        r.raise_for_status()
        return r.json()

    def guardar_partida(self, nombre, data):
        r = self.session.post(
            f"{API_BASE_URL}/jugadores/{nombre}/partidas",
            json=data,
            timeout=self.default_timeout
        )
        r.raise_for_status()
        return r.json().get("id")

    def borrar_partida(self, nombre, id_partida):
        r = self.session.delete(
            f"{API_BASE_URL}/jugadores/{nombre}/partidas/{id_partida}",
            timeout=self.default_timeout
        )
        r.raise_for_status()
