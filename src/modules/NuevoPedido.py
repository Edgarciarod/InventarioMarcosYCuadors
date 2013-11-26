#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import Error
import psycopg2
import psycopg2.extras
from modules import TipoDeCambio
global builder, dialog, db,  MainWin, model, iter

db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')


class Handler:
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

            except Exception as e:
                Error.Error(str(e))
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
            Error.Error(str(e))
            print ('ERROR:', e.args)

    def MainAcceptButton_clicked(self, button):
        global builder, dialog
        tmp = builder.get_object("window2")
        tmp.destroy()
        tmp = builder.get_object("window3")
        tmp.destroy()
        dialog.destroy()

        try:
            dict_cursor = db.cursor()
            try:
                dict_cursor.execute("SELECT actualizar_nuevo_material(%s);",
                                    (float(TipoDeCambio.TipoDeCambio().get_usd_to_mxn()),))
                dict_cursor.execute("TRUNCATE entrada_almacen;")
            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:',type(e) ,e.args)


    def MainCancelButton_clicked(self, button):
        global builder, dialog
        tmp = builder.get_object("window2")
        tmp.destroy()
        tmp = builder.get_object("window3")
        tmp.destroy()
        dialog.destroy()
        try:
            dict_cursor = db.cursor()
            try:
                dict_cursor.execute("TRUNCATE entrada_almacen;")
            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:',type(e) ,e.args)


    def MainAddButton_clicked(self, button):
        global dialog
        dialog.set_visible(True)


    def MainEditButton_clicked(self, button):
        global MainWin, db, builder, model, iter
        #global dialog
        dialog = builder.get_object("window3")
        try:
            (model, iter) = MainWin.TreeView.get_selection().get_selected()
            row = []
            if iter != None:
                row = list(model[iter])
                #print(row)
                builder.get_object("ClaveMolduraEdit_entry").set_text(row[1])
                builder.get_object("ClaveMolduraEdit_entry").set_editable(False)
                builder.get_object("PrecioUnitarioEdit_entry").set_text(row[5])
                builder.get_object("CantidadEdit_entry").set_text("%.0f"%(float(row[4])/64))
                dialog.set_visible(True)
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:', e.args)

    def AcceptOnEditButton_clicked(self,button):
        global db, MainWin, builder
        try:
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                clave_moldura = builder.get_object("ClaveMolduraEdit_entry").get_text()
                cantidad = builder.get_object("CantidadEdit_entry").get_text()
                precio_unitario = builder.get_object("PrecioUnitarioEdit_entry").get_text()

                dict_cursor.execute("""SELECT moldura_id FROM maestro_moldura
                                    WHERE clave_interna = %s or  clave_proveedor = %s;""",
                                    (clave_moldura, clave_moldura))

                for i in dict_cursor:
                    moldura_id = i['moldura_id']

                dict_cursor.execute("""UPDATE entrada_almacen
                           SET cantidad = %s,  precio_unitario = %s
                           WHERE moldura_id = %s ;""", (int(cantidad), float(precio_unitario), int(moldura_id)))


            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
                dialog = builder.get_object("window3")
                dialog.set_visible(False)
                builder.get_object("ClaveMoldura_entry").set_text("")
                builder.get_object("PrecioUnitario_entry").set_text("")
                builder.get_object("Cantidad_entry").set_text("")
            dict_cursor.close()
            MainWin.lista.clear()
            MainWin.addTreeView()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:', e.args, type(e))

    def CancelOnEditButton_clicked(self,button):
        global  builder
        dialog = builder.get_object("window3")
        dialog.set_visible(False)

    def MainDeleteButton_clicked(self,button):
        global db, MainWin, builder
        try:
            (model, iter) = MainWin.TreeView.get_selection().get_selected()
            row = []
            if iter != None:
                row = list(model[iter])
            else:
                print("Not found :(")
            dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                clave_moldura = row[1]
                dict_cursor.execute("""SELECT moldura_id FROM maestro_moldura
                                    WHERE clave_interna = %s or  clave_proveedor = %s;""",
                                    (clave_moldura, clave_moldura))

                for i in dict_cursor:
                    moldura_id = i['moldura_id']


                dict_cursor.execute("""DELETE FROM entrada_almacen
                           WHERE moldura_id = %s ;""", ( int(moldura_id), ))


            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
            MainWin.lista.clear()
            MainWin.addTreeView()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:', e.args, type(e))

    def CancelarButton_clicked(self, button):
        global builder
        dialog.set_visible(False)
        builder.get_object("ClaveMoldura_entry").set_text("")
        builder.get_object("PrecioUnitario_entry").set_text("")
        builder.get_object("Cantidad_entry").set_text("")

class WinNuevoPedido:
    def __init__(self):
        global builder, dialog, MainWin,db
        MainWin = self
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevoPedido.glade")
        dialog = builder.get_object("window1")
        builder.connect_signals(Handler())
        self.TreeView = builder.get_object("treeview")
        self.initTreeView()
        #self.addTreeView()
        try:
            dict_cursor = db.cursor()
            try:
                dict_cursor.execute("TRUNCATE entrada_almacen;")
            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:',type(e) ,e.args)

    def addTreeView(self):
        cam = TipoDeCambio.TipoDeCambio()
        print(cam.get_mxn_to_usd())

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
                         "%.2f"%(i['cantidad']*64*0.3048),
                         "%d"%(i['cantidad']*64),
                         "%.2f"%(i['precio_unitario']),
                         "%.2f"%(i['precio_unitario']/64*3.2808399),
                         "%.2f"%((i['precio_unitario']/64*3.2808399)*cam.get_usd_to_mxn())]

                    self.lista.append(j)
            except Exception as e:
                Error.Error(str(e))
                db.rollback()
            else:
                db.commit()
            dict_cursor.close()
        except Exception as e:
            Error.Error(str(e))
            print ('ERROR:',type(e) ,e.args)


    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Nombre", render, text = 0),
                   Gtk.TreeViewColumn("Clave Interna", render, text = 1),
                   Gtk.TreeViewColumn("Clave Externa", render, text = 2),
                   Gtk.TreeViewColumn("Cantidad(m)", render, text = 3),
                   Gtk.TreeViewColumn("Cantidad(ft)", render, text = 4),
                   Gtk.TreeViewColumn("Precio por caja(USD)", render, text = 5),
                   Gtk.TreeViewColumn("Precio por metro(USD)", render, text = 6),
                   Gtk.TreeViewColumn("Precio por metro(MXN)", render, text = 7)]

        self.TreeView.set_model(self.lista)

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)


def NuevoPedido():
    WinNuevoPedido()
    Gtk.main()
    db.close()
    tmp = builder.get_object("window1")
    tmp.destroy()
    tmp = builder.get_object("window2")
    tmp.destroy()
    tmp = builder.get_object("window3")
    tmp.destroy()
    Gtk.main_quit()