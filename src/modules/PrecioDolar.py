from gi.repository import Gtk
import psycopg2
import psycopg2.extras

global builder, entry, db

db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def apply_clicked(self, button):
        global builder, entry, db
        window = builder.get_object("window1")

        try:
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                dolar_value = entry.get_text()
                dolar_value = float(dolar_value)
                dolares_to_pesos = dolar_value
                pesos_to_dolares = 1.0/dolar_value
                dict_cursor.execute("""
                        UPDATE  conversiones
                        SET(dolares_a_pesos, pesos_a_dolares, ultima_actualizacion)
                        = (%s, %s, CURRENT_TIMESTAMP);""",
                        (float(dolares_to_pesos), float(pesos_to_dolares)))
            except psycopg2.IntegrityError:
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args)

        window.destroy()


class WinDolar:
    def __init__(self):
        global builder, entry

        builder = Gtk.Builder()
        builder.add_from_file("gui/PrecioDolar.glade")
        builder.connect_signals(Handler())

        entry = builder.get_object("DolarEntry")


def PrecioDolar():
    WinDolar()
    Gtk.main()