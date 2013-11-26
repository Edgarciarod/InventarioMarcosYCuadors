from gi.repository import Gtk
from modules import Error
import psycopg2
import psycopg2.extras
global db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)


    def AddMoldura_clicked(self, button):
        global builder, db

        clave_interna   = builder.get_object("ClaveInternaEntry").get_text()
        clave_proveedor = builder.get_object("ClaveProveedorEntry").get_text()
        precio_unitario = builder.get_object("PrecioUnitarioEntry").get_text()
        ancho_moldura   = builder.get_object("AnchoMolduraEntry").get_text()
        punto_reorden   = builder.get_object("PuntoReordenEntry").get_text()
        nombre          = builder.get_object("NombreEntry").get_text()
        descripcion     = builder.get_object("DescripcionEntry").get_text()

        try:
            precio_unitario = None if precio_unitario == "" else float(precio_unitario)
            ancho_moldura   = None if ancho_moldura == "" else float(ancho_moldura)
            punto_reorden   = None if punto_reorden == "" else float(punto_reorden)
            clave_interna   = None if clave_interna == "" else str(clave_interna)
            clave_proveedor = None if clave_proveedor == "" else str(clave_proveedor)

            try:
                cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
                try:
                    cursor.execute("""INSERT INTO maestro_moldura(clave_interna, clave_proveedor, precio_unitario,
                                                                  ancho_moldura, punto_reorden, nombre_moldura, descripcion)
                                   VALUES(%s, %s, %s, %s, %s, %s, %s)""",
                                   (clave_interna, clave_proveedor, precio_unitario, ancho_moldura, punto_reorden,
                                    nombre, descripcion)
                    )
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
        except Exception as e:
            Error.Error(str(e))


    def Cancel_clicked(self, button):
        window = builder.get_object("window1")
        window.destroy()

class WinNuevaMolduraCatalogoMaestro:
    def __init__(self):
        global builder

        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaMolduraCatalogoMaestro.glade")
        builder.connect_signals(Handler())

def NuevaMolduraCatalogoMaestro():
    global db
    WinNuevaMolduraCatalogoMaestro()
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    Gtk.main()
