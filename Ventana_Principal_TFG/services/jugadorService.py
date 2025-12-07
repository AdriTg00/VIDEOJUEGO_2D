from DAO.jugadorDAO import JugadorDAO
import json
import os


class JugadorService:
    LOCAL_FILE = "usuario_local.json"

    def __init__(self, dao):
        self.dao = JugadorDAO()
        self.dao = dao

    def validar_y_crear(self, nombre: str) -> bool:
        """
        Devuelve True si el jugador es válido y se crea.
        Devuelve False si ya existe.
        """
        if self.dao.existe(nombre):
            return False
        
        # Crear jugador en Firebase
        self.dao.crear(nombre)
        return True
        

    def existe_local(self):
        return os.path.exists(self.LOCAL_FILE)

    def cargar_local(self):
        with open(self.LOCAL_FILE, "r") as f:
            return json.load(f)

    def guardar_local(self, datos):
        with open(self.LOCAL_FILE, "w") as f:
            json.dump(datos, f)

    def crear_usuario(self, nombre):
        datos = self.dao.crear_usuario(nombre)
        self.guardar_local(datos)
        return datos
