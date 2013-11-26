#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import Error
import psycopg2
import psycopg2.extras
global builder, db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def Accept_clicked(self, button):
        global builder
        window = builder.get_object("window1")
        window.destroy()


class WinConsultaInventario:
    def __init__(self):
        global builder, MainW, db
        MainW = self

        builder = Gtk.Builder()
        builder.add_from_file("gui/ConsultaInventario.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()

    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, bool)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Clave Interna", render, text = 0),
                   Gtk.TreeViewColumn("Clave Externa", render, text = 1),
                   Gtk.TreeViewColumn("Cantidad (m)", render, text = 2),
                   Gtk.TreeViewColumn("Precio (mxn/m)", render, text = 3),
                   Gtk.TreeViewColumn("Nombre", render, text = 4),
                   Gtk.TreeViewColumn("Descripción", render, text = 5),
                   Gtk.TreeViewColumn("Crítico", render, text = 6)
        ]

        self.TreeView.set_model(self.lista)

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)

        self.addTreeView()

    def addTreeView(self):
        global db
        cursor  = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        cursor.execute("""SELECT inventario_teorico.cantidad, maestro_moldura.clave_interna, maestro_moldura.clave_proveedor,
                       maestro_moldura.nombre_moldura, maestro_moldura.descripcion, maestro_moldura.precio_unitario,
                       maestro_moldura.punto_reorden
                       FROM inventario_teorico, maestro_moldura
                       WHERE inventario_teorico.moldura_id = maestro_moldura.moldura_id
                       ORDER BY maestro_moldura.clave_interna, maestro_moldura.nombre_moldura""")
        for row in cursor:
            clave_interna   = str(row['clave_interna'])
            clave_proveedor = str(row['clave_proveedor'])
            cantidad        = str(row['cantidad'])
            precio          = str(row['precio_unitario'])
            nombre          = str(row['nombre_moldura'])
            descripcion     = str(row['descripcion'])
            punto_critico   = row['punto_reorden']
            critico         = True if row['cantidad'] < punto_critico else False

            self.lista.append([clave_interna, clave_proveedor, cantidad, precio, nombre, descripcion, critico])

        db.commit()
        cursor.close()

def ConsultaInventario():
    global db
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')
    WinConsultaInventario()
    Gtk.main()
