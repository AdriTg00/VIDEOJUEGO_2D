class Configuracion:
    def __init__(
        self,
        volumen_musica: int = 50,
        volumen_sfx: int = 50,
        resolucion: str = "1920x1080",
        modo_pantalla: str = "ventana"
    ):
        self.volumen_musica = volumen_musica
        self.volumen_sfx = volumen_sfx
        self.resolucion = resolucion
        self.modo_pantalla = modo_pantalla

    def __repr__(self):
        return (
            f"<Configuracion musica={self.volumen_musica}, "
            f"sfx={self.volumen_sfx}, res={self.resolucion}, "
            f"pantalla={self.modo_pantalla}>"
        )
