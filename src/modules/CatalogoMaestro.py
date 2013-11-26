#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import NuevaMolduraCatalogoMaestro, EditarMolduraCatalogoMaestro, Error
import psycopg2
import psycopg2.extras
global db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)


    def NuevaMoldura_clicked(self, button):
        NuevaMolduraCatalogoMaestro.NuevaMolduraCatalogoMaestro()
        MainW.lista.clear()
        WinCatalogoMaestro.addTreeView(MainW)


    def Editar_clicked(self, button):
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            clave_interna = list(model[iter])[1]
            EditarMolduraCatalogoMaestro.EditarMolduraCatalogoMaestro(clave_interna)
            MainW.lista.clear()
            WinCatalogoMaestro.addTreeView(MainW)

    def Activate_clicked(self, button):
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            print ("Entró")
            clave_interna = list(model[iter])[1]
            cursor = db.cursor()
            cursor.execute("UPDATE maestro_moldura SET activo = TRUE WHERE clave_interna = %s", (clave_interna,))
            MainW.lista.clear()
            WinCatalogoMaestro.addTreeView(MainW)
            db.commit()


    def Desactivate_clicked(self, button):
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            clave_interna = list(model[iter])[1]
            cursor = db.cursor()
            cursor.execute("UPDATE maestro_moldura SET activo = FALSE WHERE clave_interna = %s", (clave_interna,))
            MainW.lista.clear()
            WinCatalogoMaestro.addTreeView(MainW)
            db.commit()


class WinCatalogoMaestro:
    def __init__(self):
        global builder, MainW, db
        MainW = self

        builder = Gtk.Builder()
        builder.add_from_file("gui/CatalogoMaestro.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()


    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("ID", render, text = 0),
                   Gtk.TreeViewColumn("Clave Interna", render, text = 1),
                   Gtk.TreeViewColumn("Clave Externa", render, text = 2),
                   Gtk.TreeViewColumn("Nombre", render, text = 3),
                   Gtk.TreeViewColumn("Precio Unitario (mxn/m)", render, text = 4),
                   Gtk.TreeViewColumn("Ancho Moldura (m)", render, text = 5),
                   Gtk.TreeViewColumn("Punto Reorden (m)", render, text = 6),
                   Gtk.TreeViewColumn("Descripción", render, text = 7),
                   Gtk.TreeViewColumn("Activo", render, text = 8)]

        self.TreeView.set_model(self.lista)
        self.addTreeView()

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)


    def addTreeView(self):
        cursor  = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        cursor.execute("SELECT * FROM maestro_moldura ORDER BY clave_interna, nombre_moldura")
        for row in cursor:
            id            = str(row['moldura_id'])
            clave_interna = str(row['clave_interna'])
            clave_externa = str(row['clave_proveedor'])
            precio        = str(row['precio_unitario'])
            ancho_moldura = str(row['ancho_moldura'])
            punto_reorden = str(row['punto_reorden'])
            nombre        = str(row['nombre_moldura'])
            descripcion   = str(row['descripcion'])
            activo        = str(row['activo'])
            self.lista.append([id, clave_interna, clave_externa, nombre, precio, ancho_moldura, punto_reorden, descripcion, activo])

        db.commit()
        cursor.close()

def CatalogoMaestro():
    global db
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')
    WinCatalogoMaestro()
    Gtk.main()
