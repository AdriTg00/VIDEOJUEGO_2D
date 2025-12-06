# model/jugador.py
from datetime import datetime

class Jugador:
    def __init__(self, nombre: str, fecha_creacion=None, es_admin=False,
                 tiempo_total: float = 0.0, puntuacion_total: int = 0, niveles_superados: int = 0):
        self.nombre = nombre
        self.fecha_creacion = fecha_creacion or datetime.utcnow()
        self.es_admin = es_admin

        # Nuevos atributos agregados acumulados
        self.tiempo_total = float(tiempo_total)        # en segundos (float)
        self.puntuacion_total = int(puntuacion_total)  # suma de puntuaciones
        self.niveles_superados = int(niveles_superados)

    def __repr__(self):
        return f"<Jugador nombre={self.nombre} total_punt={self.puntuacion_total} niveles={self.niveles_superados}>"

    def to_dict(self):
        return {
            "fecha_creacion": self.fecha_creacion,
            "es_admin": self.es_admin,
            "tiempo_total": self.tiempo_total,
            "puntuacion_total": self.puntuacion_total,
            "niveles_superados": self.niveles_superados,
        }

    @staticmethod
    def from_dict(nombre, data):
        return Jugador(
            nombre=nombre,
            fecha_creacion=data.get("fecha_creacion"),
            es_admin=data.get("es_admin", False),
            tiempo_total=data.get("tiempo_total", 0.0),
            puntuacion_total=data.get("puntuacion_total", 0),
            niveles_superados=data.get("niveles_superados", 0)
        )
