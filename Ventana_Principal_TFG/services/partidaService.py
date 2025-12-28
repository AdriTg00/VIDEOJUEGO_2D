from dao.partida_dao import PartidasDAO
from model.partida import Partida
from datetime import datetime

class PartidasService:

    def __init__(self):
        self.dao = PartidasDAO()

    def guardar_partida(self, nombre_jugador: str, partida: Partida) -> str:
        partida.fecha = datetime.now()
        return self.dao.guardar_partida(nombre_jugador, partida)

    def obtener_partidas(self, nombre_jugador: str) -> list[Partida]:
        return self.dao.obtener_partidas(nombre_jugador)

    def eliminar_partida(self, nombre_jugador: str, id_partida: str):
        self.dao.borrar_partida(nombre_jugador, id_partida)
