from PySide6.QtWidgets import QMessageBox
from PySide6.QtCore import Qt

from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre

from .session_manager import SessionManager
from .controlador_navegacion import NavigationController
from .game_launcher import GameLauncher
from PySide6.QtWidgets import QApplication


class AppController:
    def __init__(self):
        
        # Sesión
        self.session = SessionManager()

    
        # Ventanas
        self.launcher = launcher(self.session.state)
        self.config = configuracion(self.session.state)
        self.cargar = cargar(self.session.state)
        self.intro = introducirNombre(self.session.state)

        
        # Controladores
        self.nav = NavigationController(
            self.launcher,
            self.cargar,
            self.config,
            self.intro
        )
        self.game = GameLauncher(self.session)

        
        # Señales
        self._conectar_senales()


        # Arranque
        self._decidir_inicio()

    def _conectar_senales(self):
        self.intro.nombre_validado.connect(self._on_nombre_validado, type=Qt.QueuedConnection)

        self.launcher.abrir_config_signal.connect(self.nav.mostrar_config)
        self.launcher.abrir_cargar_signal.connect(self.nav.mostrar_partidas)
        self.launcher.abrir_nueva_signal.connect(self._nueva_partida)

        self.cargar.partida_seleccionada.connect(self._cargar_partida)
        self.launcher.salir_signal.connect(self._salir_app)

        self.launcher.idioma_cambiado.connect(self.config.apply_language)
        self.launcher.idioma_cambiado.connect(self.cargar.apply_language)
        self.launcher.idioma_cambiado.connect(self.intro.apply_language)

    def _decidir_inicio(self):
        if self.session.state["usuario"]:
            self.nav.mostrar_launcher()
        else:
            self.nav.mostrar_intro()


    # Callbacks
    def _on_nombre_validado(self, user_id):
        self.session.guardar_usuario(user_id)
        self.nav.mostrar_launcher()

    def _nueva_partida(self):
        self.game.lanzar_nueva()
        self.launcher.close()

    def _cargar_partida(self, partida):
        self.game.lanzar_con_partida(partida)
        self.launcher.close()
    
    def _salir_app(self):
        QApplication.quit()
