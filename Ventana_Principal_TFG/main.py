import sys
from PySide6.QtWidgets import QApplication
from controller.app_controller import AppController
from bootstrap.app_bootstrap import init_persistence


def main():
    # Inicialización técnica (BD, tablas, etc.)
    init_persistence()

    # Qt App
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
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
