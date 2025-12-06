# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'partidasGuardadas.ui'
##
## Created by: Qt User Interface Compiler version 6.10.0
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QAbstractItemView, QApplication, QGridLayout, QHeaderView,
    QLabel, QSizePolicy, QSpacerItem, QTableWidget,
    QTableWidgetItem, QWidget)

class Ui_partidaGuardada(object):
    def setupUi(self, partidaGuardada):
        if not partidaGuardada.objectName():
            partidaGuardada.setObjectName(u"partidaGuardada")
        partidaGuardada.resize(588, 519)
        partidaGuardada.setStyleSheet(u"background-color: #faf0d6;")
        self.gridLayout = QGridLayout(partidaGuardada)
        self.gridLayout.setObjectName(u"gridLayout")
        self.tableWidget = QTableWidget(partidaGuardada)
        if (self.tableWidget.columnCount() < 7):
            self.tableWidget.setColumnCount(7)
        __qtablewidgetitem = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(0, __qtablewidgetitem)
        __qtablewidgetitem1 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(1, __qtablewidgetitem1)
        __qtablewidgetitem2 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(2, __qtablewidgetitem2)
        __qtablewidgetitem3 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(3, __qtablewidgetitem3)
        __qtablewidgetitem4 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(4, __qtablewidgetitem4)
        __qtablewidgetitem5 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(5, __qtablewidgetitem5)
        __qtablewidgetitem6 = QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(6, __qtablewidgetitem6)
        self.tableWidget.setObjectName(u"tableWidget")
        self.tableWidget.setStyleSheet(u"/* --- Tabla general --- */\n"
"QTableWidget, QTableView {\n"
"    background-color: #F5E8C7;      /* pergamino */\n"
"    color: #5C3A1E;                 /* marr\u00f3n texto */\n"
"    border: 3px solid #7A4E28;      /* borde pixel marr\u00f3n */\n"
"    gridline-color: #D2B48C;        /* l\u00edneas internas suaves */\n"
"    font-size: 14px;\n"
"    selection-background-color: #F1D7A3; \n"
"    selection-color: #3B2614;\n"
"}\n"
"\n"
"/* --- Cabecera horizontal --- */\n"
"QHeaderView::section {\n"
"    background-color: #EED9B6; \n"
"    color: #4A2E1A;\n"
"    padding: 6px;\n"
"    border: 2px solid #7A4E28;\n"
"    font-weight: bold;\n"
"}\n"
"\n"
"/* --- Filas alternas --- */\n"
"QTableWidget::item:alternate,\n"
"QTableView::item:alternate {\n"
"    background-color: #F9EED3; \n"
"}\n"
"\n"
"/* --- Filas normales --- */\n"
"QTableWidget::item,\n"
"QTableView::item {\n"
"    padding: 4px;\n"
"}\n"
"\n"
"/* --- Hover sobre filas --- */\n"
"QTableWidget::item:hover,\n"
"QTableView::item:hover {\n"
"    bac"
                        "kground-color: #FFF5DD;\n"
"    color: #3B2614;\n"
"}\n"
"\n"
"/* --- Barra de scroll horizontal --- */\n"
"QScrollBar:horizontal {\n"
"    background: #EED9B6;\n"
"    height: 14px;\n"
"    border: 2px solid #7A4E28;\n"
"}\n"
"\n"
"QScrollBar::handle:horizontal {\n"
"    background: #C7A272;\n"
"    min-width: 30px;\n"
"}\n"
"\n"
"QScrollBar::add-line:horizontal,\n"
"QScrollBar::sub-line:horizontal {\n"
"    background: #B89262;\n"
"    width: 14px;\n"
"}\n"
"\n"
"/* --- Scroll vertical (si existiera) --- */\n"
"QScrollBar:vertical {\n"
"    background: #EED9B6;\n"
"    width: 14px;\n"
"    border: 2px solid #7A4E28;\n"
"}\n"
"\n"
"QScrollBar::handle:vertical {\n"
"    background: #C7A272;\n"
"    min-height: 30px;\n"
"}\n"
"\n"
"QScrollBar::add-line:vertical,\n"
"QScrollBar::sub-line:vertical {\n"
"    background: #B89262;\n"
"    height: 14px;\n"
"}\n"
"")
        self.tableWidget.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self.tableWidget.setAlternatingRowColors(True)
        self.tableWidget.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        self.tableWidget.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.tableWidget.setSortingEnabled(True)
        self.tableWidget.setColumnCount(7)

        self.gridLayout.addWidget(self.tableWidget, 4, 0, 1, 1)

        self.verticalSpacer = QSpacerItem(20, 40, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)

        self.gridLayout.addItem(self.verticalSpacer, 5, 0, 1, 1)

        self.verticalSpacer_2 = QSpacerItem(20, 40, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)

        self.gridLayout.addItem(self.verticalSpacer_2, 0, 0, 1, 1)

        self.partidasGuardadas = QLabel(partidaGuardada)
        self.partidasGuardadas.setObjectName(u"partidasGuardadas")
        sizePolicy = QSizePolicy(QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.partidasGuardadas.sizePolicy().hasHeightForWidth())
        self.partidasGuardadas.setSizePolicy(sizePolicy)
        self.partidasGuardadas.setMaximumSize(QSize(500, 300))
        self.partidasGuardadas.setStyleSheet(u"QLabel {\n"
"    color: #3C3C3C;\n"
"    font-size: 30px;\n"
"    font-weight: bold;\n"
"    padding: 6px;\n"
"    letter-spacing: 1px;\n"
"}")
        self.partidasGuardadas.setTextFormat(Qt.TextFormat.AutoText)
        self.partidasGuardadas.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.partidasGuardadas.setWordWrap(False)
        self.partidasGuardadas.setOpenExternalLinks(False)

        self.gridLayout.addWidget(self.partidasGuardadas, 2, 0, 1, 1)


        self.retranslateUi(partidaGuardada)

        QMetaObject.connectSlotsByName(partidaGuardada)
    # setupUi

    def retranslateUi(self, partidaGuardada):
        partidaGuardada.setWindowTitle(QCoreApplication.translate("partidaGuardada", u"Partidas guardadas", None))
        ___qtablewidgetitem = self.tableWidget.horizontalHeaderItem(0)
        ___qtablewidgetitem.setText(QCoreApplication.translate("partidaGuardada", u"Jugador", None));
        ___qtablewidgetitem1 = self.tableWidget.horizontalHeaderItem(1)
        ___qtablewidgetitem1.setText(QCoreApplication.translate("partidaGuardada", u"Nivel", None));
        ___qtablewidgetitem2 = self.tableWidget.horizontalHeaderItem(2)
        ___qtablewidgetitem2.setText(QCoreApplication.translate("partidaGuardada", u"Muertes", None));
        ___qtablewidgetitem3 = self.tableWidget.horizontalHeaderItem(3)
        ___qtablewidgetitem3.setText(QCoreApplication.translate("partidaGuardada", u"Puntuacion", None));
        ___qtablewidgetitem4 = self.tableWidget.horizontalHeaderItem(4)
        ___qtablewidgetitem4.setText(QCoreApplication.translate("partidaGuardada", u"Tiempo", None));
        ___qtablewidgetitem5 = self.tableWidget.horizontalHeaderItem(5)
        ___qtablewidgetitem5.setText(QCoreApplication.translate("partidaGuardada", u"Fecha", None));
        ___qtablewidgetitem6 = self.tableWidget.horizontalHeaderItem(6)
        ___qtablewidgetitem6.setText(QCoreApplication.translate("partidaGuardada", u"ID", None));
        self.partidasGuardadas.setText(QCoreApplication.translate("partidaGuardada", u"Partidas guardadas:", None))
    # retranslateUi

