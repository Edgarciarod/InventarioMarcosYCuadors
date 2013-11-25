from gi.repository import Gtk
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
        precio_unitario = float(builder.get_object("PrecioUnitarioEntry").get_text())
        ancho_moldura   = float(builder.get_object("AnchoMolduraEntry").get_text())
        punto_reorden   = float(builder.get_object("PuntoReordenEntry").get_text())
        nombre          = builder.get_object("NombreEntry").get_text()
        descripcion     = builder.get_object("DescripcionEntry").get_text()

        try:
            cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                cursor.execute("""INSERT INTO maestro_moldura(clave_interna, clave_proveedor, precio_unitario,
                                                              ancho_moldura, punto_reorden, nombre_moldura, descripcion)
                               VALUES(%s, %s, %s, %s, %s, %s, %s)""",
                               (clave_interna, clave_proveedor, precio_unitario, ancho_moldura, punto_reorden,
                                nombre, descripcion)
                )
            except (psycopg2.IntegrityError, UnboundLocalError, ValueError):
                db.rollback()
            else:
                db.commit()
                window = builder.get_object("window1")
                window.destroy()
            cursor.close()
        except Exception as e:
            print ('ERROR:', e.args, type(e))


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
