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
        clave_interna = builder.get_object("ClaveInternaEntry").get_text()
        cantidad      = builder.get_object("CantidadEntry").get_text()

        try:
            clave_interna = None if clave_interna == "" else str(clave_interna)
            cantidad      = None if cantidad == "" else float(cantidad)

            try:
                cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
                try:
                    cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s", (clave_interna,))
                    datos = list(cursor)
                    if len(datos) > 0:
                        moldura_id = datos[0]['moldura_id']
                    else:
                        raise Exception('No existe la clave %s'%(clave_interna,))

                    cursor.execute("INSERT INTO inventario_temporal(moldura_id, cantidad) VALUES(%s, %s)", (moldura_id, cantidad))
                except Exception as e:
                    db.rollback()
                    Error.Error(str(e))
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
