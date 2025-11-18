from datetime import datetime

class Partida:
    def __init__(
        self,
        id_partida: str = None,
        nivel: int = 0,
        muertes_nivel: int = 0,
        puntuacion: int = 0,
        tiempo: int = 0,
        fecha: datetime = None,
        tipo: str = "guardado"
    ):
        self.id_partida = id_partida
        self.nivel = nivel
        self.muertes_nivel = muertes_nivel
        self.puntuacion = puntuacion
        self.tiempo = tiempo
        self.fecha = fecha
        self.tipo = tipo

    def __repr__(self):
        return f"<Partida id={self.id_partida} nivel={self.nivel} puntuacion={self.puntuacion}>"

    def to_dict(self):
        return {
            "nivel": self.nivel,
            "muertes_nivel": self.muertes_nivel,
            "puntuacion": self.puntuacion,
            "tiempo": self.tiempo,
            "fecha": self.fecha,
            "tipo": self.tipo
        }

    @staticmethod
    def from_dict(id_partida, data):
        return Partida(
            id_partida=id_partida,
            nivel=data.get("nivel", 0),
            muertes_nivel=data.get("muertes_nivel", 0),
            puntuacion=data.get("puntuacion", 0),
            tiempo=data.get("tiempo", 0),
            fecha=data.get("fecha"),
            tipo=data.get("tipo", "guardado")
        )
