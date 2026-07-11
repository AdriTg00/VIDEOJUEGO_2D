import requests
from config import API_BASE_URL
from dao.local_cache import (
    cache_partidas, obtener_partidas_cache,
    guardar_partida_cache, borrar_partida_cache
)


class PartidasDAO:
    def __init__(self):
        self.session = requests.Session()
        self.default_timeout = 15

    def obtener_partidas(self, nombre):
        try:
            r = self.session.get(
                f"{API_BASE_URL}/partidas/obtener",
                params={"jugador": nombre},
                timeout=self.default_timeout
            )
            r.raise_for_status()
            data = r.json()
            cache_partidas(nombre, data)
            return data
        except requests.RequestException:
            return obtener_partidas_cache(nombre)

    def guardar_partida(self, nombre, data):
        try:
            r = self.session.post(
                f"{API_BASE_URL}/jugadores/{nombre}/partidas",
                json=data,
                timeout=self.default_timeout
            )
            r.raise_for_status()
            pid = r.json().get("id")
            data["id"] = pid
            guardar_partida_cache(nombre, data)
            return pid
        except requests.RequestException:
            return guardar_partida_cache(nombre, data)

    def borrar_partida(self, nombre, id_partida):
        try:
            r = self.session.delete(
                f"{API_BASE_URL}/jugadores/{nombre}/partidas/{id_partida}",
                timeout=self.default_timeout
            )
            r.raise_for_status()
        except requests.RequestException:
            pass
        borrar_partida_cache(id_partida)
