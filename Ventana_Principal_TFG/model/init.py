from model.configuracion import get_connection as get_config_connection


def inicializar_bases():
    """
    Inicializa todas las bases de datos necesarias para el launcher.
    Crea las tablas si no existen.
    """
    print("Inicializando bases de datos...")

    # Base de datos de configuración
    conn = get_config_connection()
    conn.close()

    # Base de datos de jugador
    inicializar_jugador_bd()

    print("✅ Bases de datos listas.")