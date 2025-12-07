import requests

BASE_URL = "https://flask-server-9ymz.onrender.com"

class PartidasDAO:

    

    def obtener_partidas(self, nombre):
        r = requests.get(f"{BASE_URL}/jugadores/{nombre}/partidas")
        return r.json()

    def guardar_partida(self, nombre, data):
        r = requests.post(f"{BASE_URL}/jugadores/{nombre}/partidas", json=data)
        return r.json()["id"]

    def borrar_partida(self, nombre, id_partida):
        requests.delete(f"{BASE_URL}/jugadores/{nombre}/partidas/{id_partida}")
