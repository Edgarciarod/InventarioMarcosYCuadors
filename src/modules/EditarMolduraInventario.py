from gi.repository import Gtk
from modules import Error
import psycopg2
import psycopg2.extras
global db, MainW, clave_interna

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AddMoldura_clicked(self, button):
        global builder, db, clave_interna

        CantidadEntry = builder.get_object("CantidadEntry")
        cantidad      = CantidadEntry.get_text()

        try:
            cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s", (clave_interna,))
                datos = list(cursor)
                moldura_id = datos[0]['moldura_id']

                cursor.execute("UPDATE inventario_temporal SET cantidad = %s", (float(cantidad),))
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

class WinEditarMolduraInventario:
    def __init__(self):
        global builder

        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaMolduraInventario.glade")
        builder.connect_signals(Handler())

        claveEntry = builder.get_object("ClaveInternaEntry")
        claveEntry.set_text(clave_interna)
        claveEntry.set_editable(False)

def EditarMolduraInventario(clave):
    global db, clave_interna

    clave_interna = clave
    WinEditarMolduraInventario()
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    Gtk.main()

