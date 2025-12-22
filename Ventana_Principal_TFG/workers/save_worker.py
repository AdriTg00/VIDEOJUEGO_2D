# save_worker.py
from PySide6.QtCore import QThread, Signal
import traceback

class SaveWorker(QThread):
    finished = Signal(object)   # emitimos respuesta (dict u otro)
    error = Signal(str)         # emitimos mensaje de error (string)

    def __init__(self, func, *args, **kwargs):
        """
        func: función a ejecutar en background (ej: service.crear_usuario)
        args/kwargs: parámetros para esa función
        """
        super().__init__()
        self.func = func
        self.args = args
        self.kwargs = kwargs

    def run(self):
        try:
            result = self.func(*self.args, **self.kwargs)
            self.finished.emit(result)
        except Exception as e:
            tb = traceback.format_exc()
            # Emitimos mensaje de error legible.
            self.error.emit(f"{str(e)}\n{tb}")
