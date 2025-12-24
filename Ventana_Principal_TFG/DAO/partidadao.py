# partidadao.py (REEMPLAZAR/ACTUALIZAR)
import requests

BASE_URL = "https://flask-server-9ymz.onrender.com"

class PartidasDAO:
    def __init__(self):
        self.session = requests.Session()
        self.default_timeout = 25

    def obtener_partidas(self, nombre):
        r = self.session.get( f"{BASE_URL}/partidas/obtener",params={"jugador": nombre},timeout=self.default_timeout)
        r.raise_for_status()
        return r.json()

    def guardar_partida(self, nombre, data):
        r = self.session.post(f"{BASE_URL}/jugadores/{nombre}/partidas", json=data, timeout=self.default_timeout)
        r.raise_for_status()
        return r.json().get("id")

    def borrar_partida(self, nombre, id_partida):
        r = self.session.delete(f"{BASE_URL}/jugadores/{nombre}/partidas/{id_partida}", timeout=self.default_timeout)
        r.raise_for_status()
