# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'introduccionNombre.ui'
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
from PySide6.QtWidgets import (QApplication, QGridLayout, QLabel, QLineEdit,
    QPushButton, QSizePolicy, QSpacerItem, QWidget)

class Ui_introduccionNombre(object):
    def setupUi(self, introduccionNombre):
        if not introduccionNombre.objectName():
            introduccionNombre.setObjectName(u"introduccionNombre")
        introduccionNombre.resize(377, 187)
        introduccionNombre.setStyleSheet(u"background-color: #faf0d6;\n"
"")
        self.gridLayout = QGridLayout(introduccionNombre)
        self.gridLayout.setObjectName(u"gridLayout")
        self.nombre = QLineEdit(introduccionNombre)
        self.nombre.setObjectName(u"nombre")
        self.nombre.setMaximumSize(QSize(300, 40))
        self.nombre.setStyleSheet(u"QLineEdit {\n"
"    background-color: #FFF7D2;            /* fondo beige claro */\n"
"    border: 3px solid #C6A72F;            /* borde dorado */\n"
"    border-radius: 8px;                   /* esquinas suaves */\n"
"    color: #3A2F00;                       /* texto marr\u00f3n oscuro */\n"
"    font-weight: bold;\n"
"    font-family: \"Press Start 2P\", monospace;  /* si tienes fuente pixel */\n"
"    font-size: 8px;\n"
"    padding: 6px 10px;\n"
"    selection-background-color: #F7D24A;  /* color de selecci\u00f3n */\n"
"    selection-color: black;\n"
"}\n"
"\n"
"QLineEdit:hover {\n"
"    border-color: #E6C84F;                /* borde m\u00e1s brillante al pasar el rat\u00f3n */\n"
"    background-color: #FFF4BD;\n"
"}\n"
"\n"
"QLineEdit:focus {\n"
"    border-color: #FFD700;                /* dorado intenso cuando se escribe */\n"
"    background-color: #FFF9E0;\n"
"    box-shadow: 0 0 10px #FFD700;         /* efecto resplandor dorado */\n"
"}\n"
"\n"
"QLineEdit:disabled {\n"
"    background-color: #E0E0"
                        "E0;\n"
"    color: #888;\n"
"    border-color: #AAA;\n"
"}\n"
"")

        self.gridLayout.addWidget(self.nombre, 1, 2, 1, 1)

        self.horizontalSpacer = QSpacerItem(40, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)

        self.gridLayout.addItem(self.horizontalSpacer, 1, 0, 1, 1)

        self.horizontalSpacer_2 = QSpacerItem(40, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)

        self.gridLayout.addItem(self.horizontalSpacer_2, 1, 3, 1, 1)

        self.labelNombre = QLabel(introduccionNombre)
        self.labelNombre.setObjectName(u"labelNombre")
        self.labelNombre.setMaximumSize(QSize(150, 50))
        self.labelNombre.setStyleSheet(u"QLabel {\n"
"    color: #3C3C3C;\n"
"    font-size: 11px;\n"
"    font-weight: bold;\n"
"    padding: 6px;\n"
"    letter-spacing: 1px;\n"
"}")

        self.gridLayout.addWidget(self.labelNombre, 1, 1, 1, 1)

        self.iniciarPartida = QPushButton(introduccionNombre)
        self.iniciarPartida.setObjectName(u"iniciarPartida")
        self.iniciarPartida.setMaximumSize(QSize(300, 40))
        self.iniciarPartida.setLayoutDirection(Qt.LayoutDirection.LeftToRight)
        self.iniciarPartida.setStyleSheet(u"QPushButton {\n"
"    background-color: #F7E088;          /* dorado suave */\n"
"    border: 3px solid #C6A72F;          /* borde m\u00e1s oscuro */\n"
"    border-radius: 10px;\n"
"    color: #3A2F00;                     /* texto marr\u00f3n oscuro */\n"
"    font-weight: bold;\n"
"    font-family: \"Press Start 2P\", monospace; /* o una similar pixel */\n"
"    font-size: 12px;\n"
"    padding: 8px 16px;\n"
"    text-transform: uppercase;\n"
"    box-shadow: 0px 3px 0px #9E821F;    /* efecto relieve inferior */\n"
"}\n"
"\n"
"QPushButton:hover {\n"
"    background-color: #FFE87C;          /* brillo al pasar el rat\u00f3n */\n"
"    border-color: #E6C84F;\n"
"    box-shadow: 0px 3px 0px #C6A72F;\n"
"    transform: translateY(-1px);        /* efecto sutil de elevaci\u00f3n */\n"
"}\n"
"\n"
"QPushButton:pressed {\n"
"    background-color: #E6C84F;\n"
"    border-color: #A88C22;\n"
"    color: #2A2000;\n"
"    box-shadow: 0px 1px 0px #8B6F16;\n"
"    transform: translateY(2px);         /* efecto de \u201cclic\u201d"
                        " */\n"
"}\n"
"\n"
"QPushButton:disabled {\n"
"    background-color: #DDD2A0;\n"
"    border-color: #B5A36A;\n"
"    color: #888;\n"
"    box-shadow: none;\n"
"}\n"
"")
        self.iniciarPartida.setInputMethodHints(Qt.InputMethodHint.ImhDate)

        self.gridLayout.addWidget(self.iniciarPartida, 2, 1, 1, 1)


        self.retranslateUi(introduccionNombre)

        QMetaObject.connectSlotsByName(introduccionNombre)
    # setupUi

    def retranslateUi(self, introduccionNombre):
        introduccionNombre.setWindowTitle(QCoreApplication.translate("introduccionNombre", u"Form", None))
        self.nombre.setPlaceholderText(QCoreApplication.translate("introduccionNombre", u"Introduce el nombre", None))
        self.labelNombre.setText(QCoreApplication.translate("introduccionNombre", u"Introduce tu nombre:", None))
        self.iniciarPartida.setText(QCoreApplication.translate("introduccionNombre", u"Iniciar partida", None))
    # retranslateUi

