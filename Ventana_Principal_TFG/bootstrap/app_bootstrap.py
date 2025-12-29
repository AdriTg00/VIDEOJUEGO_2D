from services.configuracion_service import ConfiguracionDAO

def init_persistence():
    dao = ConfiguracionDAO()
    dao._connect()
    dao._ensure_table()
