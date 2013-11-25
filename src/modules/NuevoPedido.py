#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
import psycopg2
import psycopg2.extras
global builder, dialog, db

db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')

class Handler:

    def AceptarButton_clicked(self, button):
        global db
        try:
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                clave_moldura = builder.get_object("ClaveMoldura_entry").get_text()
                cantidad = builder.get_object("Cantidad_entry").get_text()
                precio_unitario = builder.get_object("PrecioUnitario_entry").get_text()

                dict_cursor.execute("""SELECT moldura_id FROM maestro_moldura
                                    WHERE clave_interna = %s or  clave_proveedor = %s;""",
                                    (clave_moldura, clave_moldura))

                for i in dict_cursor:
                    moldura_id = i['moldura_id']

                dict_cursor.execute("""INSERT INTO entrada_almacen (moldura_id, cantidad, precio_unitario)
                           VALUES(%s, %s, %s);""", (moldura_id, cantidad, precio_unitario))
            except psycopg2.IntegrityError:
                db.rollback()
            else:
                db.commit()
                dialog.set_visible(False)
                builder.get_object("ClaveMoldura_entry").set_text("")
                builder.get_object("PrecioUnitario_entry").set_text("")
                builder.get_object("Cantidad_entry").set_text("")
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args)

    def MainAcceptButton_clicked(self, button):
        global dialog
        #dialog.set_visible(True)

    def MainAddButton_clicked(self, button):
        global dialog
        dialog.set_visible(True)

    def CancelarButton_clicked(self, button):
        global builder
        dialog.set_visible(False)
        builder.get_object("ClaveMoldura_entry").set_text("")
        builder.get_object("PrecioUnitario_entry").set_text("")
        builder.get_object("Cantidad_entry").set_text("")

class WinNuevoPedido:
    def __init__(self):
        global builder, dialog
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevoPedido.glade")
        dialog = builder.get_object("window1")
        builder.connect_signals(Handler())


def NuevoPedido():
    WinNuevoPedido()
    Gtk.main()