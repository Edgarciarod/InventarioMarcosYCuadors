#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
import psycopg2
import psycopg2.extras

global builder, db

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AgregarButton_clicked(self, button):
        global builder, db
        FolioEntry = builder.get_object("FolioEntry")
        ClaveMolduraEntry = builder.get_object("ClaveMolduraEntry")
        CantBaseEntry = builder.get_object("CantBaseEntry")
        CantAlturaEntry = builder.get_object("CantAlturaEntry")
        IDTiendaEntry = builder.get_object("IDTiendaEntry")

        folio = FolioEntry.get_text()
        tienda = IDTiendaEntry.get_text()
        base = CantBaseEntry.get_text()
        altura = CantAlturaEntry.get_text()

        try:
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                clave = ClaveMolduraEntry.get_text()
                dict_cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %(str)s", {'str':clave})

                for i in dict_cursor:
                    moldura_id = i['moldura_id']

                print(folio, tienda, base, altura, moldura_id)

                dict_cursor.execute("""INSERT INTO
                                    orden_salida_moldura(folio, tienda_id, base_marco, altura_marco, moldura_id)
                                    VALUES(%s, %s, %s, %s, %s)""",
                                    (int(folio), int(tienda), float(base), float(altura), int(moldura_id)));
            except (psycopg2.IntegrityError, UnboundLocalError, ValueError):
                db.rollback()
            else:
                db.commit()
                window = builder.get_object("window1")
                window.destroy()
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args, type(e))

    def CancelarButton_clicked(self, button):
        window = builder.get_object("window1")
        window.destroy()

class WinNuevaOrden:
    def __init__(self):
        global builder
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaOrden.glade")
        builder.connect_signals(Handler())

def NuevaOrden():
    global db
    WinNuevaOrden()
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    Gtk.main()