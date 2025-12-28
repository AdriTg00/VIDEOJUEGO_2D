from PySide6.QtWidgets import QWidget, QLabel, QHBoxLayout, QVBoxLayout

class WidgetEstadisticasUltima(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.lbl_titulo = QLabel("Última partida completada")
        self.lbl_tiempo = QLabel("Tiempo: --")
        self.lbl_puntuacion = QLabel("Puntuación: --")
        self.lbl_niveles = QLabel("Niveles superados: --")

        layout_datos = QHBoxLayout()
        layout_datos.addWidget(self.lbl_tiempo)
        layout_datos.addWidget(self.lbl_puntuacion)
        layout_datos.addWidget(self.lbl_niveles)

        layout = QVBoxLayout(self)
        layout.addWidget(self.lbl_titulo)
        layout.addLayout(layout_datos)

        self.setVisible(False)  

    def actualizar(self, estadisticas: dict):
        self.lbl_tiempo.setText(f"Tiempo: {estadisticas['tiempo_total']:.2f}s")
        self.lbl_puntuacion.setText(f"Puntuación: {estadisticas['puntuacion_total']}")
        self.lbl_niveles.setText(f"Niveles superados: {estadisticas['niveles_superados']}")

        self.setVisible(True)
