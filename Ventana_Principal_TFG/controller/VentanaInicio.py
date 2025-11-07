from PySide6.QtCore import Signal
from PySide6.QtWidgets import QMainWindow
from views.VentanaInicio_ui import Ui_launcher
from translator import TRANSLATIONS
from resources import resources_rc



class launcher(QMainWindow):
    abrir_config_signal = Signal()
    abrir_cargar_signal = Signal()
    abrir_nueva_signal = Signal()
    idioma_cambiado = Signal(str)

    def __init__(self, app_state, parent=None):
        super().__init__(parent)
        self.app_state = app_state
        self.ui = Ui_launcher()
        self.ui.setupUi(self)
        
    
        self.ui.nuevaPartida.clicked.connect(self.nueva_partida)
        self.ui.cargarDatos.clicked.connect(self.cargar_datos)
        current_lang = self.app_state.get("language", "Español")
        self.ui.comboIdioma.setCurrentText(current_lang)
        self.ui.comboIdioma.currentTextChanged.connect(self.cambiar_idioma)
        self.ui.opciones.clicked.connect(self.emitir_abrir_config)
        self.ui.nuevaPartida.clicked.connect(self.nueva_partida)

    # === FUNCIONES ===
    def nueva_partida(self):
        print("Nueva partida iniciada")
        self.abrir_nueva_signal.emit()

    def cargar_datos(self):
        print("Cargar datos de partida")
        self.abrir_cargar_signal.emit()
        

    def emitir_abrir_config(self):
        print("Señal para abrir configuración emitida")
        self.abrir_config_signal.emit() 

    def cambiar_idioma(self, nuevo_idioma):
        """Cuando cambia el idioma en el combo."""
        self.app_state["language"] = nuevo_idioma
        self.apply_language()
        self.idioma_cambiado.emit(nuevo_idioma)
    
    def apply_language(self):
        """Actualiza los textos de la interfaz según el idioma actual."""
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS.get(lang, TRANSLATIONS["Español"])

        self.setWindowTitle(tr["launcher_title"])
        self.ui.nuevaPartida.setText(tr["new_game"])
        self.ui.cargarDatos.setText(tr["load_game"])
        self.ui.opciones.setText(tr["options"])
        self.ui.salir.setText(tr["exit"])
        self.ui.idioma.setText(tr["language_label"])
      
