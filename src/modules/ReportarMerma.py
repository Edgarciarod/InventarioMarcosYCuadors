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
        ClaveInterna = builder.get_object("ClaveInternaEntry")
        Cantidad     = builder.get_object("CantidadEntry")

        clave_interna = ClaveInterna.get_text()
        cantidad      = Cantidad.get_text()

        try:
            cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                cantidad = float(cantidad)
                cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s", (clave_interna,))
                datos = list(cursor)

                if len(datos) == 0:
                    raise Exception('No existe la moldura en el inventario')

                moldura_id = datos[0]['moldura_id']

                cursor.execute("SELECT cantidad FROM inventario_teorico WHERE moldura_id = %s", (moldura_id,))
                datos = list(cursor)

                if len(datos) > 0:
                    cantidad_actual = datos[0]['cantidad']
                    if cantidad <= cantidad_actual:
                        cursor.execute("INSERT INTO inventario_desperdicio(moldura_id, cantidad) VALUES(%s, %s)", (moldura_id, cantidad))
                    else:
                        raise Exception('No hay suficiente cantidad en el inventario')
                else:
                    raise Exception('No existe la moldura en el inventario')
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

class WinReportarMerma:
    def __init__(self):
        global builder

        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaMolduraInventario.glade")
        builder.connect_signals(Handler())

def ReportarMerma():
    global db
    WinReportarMerma()
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    Gtk.main()
