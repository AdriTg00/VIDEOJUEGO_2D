from functools import partial
from PySide6.QtCore import Signal
from PySide6.QtWidgets import QWidget, QMessageBox
from views.partidasGuardadas_ui import Ui_partidaGuardada
from translator import TRANSLATIONS


class cargar(QWidget):
    partida_seleccionada = Signal(int)

    def __init__(self, app_state,  parent=None):
        super().__init__(parent)
        self.ui = Ui_partidaGuardada()
        self.app_state = app_state
        self.ui.setupUi(self)
        self.apply_language()
    

    def _safe_disconnect(self, widget):
        """Intenta desconectar todas las conexiones en clicked para evitar duplicados."""
        try:
            widget.clicked.disconnect()
        except Exception:
            pass
    
    def apply_language(self):
        """Actualiza todos los textos de la interfaz según el idioma actual."""
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]

        # Título y etiqueta principal
        self.setWindowTitle(tr.get("saved_games", "Partidas guardadas:"))
        self.ui.partidasGuardadas.setText(tr.get("saved_games", "Partidas guardadas:"))

