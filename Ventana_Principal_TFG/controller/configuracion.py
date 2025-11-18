from PySide6.QtWidgets import QWidget, QMessageBox
from views.configuracion_ui import Ui_configuracion
from services.configuracionService import ConfiguracionService
from model.configuracion import Configuracion
from translator import TRANSLATIONS



class configuracion(QWidget):
    def __init__(self, app_state, parent=None):
        super().__init__(parent)
        self.app_state = app_state
        self.ui = Ui_configuracion()
        self.service = ConfiguracionService()
        self.ui.setupUi(self)
        self.ui.ventana.setChecked(True)
        self.ui.ventana.stateChanged.connect(self.sync_checkboxes)
        self.ui.completa.stateChanged.connect(self.sync_checkboxes)
        #Sliders
        self.ui.volumenGeneralSlider.valueChanged.connect(self.actualizar_volumen_general)
        self.ui.volumenSFXSlider.valueChanged.connect(self.actualizar_volumen_sfx)
        # Mostrar valores iniciales
        self.actualizar_volumen_general()
        self.actualizar_volumen_sfx()
        #Guardar configuracion
        self.ui.guardar.clicked.connect(self.guardar_configuracion)
        self.apply_language()


    def apply_language(self):
        """Actualiza todos los textos según el idioma actual."""
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]

        self.setWindowTitle(tr.get("settings_title", "Configuración"))
        self.ui.VolumenGeneral.setText(tr.get("general_volume", "Volumen general:"))
        self.ui.VolumenSFX.setText(tr.get("sfx_volume", "Volumen SFX:"))
        self.ui.Resolucion.setText(tr.get("resolution", "Resolución:"))
        self.ui.TipoDeVisualizacion.setText(tr.get("view_type", "Tipo de visualización:"))
        self.ui.ventana.setText(tr.get("windowed", "Ventana"))
        self.ui.completa.setText(tr.get("fullscreen", "Completa"))
        self.ui.guardar.setText(tr.get("save_settings", "Guardar configuración"))

    def sync_checkboxes(self):
        sender = self.sender()

        if sender == self.ui.ventana and self.ui.ventana.isChecked():
            self.ui.completa.setChecked(False)

        elif sender == self.ui.completa and self.ui.completa.isChecked():
            self.ui.ventana.setChecked(False)

        if not self.ui.ventana.isChecked() and not self.ui.completa.isChecked():
            sender.setChecked(True)

        # === SLIDERS ===
    def actualizar_volumen_general(self):
        valor = self.ui.volumenGeneralSlider.value()
        self.ui.volumenGeneral.setText(f"{valor}%")

    def actualizar_volumen_sfx(self):
        valor = self.ui.volumenSFXSlider.value()
        self.ui.volumenSFX.setText(f"{valor}%")

    def guardar_configuracion(self):
        volumen_musica = self.ui.volumenGeneralSlider.value()
        volumen_sfx = self.ui.volumenSFXSlider.value()
        resolucion = self.ui.resolucion.currentText()
        modo_pantalla = "ventana" if self.ui.ventana.isChecked() else "completa"

        # Crear modelo
        config = Configuracion(
            volumen_musica=volumen_musica,
            volumen_sfx=volumen_sfx,
            resolucion=resolucion,
            modo_pantalla=modo_pantalla
        )

        # Guardar usando el SERVICE
        self.service.guardar_configuracion(config)

        # Mostrar mensaje
        msg = QMessageBox(self)
        msg.setWindowTitle("Guardado")
        msg.setText("Configuración guardada correctamente.")
        msg.exec()