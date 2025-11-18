import sqlite3
import os
from model.configuracion import Configuracion

DB_PATH = "configuracion.db"

class ConfiguracionDAO:

    def __init__(self):
        self._ensure_table()

    def _connect(self):
        return sqlite3.connect(DB_PATH)

    def _ensure_table(self):
        """Crea la tabla si no existe."""
        conn = self._connect()
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS configuracion (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                volumen_musica INTEGER,
                volumen_sfx INTEGER,
                resolucion TEXT,
                modo_pantalla TEXT
            )
        ''')
        conn.commit()
        conn.close()

    def obtener(self) -> Configuracion:
        conn = self._connect()
        cursor = conn.cursor()
        cursor.execute("SELECT volumen_musica, volumen_sfx, resolucion, modo_pantalla FROM configuracion LIMIT 1")
        row = cursor.fetchone()
        conn.close()

        if row is None:
            # No existe config → devolvemos default
            return Configuracion()

        return Configuracion(*row)

    def guardar(self, config: Configuracion):
        conn = self._connect()
        cursor = conn.cursor()

        cursor.execute("DELETE FROM configuracion")
        cursor.execute("""
            INSERT INTO configuracion (volumen_musica, volumen_sfx, resolucion, modo_pantalla)
            VALUES (?, ?, ?, ?)
        """, (
            config.volumen_musica,
            config.volumen_sfx,
            config.resolucion,
            config.modo_pantalla
        ))

        conn.commit()
        conn.close()
