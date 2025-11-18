import sys
from PySide6.QtCore import QTranslator, QCoreApplication
from PySide6.QtWidgets import QApplication
from controller.app_controller import AppController
from resources import resources_rc
from services.configuracionService import ConfiguracionDAO

def main():
    configuracion = ConfiguracionDAO()
    configuracion._connect()
    configuracion._ensure_table()
    app = QApplication(sys.argv)
    app.setApplicationName("Launcher")
    app.setStyleSheet("""
        QMessageBox QLabel {
            color: black;
        }
        QMessageBox QPushButton {
            color: black;
        }
    """)
    controller = AppController()
    controller.introducir_nombre.setFixedSize(controller.launcher.size())
    controller.launcher.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()