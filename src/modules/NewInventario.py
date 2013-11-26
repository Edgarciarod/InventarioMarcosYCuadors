#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import NuevaMolduraInventario, EditarMolduraInventario, Error
import psycopg2
import psycopg2.extras
global db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def NuevaMoldura_clicked(self, button):
        NuevaMolduraInventario.NuevaMolduraInventario()
        MainW.lista.clear()
        WinNewInventario.addTreeView(MainW)

    def Editar_clicked(self, button):
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            clave_interna = list(model[iter])[0]
            EditarMolduraInventario.EditarMolduraInventario(clave_interna)
            MainW.lista.clear()
            WinNewInventario.addTreeView(MainW)

    def Eliminar_clicked(self, button):
        cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            clave_interna = list(model[iter])[0]
            cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s", (clave_interna))
            datos = list(cursor)
            moldura_id = datos[0]['moldura_id']
            cursor.execute("DELETE FROM inventario_temporal WHERE moldura_id = %s", (int(moldura_id),))
            MainW.lista.clear()
            WinNewInventario.addTreeView(MainW)

    def Accept_clicked(self, button):
        cursor = db.cursor()
        cursor.execute("TRUNCATE TABLE inventario_real")
        cursor.execute("TRUNCATE TABLE inventario_teorico")
        cursor.execute("SELECT copia_inv_temp()")
        cursor.execute("TRUNCATE TABLE inventario_temporal")
        db.commit()
        window = builder.get_object("window1")
        window.destroy()

    def Cancel_clicked(self, button):
        window = builder.get_object("window1")
        window.destroy()

class WinNewInventario:
    def __init__(self):
        global builder, MainW, db
        MainW = self

        builder = Gtk.Builder()
        builder.add_from_file("gui/CapturarInventario.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()

    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Clave Interna", render, text = 0),
                   Gtk.TreeViewColumn("Clave Externa", render, text = 1),
                   Gtk.TreeViewColumn("Cantidad (m)", render, text = 2),
                   Gtk.TreeViewColumn("Nombre", render, text = 3),
                   Gtk.TreeViewColumn("Descripción", render, text = 4)]

        self.TreeView.set_model(self.lista)

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)

    def addTreeView(self):
        cursor  = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor2 = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        cursor.execute("SELECT moldura_id, cantidad FROM inventario_temporal")
        for row in cursor:
            cursor2.execute("SELECT clave_interna, clave_proveedor, nombre_moldura, descripcion FROM maestro_moldura WHERE moldura_id = %s",(row['moldura_id'],))
            datos = list(cursor2)

            clave_interna   = datos[0]['clave_interna']
            clave_proveedor = datos[0]['clave_proveedor']
            nombre          = datos[0]['nombre_moldura']
            descripcion     = datos[0]['descripcion']
            cantidad        = row['cantidad']

            self.lista.append([str(clave_interna), str(clave_proveedor), str(cantidad), str(nombre), str(descripcion)])

        cursor.close()
        cursor2.close()

def NewInventario():
    global db
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')
    WinNewInventario()
    Gtk.main()
