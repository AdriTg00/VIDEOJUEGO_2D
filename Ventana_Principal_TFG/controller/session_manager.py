import os
import json
import sys


class SessionManager:
    def __init__(self):
        self.state = {
            "language": "Español",
            "usuario": None
        }
        self._cargar_usuario_local()

    # -----------------------------
    # Paths
    # -----------------------------
    def _base_dir(self):
        if getattr(sys, "frozen", False):
            return os.path.dirname(sys.executable)
        return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

    def _user_file(self):
        return os.path.join(self._base_dir(), "usuario_local.json")

    # -----------------------------
    # Usuario local
    # -----------------------------
    def _cargar_usuario_local(self):
        if not os.path.exists(self._user_file()):
            return

        try:
            with open(self._user_file(), "r", encoding="utf-8") as f:
                datos = json.load(f)
            self.state["usuario"] = datos.get("id")
        except Exception:
            pass

    def guardar_usuario(self, user_id: str):
        self.state["usuario"] = user_id
        try:
            with open(self._user_file(), "w", encoding="utf-8") as f:
                json.dump({"id": user_id}, f, indent=4)
        except Exception:
            pass
