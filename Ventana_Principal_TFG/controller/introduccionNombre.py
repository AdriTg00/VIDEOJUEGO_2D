from functools import partial
from PySide6.QtCore import Signal
from PySide6.QtWidgets import QWidget, QMessageBox
from views.introduccionNombre_ui import Ui_introduccionNombre
from translator import TRANSLATIONS


class introducirNombre(QWidget):
    partida_seleccionada = Signal(int)

    def __init__(self, app_state,  parent=None):
        super().__init__(parent)
        self.ui = Ui_introduccionNombre()
        self.app_state = app_state
        self.ui.setupUi(self)
        self.apply_language()

    def apply_language(self):
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]

        self.setWindowTitle(tr["intro_title"])
        self.ui.labelNombre.setText(tr["intro_label"])
        self.ui.iniciarPartida.setText(tr["intro_button"])
        self.ui.nombre.setPlaceholderText(tr["intro_placeholder"])
