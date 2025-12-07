import requests

BASE_URL = "https://flask-server-9ymz.onrender.com"

class JugadorDAO:
       
    def crear_usuario(self, nombre: str):
    
        resp = requests.post(
            f"{BASE_URL}/jugadores/crear",
            json={"nombre": nombre}
        )
        return resp.json()

    def obtener(self, user_id: str):
        """
        Obtiene datos del usuario por ID único.
        """
        resp = requests.get(
            f"{BASE_URL}/jugadores/obtener",
            params={"id": user_id}
        )
        return resp.json()

