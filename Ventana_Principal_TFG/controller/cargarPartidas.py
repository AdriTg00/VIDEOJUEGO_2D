from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget,
    QMessageBox,
    QTableWidgetItem,
    QAbstractItemView
)

from views.partidasGuardadas_ui import Ui_partidaGuardada
from translator import TRANSLATIONS

from services.partida_service import PartidasService
from services.jugador_service import JugadorService
from utils.logger import setup_logger


class cargar(QWidget):
    # Emitimos LA PARTIDA COMPLETA
    partida_seleccionada = Signal(dict)

    def __init__(self, app_state, parent=None):
        super().__init__(parent)

        # Logger
        self.log = setup_logger("cargar_partidas")
        self.log.info("=== Ventana Cargar Partidas creada ===")

        # -------------------------------------------------
        # UI
        # -------------------------------------------------
        self.ui = Ui_partidaGuardada()
        self.ui.setupUi(self)
        self.setFixedSize(self.size())

        # -------------------------------------------------
        # Estado
        # -------------------------------------------------
        self.app_state = app_state
        self.log.info(f"App state recibido: {self.app_state}")

        # -------------------------------------------------
        # Servicios
        # -------------------------------------------------
        self.partida_service = PartidasService()
        self.jugador_service = JugadorService()

        # -------------------------------------------------
        # Tabla
        # -------------------------------------------------
        self.ui.tablaGuardados.setSelectionBehavior(
            QAbstractItemView.SelectRows
        )
        self.ui.tablaGuardados.setSelectionMode(
            QAbstractItemView.SingleSelection
        )

        self.ui.tablaGuardados.itemDoubleClicked.connect(
            self._on_partida_doble_click
        )

        # Init
        self.apply_language()
        self.cargar_partidas()

    # Idioma
    def apply_language(self):
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]

        self.setWindowTitle(tr.get("saved_games", "Partidas guardadas"))
        self.ui.partidasGuardadas.setText(
            tr.get("saved_games", "Partidas guardadas")
        )

    # Estadísticas globales
    def _cargar_estadisticas_ultima(self):
        self.log.info("Entrando en _cargar_estadisticas_ultima()")

        jugador_id = self.app_state.get("usuario")
        self.log.info(f"Jugador ID para estadísticas: {jugador_id}")

        if not jugador_id:
            self.log.warning("Jugador ID vacío, limpiando estadísticas")
            self.ui.lblEstadisticas.setText("")
            return

        try:
            stats = self.jugador_service.obtener_estadisticas_jugador(jugador_id)
            self.log.info("Estadísticas recibidas del backend")
            self.log.debug(f"Stats completas: {stats}")
        except Exception as e:
            self.log.error(
                f"Error obteniendo estadísticas del jugador {jugador_id}",
                exc_info=True
            )
            self.ui.lblEstadisticas.setText("")
            return

        if not stats:
            self.log.warning("Stats vacías")
            self.ui.lblEstadisticas.setText("")
            return

        niveles = stats.get("niveles_superados", 0)
        self.log.info(f"niveles_superados = {niveles} ({type(niveles)})")

        if int(niveles) == 0:
            self.log.warning("niveles_superados == 0, no se muestran estadísticas")
            self.ui.lblEstadisticas.setText("")
            return

        texto = (
            "🏁 ÚLTIMA PARTIDA COMPLETADA\n\n"
                f"👤 Jugador: {stats.get('nombre', '-')}\n"
                f"⏱ Tiempo total: {round(stats.get('tiempo_total', 0), 2)} s\n"
                f"⭐ Puntuación total: {stats.get('puntuacion_total', 0)}\n"
                f"🏆 Niveles superados: {stats.get('niveles_superados', 0)}"
        )

        self.log.info("Pintando estadísticas en lblEstadisticas")
        self.ui.lblEstadisticas.setText(texto)

    # Cargar partidas
    def cargar_partidas(self):
        self.log.info("Iniciando cargar_partidas()")

        jugador_id = self.app_state.get("usuario")
        self.log.info(f"Jugador activo: {jugador_id}")

        if not jugador_id:
            self.log.warning("No hay usuario activo")
            QMessageBox.warning(self, "Error", "No hay usuario activo")
            return

        try:
            partidas = self.partida_service.obtener_partidas(jugador_id)
            self.log.info(f"Partidas obtenidas: {len(partidas)}")
            self.log.debug(f"Contenido partidas: {partidas}")
        except Exception as e:
            self.log.error(
                "Error obteniendo partidas",
                exc_info=True
            )
            QMessageBox.critical(self, "Error", str(e))
            return

        tabla = self.ui.tablaGuardados
        tabla.setRowCount(len(partidas))

        for fila, partida in enumerate(partidas):
            item_jugador = QTableWidgetItem(jugador_id)
            item_jugador.setData(Qt.UserRole, partida)
            tabla.setItem(fila, 0, item_jugador)

            tabla.setItem(fila, 1, QTableWidgetItem(str(partida.get("nivel", 1))))
            tabla.setItem(fila, 2, QTableWidgetItem(str(partida.get("muertes_nivel", 0))))
            tabla.setItem(fila, 3, QTableWidgetItem(
                self._formatear_tiempo(partida.get("tiempo", 0))
            ))
            tabla.setItem(fila, 4, QTableWidgetItem(str(partida.get("puntuacion", 0))))
            tabla.setItem(fila, 5, QTableWidgetItem(str(partida.get("fecha", ""))))
            tabla.setItem(fila, 6, QTableWidgetItem(partida.get("id", "")))

        tabla.setColumnHidden(6, True)

        self.log.info("Tabla cargada, cargando estadísticas globales")
        self._cargar_estadisticas_ultima()

    # Utilidades
    def _formatear_tiempo(self, segundos):
        if not segundos:
            return "00:00"

        minutos = int(segundos) // 60
        seg = int(segundos) % 60
        return f"{minutos:02}:{seg:02}"


    # Doble click
    def _on_partida_doble_click(self, item):
        fila = item.row()
        partida = self.ui.tablaGuardados.item(fila, 0).data(Qt.UserRole)

        self.log.info(f"Partida seleccionada: {partida}")
        self.partida_seleccionada.emit(partida)
        self.close()
