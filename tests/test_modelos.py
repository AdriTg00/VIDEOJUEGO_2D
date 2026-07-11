import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "Ventana_Principal_TFG"))

from model.jugador import Jugador
from model.partida import Partida
from model.configuracion import Configuracion


def test_crear_jugador():
    j = Jugador(nombre="Test")
    assert j.nombre == "Test"
    assert j.puntuacion_total == 0
    assert j.niveles_superados == 0
    d = j.to_dict()
    assert d["es_admin"] is False


def test_crear_partida():
    p = Partida(nivel=2, puntuacion=100, tiempo=45.5, fecha="2025-01-01")
    assert p.nivel == 2
    assert p.puntuacion == 100
    assert p.fecha == "2025-01-01"
    d = p.to_dict()
    assert d["nivel"] == 2


def test_configuracion_defaults():
    c = Configuracion()
    assert c.volumen_musica == 50
    assert c.volumen_sfx == 50
    assert c.resolucion == "1920x1080"
    assert c.modo_pantalla == "ventana"


def test_partida_from_dict():
    data = {"nivel": 3, "puntuacion": 200, "muertes_nivel": 5, "tipo": "guardado"}
    p = Partida.from_dict("id-123", data)
    assert p.id_partida == "id-123"
    assert p.nivel == 3
    assert p.puntuacion == 200


if __name__ == "__main__":
    test_crear_jugador()
    test_crear_partida()
    test_configuracion_defaults()
    test_partida_from_dict()
    print("[OK] Todos los tests de modelos pasaron")
