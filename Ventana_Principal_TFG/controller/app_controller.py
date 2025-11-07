from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre
from PySide6.QtCore import Qt


class AppController:
    def __init__(self):
        self.app_state = {"language": "Español"}
        self.launcher = launcher(self.app_state)
        self.config_window = configuracion(self.app_state)
        self.carg_partidas = cargar(self.app_state)
        self.introducir_nombre = introducirNombre(self.app_state)
        self.launcher.abrir_config_signal.connect(self.mostrar_configuracion)
        self.launcher.abrir_cargar_signal.connect(self.mostrar_partidas_guardadas)
        self.launcher.abrir_nueva_signal.connect(self.abrir_nueva_partida)
        self.launcher.idioma_cambiado.connect(self.config_window.apply_language)
        self.launcher.idioma_cambiado.connect(self.carg_partidas.apply_language)
        self.launcher.idioma_cambiado.connect(self.introducir_nombre.apply_language)
       
    
        

    def mostrar_partidas_guardadas(self):
        print("Abriendo ventana de configuración desde el controlador")
        self.carg_partidas.setWindowModality(Qt.ApplicationModal) 
        self.carg_partidas.show()  
    
    def abrir_nueva_partida(self):
        print("Abriendo ventana de configuración desde el controlador")
        self.introducir_nombre.setWindowModality(Qt.ApplicationModal) 
        self.introducir_nombre.show()  
        

    def mostrar_configuracion(self):
        print("Abriendo ventana de cargar partida desde el controlador")
        self.config_window.setWindowModality(Qt.ApplicationModal) 
        self.config_window.show()  
        
    

   
   
