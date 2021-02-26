import processing
import lxml.etree as ET
import uuid
import os
import sys, traceback
import subprocess

from qgis.core import *
from qgis.gui import QgsMessageBarItem
from pathlib import Path
from datetime import date
from .assets.wgs84_ch1903 import *

from PyQt5.QtCore import Qt, QCoreApplication
from PyQt5.QtWidgets import QLabel, QWidget, QPushButton

DEBUG = False

class GeocatExport():

    def __init__(self, iface):
        self.iface = iface
        self.runExport()

    def runExport(self):
        layer = self.iface.activeLayer()
        (isValid, message) = self.ValidateMetadata(layer.metadata())
        if isValid:
            self.ToGm03(layer)
        else:
            self.showMessage(message, Qgis.Warning)

    def ValidateMetadata(self, metadata):
        # check main properties existence
        if not (metadata.title() or metadata.abstract()):
            return False, 'Metadata validation failed: Please specify title and abstract'
        elif not metadata.contacts():
            return False, 'Metadata validation failed: Please specify at least one contact'
        elif not (metadata.contacts()[0].role or metadata.contacts()[0].organization):
            return False, 'Metadata validation failed: Please specify role and organization name of your contact'
        elif not metadata.extent().spatialExtents():
            return False, 'Metadata validation failed: Please specify extent properties'
        elif metadata.extent().spatialExtents()[0].extentCrs.authid() != 'EPSG:2056':
            return False, 'Metadata validation failed: Extent CRS {} is not supported. CRS must be EPSG:2056'.format(metadata.extent().spatialExtents()[0].extentCrs.authid())
        elif not metadata.extent().temporalExtents()[0].begin():
            return False, 'Metadata validation failed: Please specify the begin time of the temporal extent'
        else:
            return True, ''

    def ToGm03(self, layer):
        metadata = layer.metadata()
        root = ET.Element('simpleGmd')
        root.set('gmdType', 'data')

        if not metadata.identifier():
            fileidentifier = str(uuid.uuid1())
        else:
            fileidentifier = metadata.identifier()

        filename = 'iso19139che_{}.xml'.format(layer.name())

        try:

            # set element fileidentifier
            sub = ET.SubElement(root, 'fileIdentifier')
            sub.text = fileidentifier
            # set element export date
            sub = ET.SubElement(root, 'dateStamp')
            sub.text = date.today().strftime('%Y-%m-%d')
            # set element metadataStandardName
            sub = ET.SubElement(root, 'metadataStandardName')
            sub.text = 'GM03 Core'
            # set element referenceSystemInfo
            sub = ET.SubElement(root, 'referenceSystemInfo')
            sub.text = layer.crs().description()

            # contact
            tree = ET.ElementTree(root)
            for contact in metadata.contacts():
                # set subtree contact
                cnt = ET.SubElement(root, 'contact')
                # set subtree responsibleParty
                rsp = ET.SubElement(cnt, 'responsibleParty')
                sub = ET.SubElement(rsp, 'individualFirstName')
                sub.text = contact.name
                # no split of firstname / lastname in layermetadata class
                sub = ET.SubElement(rsp, 'individualLastName')
                sub = ET.SubElement(rsp, 'role')
                sub.text = contact.role
                sub = ET.SubElement(rsp, 'organisationName')
                sub.text = contact.organization
                phn = ET.SubElement(rsp, 'phone')
                sub = ET.SubElement(phn, 'voice')
                sub.text = contact.voice
                sub = ET.SubElement(phn, 'facsimile')
                sub.text = contact.fax

                for address in contact.addresses:
                    adr = ET.SubElement(rsp, 'address')
                    sub = ET.SubElement(adr, 'city')
                    sub.text = address.city
                    sub = ET.SubElement(adr, 'postalCode')
                    sub.text = address.postalCode
                    sub = ET.SubElement(adr, 'country')
                    sub.text = address.country
                    # email ist not part of address class
                    sub = ET.SubElement(adr, 'electronicMailAddress')
                    sub.text = contact.email
                    # streetname and number are not independant properties in address class
                    sub = ET.SubElement(adr, 'streetName')
                    sub.text = address.address

                for link in metadata.links():
                    if link.description == "CI_OnlineResource":
                        olr = ET.SubElement(rsp, 'onlineResource')
                        sub = ET.SubElement(olr, 'url')
                        sub.text = link.url
                        sub = ET.SubElement(olr, 'protocol')
                        sub.text = link.mimeType
                        sub = ET.SubElement(olr, 'name')
                        sub.text = link.name
                        break  # only max 1 onlineResource per responsibleParty

            # identificationInfo
            idi = ET.SubElement(root, 'identificationInfo')
            sub = ET.SubElement(idi, 'title')
            sub.text = metadata.title()
            sub = ET.SubElement(idi, 'abstract')
            sub.text = metadata.abstract()
            sub = ET.SubElement(idi, 'creationDate')

            if not metadata.extent().temporalExtents()[0].isInstant():
                sub.text = metadata.extent().temporalExtents()[0].begin().toPyDateTime().strftime('%Y-%m-%d')

            tpc = ET.SubElement(idi, 'topicCategories')
            for category in metadata.categories():
                sub = ET.SubElement(tpc, 'topicCategory')
                # because Qgis automatically correct categories to UCase in layer metadata UI
                sub.text = category.lower()

            ext = ET.SubElement(idi, 'extent')
            sub = ET.SubElement(ext, 'description')
            sub.text = metadata.title()

            converter = GPSConverter()
            spatialExtent = metadata.extent().spatialExtents()[0]
            extentMaxWGS84 = converter.LV95toWGS84(int(spatialExtent.bounds.xMaximum()), int(spatialExtent.bounds.yMaximum()), 0)
            extentMinWGS84 = converter.LV95toWGS84(int(spatialExtent.bounds.xMinimum()), int(spatialExtent.bounds.yMinimum()), 0)

            gbb = ET.SubElement(ext, 'geographicBoundingBox')
            sub = ET.SubElement(gbb, 'westBoundLongitude')
            sub.text = str(extentMinWGS84[1])
            sub = ET.SubElement(gbb, 'eastBoundLongitude')
            sub.text = str(extentMaxWGS84[1])
            sub = ET.SubElement(gbb, 'southBoundLatitude')
            sub.text = str(extentMinWGS84[2])
            sub = ET.SubElement(gbb, 'northBoundLatitude')
            sub.text = str(extentMaxWGS84[2])

            # distributionInfo
            dbi = ET.SubElement(root, 'distributionInfo')
            frs = ET.SubElement(dbi, 'mdFormats')
            frm = ET.SubElement(frs, 'mdFormat')
            sub = ET.SubElement(frm, 'name')

            # todo: readout real dataset format
            sub.text = '-'
            sub = ET.SubElement(frm, 'version')
            sub.text = '-'

            tro = ET.SubElement(dbi, 'transferOptions')
            for link in metadata.links():
                if link.description == "gmd:MD_DigitalTransferOptions":
                    tfo = ET.SubElement(tro, 'transferOption')
                    sub = ET.SubElement(tfo, 'url')
                    sub.text = link.url
                    sub = ET.SubElement(tfo, 'protocol')
                    sub.text = link.type
                    sub = ET.SubElement(tfo, 'description')
                    sub.text = link.name
                    sub = ET.SubElement(tfo, 'onlineFunction')
                    sub.text = self.getOnlineFunction(link.type)

            self.dbg_info(ET.tostring(tree, encoding='utf-8', pretty_print=True))

            xslFile = str(Path(__file__).resolve().parent.joinpath('./assets/simpleGmdToIso19139che.xsl'))
            transform = ET.XSLT(ET.parse(xslFile))
            filepath = str(Path(Path.home(), filename))

            chedom = transform(tree)
            chedom.write(filepath, pretty_print=True)

            self.showMessage(filepath + QCoreApplication.translate('generals', ' file written.'), Qgis.Info, filepath)

        except Exception as e:
            QgsMessageLog.logMessage(str(e), level=Qgis.Critical)
            exc_type, exc_obj, exc_traceback = sys.exc_info()
            filename = os.path.split(exc_traceback.tb_frame.f_code.co_filename)[1]
            QgsMessageLog.logMessage('{} {} {}'.format(exc_type, filename, exc_traceback.tb_lineno), level=Qgis.Critical)
            QgsMessageLog.logMessage(traceback.print_exception(exc_type, exc_obj, exc_traceback), level=Qgis.Critical)

    @staticmethod
    def getOnlineFunction(type):
        return "download" if type == "WWW:DOWNLOAD-1.0-http--download" else "information"

    def showMessage(self, msg, level, filepath=""):
        title = "geocat.ch-Export"
        QgsMessageLog.logMessage(msg, level=level)

        if filepath:
            widget = self.iface.messageBar().createMessage(title, msg)
            folder = Path(filepath).parent

            def openFile():
                if sys.platform == "win32":
                    os.startfile(folder)
                else:
                    opener = "open" if sys.platform == "darwin" else "xdg-open"
                    subprocess.Popen([opener, folder])

            button = QPushButton(widget)
            button.setText(QCoreApplication.translate('generals', 'Open folder'))
            button.pressed.connect(openFile)
            widget.layout().addWidget(button)
            self.iface.messageBar().pushWidget(widget, level0)
        else:
            self.iface.messageBar().pushMessage(title, msg, level)

    def dbg_info(self, msg):
        if DEBUG:
            QgsMessageLog.logMessage(msg)
