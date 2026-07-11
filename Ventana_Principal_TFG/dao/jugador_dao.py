import requests
from config import API_BASE_URL
from dao.local_cache import cache_jugador, obtener_jugador_cache


class JugadorDAO:
    def __init__(self):
        self.session = requests.Session()
        self.default_timeout = 15
    # Tiempo más corto para no bloquear la UI

    def crear_usuario(self, nombre: str):
        try:
            resp = self.session.post(
                f"{API_BASE_URL}/jugadores/crear",
                json={"nombre": nombre},
                timeout=self.default_timeout
            )
            resp.raise_for_status()
            data = resp.json()
            cache_jugador(data)
            return data
        except requests.RequestException:
            import uuid
            data = {"id": uuid.uuid4().hex, "nombre": nombre, "offline": True}
            cache_jugador(data)
            return data

    def obtener_estadisticas(self, jugador_id: str):
        try:
            resp = self.session.get(
                f"{API_BASE_URL}/jugadores/{jugador_id}",
                timeout=self.default_timeout
            )
            if resp.status_code == 200:
                data = resp.json()
                if data:
                    cache_jugador(data)
                    return data
        except requests.RequestException:
            pass
        return obtener_jugador_cache(jugador_id)
