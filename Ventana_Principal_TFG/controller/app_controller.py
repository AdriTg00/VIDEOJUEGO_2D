
from .VentanaInicio import launcher
from .cargarPartidas import cargar
from .configuracion import configuracion
from .introduccionNombre import introducirNombre
from PySide6.QtCore import Qt
import os
import json


class AppController:
    def __init__(self):
        self.nombre_jugador = None
        self.app_state = {"language": "Español"}
        self.launcher = launcher(self.app_state)
        self.config_window = configuracion(self.app_state)
        self.carg_partidas = cargar(self.app_state)
        self.introducir_nombre = introducirNombre(self.app_state)
        self.comprobar_usuario_local()
        self.introducir_nombre.nombre_validado.connect(self.mostrar_launcher)
        self.launcher.abrir_config_signal.connect(self.mostrar_configuracion)
        self.launcher.abrir_cargar_signal.connect(self.mostrar_partidas_guardadas)
        self.launcher.abrir_nueva_signal.connect(self.abrir_nueva_partida)
        self.launcher.idioma_cambiado.connect(self.config_window.apply_language)
        self.launcher.idioma_cambiado.connect(self.carg_partidas.apply_language)
        self.launcher.idioma_cambiado.connect(self.introducir_nombre.apply_language)
        
    

    def mostrar_launcher(self, user_id):
        print("Usuario validado:", user_id)
        self.user_id = user_id   # Guardar ID en memoria
        self.introducir_nombre.hide()
     
        
    def mostrar_partidas_guardadas(self):
        print("Abriendo ventana de configuración desde el controlador")
        self.carg_partidas.setWindowModality(Qt.ApplicationModal) 
        self.carg_partidas.show()  
        

    def mostrar_configuracion(self):
        print("Abriendo ventana de cargar partida desde el controlador")
        self.config_window.setWindowModality(Qt.ApplicationModal) 
        self.config_window.show()  
    
    
    def abrir_nueva_partida(self):
        print("Abriendo ventana de introducción de nombre desde el controlador")
    
    def comprobar_usuario_local(self):
        if os.path.exists("usuario_local.json"):
            with open("usuario_local.json", "r") as f:
                datos = json.load(f)

            print("Usuario ya registrado → entrando directo al launcher")
            self.mostrar_launcher(datos["id"])
            self.launcher.show()
        else:
            print("No existe usuario guardado → pedir nombre")
            self.introducir_nombre.setWindowModality(Qt.ApplicationModal) 
            self.introducir_nombre.show()  
            


   
   
