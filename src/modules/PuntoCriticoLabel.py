from gi.repository import Gtk
import psycopg2
import psycopg2.extras

class PuntoCritico():
    def __init__(self, label):
        db = psycopg2.connect(database = 'Almacen',
                              user = 'postgres',
                              password = 'homojuezhomojuezhomojuez',
                              port = '5432',
                              host = '127.0.0.1')

        cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute("SELECT existe_critico FROM bandera")
        datos = list(cursor)
        critico = datos[0]['existe_critico']
        total = 0

        if critico == True:
            cursor.execute("""SELECT inventario_teorico.cantidad, maestro_moldura.punto_reorden
                            FROM inventario_teorico, maestro_moldura
                            WHERE inventario_teorico.moldura_id = maestro_moldura.moldura_id"""
            )
            for row in cursor:
                if row['cantidad'] <= row['punto_reorden']:
                    total += 1

            label.set_markup('<span color = "red">%s</span>'%total)
            print("hace algo")
        else:
            label.set_markup('<span color = "#0C9E16">0</span>')
            print("no hace algo")

        cursor.close()
        db.commit()#¬¬