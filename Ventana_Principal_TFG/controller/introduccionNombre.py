# introducirNombre.py
from PySide6.QtCore import Signal
from workers.save_worker import SaveWorker
from PySide6.QtWidgets import QWidget, QMessageBox
from views.introduccionNombre_ui import Ui_introduccionNombre
from translator import TRANSLATIONS
from services.jugadorService import JugadorService


class introducirNombre(QWidget):
    nombre_validado = Signal(str)

    def __init__(self, app_state, parent=None):
        super().__init__(parent)

        self.app_state = app_state
        self.ui = Ui_introduccionNombre()
        self.ui.setupUi(self)
        self.setFixedSize(self.size())
        self.service = JugadorService()


        # Creamos DAO y Service (por ahora lo dejamos así)

        # Aplica idioma al inicio
        self.apply_language()

        # Conexión botón -> validar nombre (ahora asíncrono)
        self.ui.iniciarPartida.clicked.connect(self.validar_nombre)

        # Guardamos el worker en self para que no se recoja el GC
        self.worker = None

    def apply_language(self):
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS.get(lang, {})

        # Fallbacks por si faltan claves
        self.setWindowTitle(tr.get("intro_title", "Introducción de nombre"))
        self.ui.labelNombre.setText(tr.get("intro_label", "Introduce tu nombre:"))
        self.ui.iniciarPartida.setText(tr.get("intro_button", "INICIAR PARTIDA"))
        self.ui.nombre.setPlaceholderText(tr.get("intro_placeholder", "Escribe tu nombre"))

    def validar_nombre(self):
        nombre = self.ui.nombre.text().strip()
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS.get(lang, {})

        if not nombre:
            title = tr.get("titulo_error", "Error")
            body = tr.get("error_nombre_vacio", "El nombre no puede estar vacío.")
            QMessageBox.warning(self, title, body)
            return

        # UI feedback inmediato (texto traducible)
        saving_text = tr.get("guardando", "Guardando...")
        self.ui.iniciarPartida.setEnabled(False)
        self.ui.iniciarPartida.setText(saving_text)

        # Lanzamos el worker para crear el usuario sin bloquear la UI
        # SaveWorker ejecuta la función pasada en background y emite finished/error
        self.worker = SaveWorker(self.service.crear_usuario, nombre)
        self.worker.finished.connect(self._on_creado_ok)
        self.worker.error.connect(self._on_creado_error)
        self.worker.start()

    def _on_creado_ok(self, datos):
        # Restaurar UI (texto traducible)
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS.get(lang, {})
        start_text = tr.get("intro_button", "INICIAR PARTIDA")

        self.ui.iniciarPartida.setEnabled(True)
        self.ui.iniciarPartida.setText(start_text)

        # Igual que antes: extraer id devuelto por API y emitir solo el id
        user_id = None
        if isinstance(datos, dict):
            # intenta varias claves comunes por si el backend varía
            user_id = datos.get("id") or datos.get("usuario_id") or datos.get("user_id")
        # fallback: si no hay id pero la petición fue exitosa, usa el nombre escrito
        if not user_id:
            user_id = self.ui.nombre.text().strip()

        self.nombre_validado.emit(user_id)

        # opcional: limpia campo o deja el valor (según tu UX)
        # self.ui.nombre.clear()

    def _on_creado_error(self, err_text):
        # Restaurar UI (texto traducible) y mostrar error detallado
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS.get(lang, {})
        start_text = tr.get("intro_button", "INICIAR PARTIDA")

        self.ui.iniciarPartida.setEnabled(True)
        self.ui.iniciarPartida.setText(start_text)

        title = tr.get("titulo_error", "Error")
        body = tr.get("error_guardar", "Ocurrió un error al guardar.")
        # mostramos mensaje traducido más detalle técnico (útil para depurar)
        QMessageBox.warning(self, title, f"{body}\n\n{err_text}")
