class Jugador:
    def __init__(self, nombre: str, fecha_creacion=None, es_admin=False):
        self.nombre = nombre
        self.fecha_creacion = fecha_creacion
        self.es_admin = es_admin

    def __repr__(self):
        return f"<Jugador nombre={self.nombre} admin={self.es_admin}>"

    def to_dict(self):
        return {
            "fecha_creacion": self.fecha_creacion,
            "es_admin": self.es_admin
        }

    @staticmethod
    def from_dict(nombre, data):
        return Jugador(
            nombre=nombre,
            fecha_creacion=data.get("fecha_creacion"),
            es_admin=data.get("es_admin", False)
        )
