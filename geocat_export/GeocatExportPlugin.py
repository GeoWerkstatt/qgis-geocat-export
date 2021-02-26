import os
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qgis.PyQt.QtCore import QTranslator, QSettings, QLocale, QCoreApplication

from .GeocatExport import *

SUPPORTED_LAYERTYPES = [QgsMapLayerType.VectorLayer, QgsMapLayerType.RasterLayer]

class GeocatExportPlugin:

    def __init__(self, iface):
        self.iface = iface

    def initGui(self):
        # Initialize translation
        qgis_locale = QLocale(QSettings().value('locale/userLocale'))
        locale_path = os.path.join(os.path.dirname(__file__), 'i18n')
        self.translator = QTranslator()
        self.translator.load(qgis_locale, 'GeocatExport', '_', locale_path)
        QCoreApplication.installTranslator(self.translator)

        icon_path = os.path.join(os.path.dirname(__file__), 'icons/cat-logo.png')
        self.layerAction = QAction(QIcon(icon_path), QCoreApplication.translate('generals','Export layer metadata for geocat.ch'), self.iface.mainWindow())
        self.layerAction.setObjectName("ExportLayerMetadataToGeocat")
        self.layerAction.triggered.connect(self.exportMetadata)

        for layerType in SUPPORTED_LAYERTYPES:
            self.iface.addCustomActionForLayerType(self.layerAction, "", layerType, True)

    def unload(self):
        for layerType in SUPPORTED_LAYERTYPES:
            self.iface.removeCustomActionForLayerType(self.layerAction)

    def exportMetadata(self):
        GeocatExport(self.iface)
