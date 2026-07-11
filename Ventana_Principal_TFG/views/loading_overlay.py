from PySide6.QtWidgets import QWidget, QLabel, QVBoxLayout
from PySide6.QtCore import Qt


class LoadingOverlay(QWidget):
    def __init__(self, parent=None, text="Cargando..."):
        super().__init__(parent)
        self._text = text
        self.setAttribute(Qt.WA_TransparentForMouseEvents, False)
        self.setStyleSheet("background-color: rgba(0, 0, 0, 180);")
        self.hide()

        layout = QVBoxLayout(self)
        layout.setAlignment(Qt.AlignCenter)
        self.label = QLabel(text, self)
        self.label.setStyleSheet("color: white; font-size: 24px; font-weight: bold; background: transparent;")
        self.label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.label)

    def show_loading(self, text=None):
        if text:
            self.label.setText(text)
        parent = self.parent()
        if parent:
            self.setGeometry(0, 0, parent.width(), parent.height())
        self.show()
        self.raise_()

    def hide_loading(self):
        self.hide()

    def resizeEvent(self, event):
        parent = self.parent()
        if parent:
            self.setGeometry(0, 0, parent.width(), parent.height())
        super().resizeEvent(event)
