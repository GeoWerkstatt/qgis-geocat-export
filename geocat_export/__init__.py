from .GeocatExportPlugin import GeocatExportPlugin

def classFactory(iface):
    return GeocatExportPlugin(iface)
