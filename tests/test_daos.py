import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "Ventana_Principal_TFG"))

from unittest.mock import patch, MagicMock
from requests.exceptions import ConnectionError as RequestsConnectionError
from dao.jugador_dao import JugadorDAO
from dao.partida_dao import PartidasDAO


@patch("dao.jugador_dao.requests.Session")
def test_jugador_dao_crear_usuario_offline(mock_session_cls):
    mock_session = MagicMock()
    mock_session_cls.return_value = mock_session
    mock_session.post.side_effect = RequestsConnectionError("Servidor caído")

    dao = JugadorDAO()
    resultado = dao.crear_usuario("Test")

    assert resultado is not None
    assert resultado.get("nombre") == "Test"
    assert resultado.get("offline") is True
    assert resultado.get("id") is not None


@patch("dao.jugador_dao.requests.Session")
def test_jugador_dao_crear_usuario_online(mock_session_cls):
    mock_session = MagicMock()
    mock_session_cls.return_value = mock_session
    mock_resp = MagicMock()
    mock_resp.json.return_value = {"id": "abc123", "nombre": "Test"}
    mock_session.post.return_value = mock_resp

    dao = JugadorDAO()
    resultado = dao.crear_usuario("Test")

    assert resultado == {"id": "abc123", "nombre": "Test"}


@patch("dao.partida_dao.requests.Session")
def test_partidas_dao_offline(mock_session_cls):
    mock_session = MagicMock()
    mock_session_cls.return_value = mock_session
    mock_session.get.side_effect = RequestsConnectionError("Servidor caído")

    dao = PartidasDAO()
    resultado = dao.obtener_partidas("test_user")

    assert resultado == []


if __name__ == "__main__":
    test_jugador_dao_crear_usuario_offline()
    test_jugador_dao_crear_usuario_online()
    test_partidas_dao_offline()
    print("[OK] Todos los tests de DAOs pasaron")
