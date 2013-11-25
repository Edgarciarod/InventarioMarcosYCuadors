#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
import psycopg2
import psycopg2.extras
global builder, dialog, db,  MainWin

db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')

class Handler:

    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AceptarButton_clicked(self, button):
        global db, MainWin
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
                           VALUES(%s, %s, %s);""", (int(moldura_id), int(cantidad), float(precio_unitario)))

            except psycopg2.IntegrityError:
                db.rollback()
            else:
                db.commit()
                dialog.set_visible(False)
                builder.get_object("ClaveMoldura_entry").set_text("")
                builder.get_object("PrecioUnitario_entry").set_text("")
                builder.get_object("Cantidad_entry").set_text("")
            dict_cursor.close()
            MainWin.lista.clear()
            MainWin.addTreeView()
        except Exception as e:
            print ('ERROR:', e.args)

    def MainAcceptButton_clicked(self, button):
        global dialog
        #dialog.set_visible(True)

    def MainCancelButton_clicked(self, button):
        global builder, dialog
        tmp = builder.get_object("window2")
        tmp.destroy()
        dialog.destroy()


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
        global builder, dialog, MainWin
        MainWin = self
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevoPedido.glade")
        dialog = builder.get_object("window1")
        builder.connect_signals(Handler())
        self.TreeView = builder.get_object("treeview")
        self.initTreeView()

    def addTreeView(self):
        try:
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                dict_cursor.execute("""
                SELECT e.moldura_id, e.cantidad, e.precio_unitario, m.nombre_moldura,m.clave_interna,m.clave_proveedor
                FROM entrada_almacen as e, maestro_moldura as m
                WHERE e.moldura_id = m.moldura_id;
                """)
                raw_data = list(dict_cursor)
                if(len(raw_data) == 0):
                    return
                for i in raw_data:
                    #print(type(i))
                    j = [i['nombre_moldura'],
                         i['clave_interna'],
                         i['clave_proveedor'],
                         i['cantidad']*64*0.3048,
                         i['cantidad']*64,
                         i['precio_unitario'],
                         i['precio_unitario']/64*3.2808399]
                    j = [str(k) for k in j]
                    self.lista.append(j)
            except psycopg2.IntegrityError:
                print("NOOOO")
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:',type(e) ,e.args)


    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Nombre", render, text = 0),
                   Gtk.TreeViewColumn("Clave Interna", render, text = 1),
                   Gtk.TreeViewColumn("Clave Externa", render, text = 2),
                   Gtk.TreeViewColumn("Cantidad(m)", render, text = 3),
                   Gtk.TreeViewColumn("Cantidad(ft)", render, text = 4),
                   Gtk.TreeViewColumn("Precio por caja", render, text = 5),
                   Gtk.TreeViewColumn("Precio por metro", render, text = 6)]

        self.TreeView.set_model(self.lista)

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)


def NuevoPedido():
    WinNuevoPedido()
    Gtk.main()