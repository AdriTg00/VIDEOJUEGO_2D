from model.configuracion import Configuracion
from dao.configuracion_dao import ConfiguracionDAO

class ConfiguracionService:

    def __init__(self):
        self.dao = ConfiguracionDAO()

    def cargar_configuracion(self) -> Configuracion:
        return self.dao.obtener()

    def guardar_configuracion(self, config: Configuracion):
        # Aquí podrías validar rangos:
        # if not 0 <= config.volumen_musica <= 100: ...
        self.dao.guardar(config)
