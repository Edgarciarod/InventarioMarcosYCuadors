from gi.repository import Gtk
from modules import Error
import psycopg2
import psycopg2.extras
global db, MainW, clave_interna

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AddMoldura_clicked(self, button):
        global builder, db

        nombre      = builder.get_object("NombreEntry").get_text()
        descripcion = builder.get_object("DescripcionEntry").get_text()

        if nombre == "":
            nombre = None
        if descripcion == "":
            descripcion = None

        try:
            cursor = db.cursor()
            try:
                cursor.execute("UPDATE maestro_moldura SET nombre_moldura = %s, descripcion = %s WHERE clave_interna = %s",
                               (nombre, descripcion, clave_interna))
            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
                window = builder.get_object("window1")
                window.destroy()
            cursor.close()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:', e.args, type(e))

    def Cancel_clicked(self, button):
        window = builder.get_object("window1")
        window.destroy()

class WinEditarMolduraCatalogoMaestro:
    def __init__(self):
        global builder, db

        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaMolduraCatalogoMaestro.glade")
        builder.connect_signals(Handler())

        cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        ClaveInternaEntry   = builder.get_object("ClaveInternaEntry")
        ClaveProveedorEntry = builder.get_object("ClaveProveedorEntry")
        PrecioUnitarioEntry = builder.get_object("PrecioUnitarioEntry")
        AnchoMolduraEntry   = builder.get_object("AnchoMolduraEntry")
        PuntoReordenEntry   = builder.get_object("PuntoReordenEntry")
        NombreEntry         = builder.get_object("NombreEntry")
        DescripcionEntry    = builder.get_object("DescripcionEntry")

        ClaveInternaEntry.set_editable(False)
        ClaveProveedorEntry.set_editable(False)
        PrecioUnitarioEntry.set_editable(False)
        AnchoMolduraEntry.set_editable(False)
        PuntoReordenEntry.set_editable(False)

        cursor.execute("""SELECT clave_proveedor, precio_unitario, ancho_moldura, punto_reorden, nombre_moldura, descripcion
                       FROM maestro_moldura WHERE clave_interna = %s""", (clave_interna,)
                      )

        datos = list(cursor)

        ClaveInternaEntry.set_text(clave_interna)
        ClaveProveedorEntry.set_text(datos[0]['clave_proveedor'])
        PrecioUnitarioEntry.set_text(str(datos[0]['precio_unitario']))
        AnchoMolduraEntry.set_text(str(datos[0]['ancho_moldura']))
        PuntoReordenEntry.set_text(str(datos[0]['punto_reorden']))
        if datos[0]['nombre_moldura'] != None:
            NombreEntry.set_text(datos[0]['nombre_moldura'])
        if datos[0]['descripcion'] != None:
            DescripcionEntry.set_text(datos[0]['descripcion'])

        db.commit()
        cursor.close()


def EditarMolduraCatalogoMaestro(clave):
    global db, clave_interna

    clave_interna = clave

    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    WinEditarMolduraCatalogoMaestro()
    Gtk.main()

