from PySide6.QtCore import Qt, Signal
from PySide6.QtWidgets import QWidget, QMessageBox, QTableWidgetItem, QAbstractItemView
from views.partidasGuardadas_ui import Ui_partidaGuardada
from translator import TRANSLATIONS
from services.partidaService import PartidasService


class cargar(QWidget):
    partida_seleccionada = Signal(str)

    def __init__(self, app_state, parent=None):
        super().__init__(parent)

        self.ui = Ui_partidaGuardada()
        self.ui.setupUi(self)

        self.partida_service = PartidasService()
        self.app_state = app_state

        # 🔹 Selección por FILA
        self.ui.tablaGuardados.setSelectionBehavior(
            QAbstractItemView.SelectRows
        )
        self.ui.tablaGuardados.setSelectionMode(
            QAbstractItemView.SingleSelection
        )

        # 🔹 Doble click = cargar partida
        self.ui.tablaGuardados.itemDoubleClicked.connect(
            self._on_partida_doble_click
        )

        self.apply_language()
        self.cargar_partidas()

    # -------------------------------------------------
    # Idioma
    # -------------------------------------------------
    def apply_language(self):
        lang = self.app_state.get("language", "Español")
        tr = TRANSLATIONS[lang]

        self.setWindowTitle(tr.get("saved_games", "Partidas guardadas"))
        self.ui.partidasGuardadas.setText(
            tr.get("saved_games", "Partidas guardadas")
        )

    # -------------------------------------------------
    # Cargar partidas
    # -------------------------------------------------
    def cargar_partidas(self):
        jugador = self.app_state.get("usuario")

        if not jugador:
            QMessageBox.warning(self, "Error", "No hay usuario activo")
            return

        try:
            partidas = self.partida_service.obtener_partidas(jugador)
        except Exception as e:
            QMessageBox.critical(self, "Error", str(e))
            return

        tabla = self.ui.tablaGuardados
        tabla.setRowCount(len(partidas))

        for fila, partida in enumerate(partidas):

            # Col 0 → Jugador
            item_jugador = QTableWidgetItem(partida["jugador_id"])
            item_jugador.setData(Qt.UserRole, partida["id"])  # ID oculto
            tabla.setItem(fila, 0, item_jugador)

            # Col 1 → Nivel
            tabla.setItem(
                fila, 1,
                QTableWidgetItem(str(partida["nivel"]))
            )

            # Col 2 → Muertes
            tabla.setItem(
                fila, 2,
                QTableWidgetItem(str(partida["muertes_nivel"]))
            )

            # Col 3 → Tiempo
            tabla.setItem(
                fila, 3,
                QTableWidgetItem(
                    self._formatear_tiempo(partida["tiempo"])
                )
            )

            # Col 4 → Puntuación
            tabla.setItem(
                fila, 4,
                QTableWidgetItem(str(partida["puntuacion"]))
            )

            # Col 5 → Fecha
            tabla.setItem(
                fila, 5,
                QTableWidgetItem(partida["fecha"])
            )

            # Col 6 → ID (visible solo si quieres)
            tabla.setItem(
                fila, 6,
                QTableWidgetItem(partida["id"])
            )

        # Opcional: ocultar columna ID
        tabla.setColumnHidden(6, True)

    # -------------------------------------------------
    # Utilidades
    # -------------------------------------------------
    def _formatear_tiempo(self, segundos):
        if not segundos:
            return "00:00"

        minutos = int(segundos) // 60
        seg = int(segundos) % 60
        return f"{minutos:02}:{seg:02}"

    # -------------------------------------------------
    # Doble click
    # -------------------------------------------------
    def _on_partida_doble_click(self, item):
        fila = item.row()

        # El ID lo guardamos en la columna Jugador (UserRole)
        partida_id = self.ui.tablaGuardados.item(
            fila, 0
        ).data(Qt.UserRole)

        self.partida_seleccionada.emit(partida_id)
        self.close()
