from PySide6.QtCore import Qt


class NavigationController:
    def __init__(self, launcher, cargar, configuracion, introducir_nombre):
        self.launcher = launcher
        self.cargar = cargar
        self.config = configuracion
        self.intro = introducir_nombre

    def mostrar_launcher(self):
        self.intro.hide()
        self.launcher.show()
        self.launcher.raise_()
        self.launcher.activateWindow()

    def mostrar_intro(self):
        self.intro.setWindowModality(Qt.ApplicationModal)
        self.intro.show()

    def mostrar_partidas(self):
        self.cargar.setWindowModality(Qt.ApplicationModal)
        self.cargar.show()

    def mostrar_config(self):
        self.config.setWindowModality(Qt.ApplicationModal)
        self.config.show()
