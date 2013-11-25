from gi.repository import Gtk
import psycopg2
import psycopg2.extras
global db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AddMoldura_clicked(self, button):
        global builder, db
        ClaveInterna = builder.get_object("ClaveInternaEntry")
        Cantidad     = builder.get_object("CantidadEntry")

        clave_interna = ClaveInterna.get_text()
        cantidad      = Cantidad.get_text()

        try:
            cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s", (clave_interna,))
                datos = list(cursor)
                moldura_id = datos[0]['moldura_id']

                print(moldura_id)

                cursor.execute("INSERT INTO inventario_temporal(moldura_id, cantidad) VALUES(%s, %s)", (moldura_id, float(cantidad)))
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

class WinNuevaMolduraInventario:
    def __init__(self):
        global builder

        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaMolduraInventario.glade")
        builder.connect_signals(Handler())

def NuevaMolduraInventario():
    global db
    WinNuevaMolduraInventario()
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    Gtk.main()
