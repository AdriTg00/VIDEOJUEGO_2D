from firebase_admin import firestore
from model.partida import Partida

db = firestore.client()

class PartidasDAO:

    def guardar_partida(self, nombre_jugador: str, partida: Partida) -> str:
        """Guarda una partida en la subcolección del jugador."""
        ref = db.collection("jugadores").document(nombre_jugador).collection("partidas").document()

        ref.set(partida.to_dict())
        return ref.id

    def obtener_partidas(self, nombre_jugador: str) -> list[Partida]:
        """Devuelve todas las partidas del jugador."""
        ref = db.collection("jugadores").document(nombre_jugador).collection("partidas")
        docs = ref.stream()

        partidas = []

        for doc in docs:
            partidas.append(Partida.from_dict(doc.id, doc.to_dict()))

        return partidas

    def eliminar_partida(self, nombre_jugador: str, id_partida: str):
        """Elimina una partida concreta."""
        db.collection("jugadores").document(nombre_jugador).collection("partidas").document(id_partida).delete()
