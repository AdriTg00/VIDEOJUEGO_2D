import sqlite3
import json
import os
from datetime import datetime

DB_PATH = "configuracion.db"


def _connect():
    return sqlite3.connect(DB_PATH)


def _ensure_tables():
    conn = _connect()
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS cache_jugadores (
            id TEXT PRIMARY KEY,
            nombre TEXT,
            fecha_creacion TEXT,
            datos_json TEXT
        )
    """)
    c.execute("""
        CREATE TABLE IF NOT EXISTS cache_partidas (
            id TEXT PRIMARY KEY,
            jugador_id TEXT,
            nivel INTEGER,
            muertes_nivel INTEGER,
            puntuacion INTEGER,
            tiempo REAL,
            pos_x REAL,
            pos_y REAL,
            tipo TEXT,
            fecha TEXT,
            datos_json TEXT
        )
    """)
    conn.commit()
    conn.close()


def cache_jugador(data: dict):
    _ensure_tables()
    conn = _connect()
    c = conn.cursor()
    c.execute("""
        INSERT OR REPLACE INTO cache_jugadores (id, nombre, fecha_creacion, datos_json)
        VALUES (?, ?, ?, ?)
    """, (data.get("id"), data.get("nombre"), str(datetime.utcnow()), json.dumps(data)))
    conn.commit()
    conn.close()
    return data


def obtener_jugador_cache(jugador_id: str) -> dict | None:
    _ensure_tables()
    conn = _connect()
    c = conn.cursor()
    c.execute("SELECT datos_json FROM cache_jugadores WHERE id = ?", (jugador_id,))
    row = c.fetchone()
    conn.close()
    return json.loads(row[0]) if row else None


def cache_partidas(jugador_id: str, partidas: list[dict]):
    _ensure_tables()
    conn = _connect()
    c = conn.cursor()
    c.execute("DELETE FROM cache_partidas WHERE jugador_id = ?", (jugador_id,))
    for p in partidas:
        pid = p.get("id") or str(hash(str(p)))
        c.execute("""
            INSERT OR REPLACE INTO cache_partidas
            (id, jugador_id, nivel, muertes_nivel, puntuacion, tiempo, pos_x, pos_y, tipo, fecha, datos_json)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            pid, jugador_id,
            p.get("nivel"), p.get("muertes_nivel"), p.get("puntuacion"),
            p.get("tiempo"), p.get("pos_x", 0.0), p.get("pos_y", 0.0),
            p.get("tipo", "guardado"), p.get("fecha", ""),
            json.dumps(p)
        ))
    conn.commit()
    conn.close()


def obtener_partidas_cache(jugador_id: str) -> list[dict]:
    _ensure_tables()
    conn = _connect()
    c = conn.cursor()
    c.execute("SELECT datos_json FROM cache_partidas WHERE jugador_id = ? ORDER BY fecha DESC", (jugador_id,))
    rows = c.fetchall()
    conn.close()
    return [json.loads(r[0]) for r in rows]


def guardar_partida_cache(jugador_id: str, partida: dict) -> str:
    _ensure_tables()
    pid = partida.get("id") or str(abs(hash(str(partida) + str(datetime.utcnow()))))
    partida["id"] = pid
    conn = _connect()
    c = conn.cursor()
    c.execute("""
        INSERT OR REPLACE INTO cache_partidas
        (id, jugador_id, nivel, muertes_nivel, puntuacion, tiempo, pos_x, pos_y, tipo, fecha, datos_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        pid, jugador_id,
        partida.get("nivel"), partida.get("muertes_nivel"), partida.get("puntuacion"),
        partida.get("tiempo"), partida.get("pos_x", 0.0), partida.get("pos_y", 0.0),
        partida.get("tipo", "guardado"), partida.get("fecha", ""),
        json.dumps(partida)
    ))
    conn.commit()
    conn.close()
    return pid


def borrar_partida_cache(id_partida: str):
    _ensure_tables()
    conn = _connect()
    c = conn.cursor()
    c.execute("DELETE FROM cache_partidas WHERE id = ?", (id_partida,))
    conn.commit()
    conn.close()
