from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import (
    QWidget, QMessageBox, QTableWidgetItem, QAbstractItemView
)

from views.partidasGuardadas_ui import Ui_partidaGuardada
from views.loading_overlay import LoadingOverlay
from translator import TRANSLATIONS
from services.partida_service import PartidasService
from services.jugador_service import JugadorService
from workers.save_worker import SaveWorker
from utils.logger import setup_logger


class cargar(QWidget):
    partida_seleccionada = Signal(dict)

    def __init__(self, app_state, parent=None):
        super().__init__(parent)
        self.log = setup_logger("cargar_partidas")
        self.log.info("=== Ventana Cargar Partidas creada ===")
        self.ui = Ui_partidaGuardada()
        self.ui.setupUi(self)
        self.setFixedSize(self.size())
        self.app_state = app_state
        self.partida_service = PartidasService()
        self.jugador_service = JugadorService()

        self._overlay = LoadingOverlay(self, "Cargando partidas...")

        self.ui.tablaGuardados.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.ui.tablaGuardados.setSelectionMode(QAbstractItemView.SingleSelection)
        self.ui.tablaGuardados.itemDoubleClicked.connect(self._on_partida_doble_click)

        self.apply_language()

    def apply_language(self):
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]
        self.setWindowTitle(tr.get("saved_games", "Partidas guardadas"))
        self.ui.partidasGuardadas.setText(tr.get("saved_games", "Partidas guardadas"))

    def cargar_partidas(self):
        self.log.info("Iniciando cargar_partidas()")
        jugador_id = self.app_state.get("usuario")
        if not jugador_id:
            self.log.warning("No hay usuario activo")
            QMessageBox.warning(self, "Error", "No hay usuario activo")
            return

        self._overlay.show_loading("Cargando partidas...")
        self.worker = SaveWorker(self._fetch_partidas, jugador_id)
        self.worker.finished.connect(self._on_partidas_cargadas)
        self.worker.error.connect(self._on_carga_error)
        self.worker.start()

    def _fetch_partidas(self, jugador_id):
        return self.partida_service.obtener_partidas(jugador_id)

    def _on_partidas_cargadas(self, result):
        self._overlay.hide_loading()
        partidas = result if isinstance(result, list) else []
        self.log.info(f"Partidas obtenidas: {len(partidas)}")

        tabla = self.ui.tablaGuardados
        tabla.setRowCount(len(partidas))

        for fila, partida in enumerate(partidas):
            item_jugador = QTableWidgetItem(self.app_state.get("usuario", ""))
            item_jugador.setData(Qt.UserRole, partida)
            tabla.setItem(fila, 0, item_jugador)
            tabla.setItem(fila, 1, QTableWidgetItem(str(partida.get("nivel", 1))))
            tabla.setItem(fila, 2, QTableWidgetItem(str(partida.get("muertes_nivel", 0))))
            tabla.setItem(fila, 3, QTableWidgetItem(self._formatear_tiempo(partida.get("tiempo", 0))))
            tabla.setItem(fila, 4, QTableWidgetItem(str(partida.get("puntuacion", 0))))
            tabla.setItem(fila, 5, QTableWidgetItem(str(partida.get("fecha", ""))))
            tabla.setItem(fila, 6, QTableWidgetItem(partida.get("id", "")))

        tabla.setColumnHidden(6, True)
        self._cargar_estadisticas_ultima()

    def _on_carga_error(self, err_text):
        self._overlay.hide_loading()
        self.log.error(f"Error cargando partidas: {err_text}")
        QMessageBox.critical(self, "Error", f"No se pudieron cargar las partidas.\n{err_text}")

    def _cargar_estadisticas_ultima(self):
        jugador_id = self.app_state.get("usuario")
        if not jugador_id:
            self.ui.lblEstadisticas.setText("")
            return

        try:
            stats = self.jugador_service.obtener_estadisticas_jugador(jugador_id)
        except Exception as e:
            self.log.error(f"Error obteniendo estadísticas", exc_info=True)
            self.ui.lblEstadisticas.setText("")
            return

        if not stats or int(stats.get("niveles_superados", 0)) == 0:
            self.ui.lblEstadisticas.setText("")
            return

        texto = (
            "ULTIMA PARTIDA COMPLETADA\n\n"
            f"Jugador: {stats.get('nombre', '-')}\n"
            f"Tiempo total: {round(stats.get('tiempo_total', 0), 2)} s\n"
            f"Puntuación total: {stats.get('puntuacion_total', 0)}\n"
            f"Niveles superados: {stats.get('niveles_superados', 0)}"
        )
        self.ui.lblEstadisticas.setText(texto)

    def _formatear_tiempo(self, segundos):
        if not segundos:
            return "00:00"
        minutos = int(segundos) // 60
        seg = int(segundos) % 60
        return f"{minutos:02}:{seg:02}"

    def _on_partida_doble_click(self, item):
        fila = item.row()
        partida = self.ui.tablaGuardados.item(fila, 0).data(Qt.UserRole)
        self.log.info(f"Partida seleccionada: {partida}")
        self.partida_seleccionada.emit(partida)
        self.close()
