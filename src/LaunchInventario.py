#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import NuevaOrden, NewInventario
import psycopg2
import psycopg2.extras
global db, MainW

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def CapturarInventario(self, *args):
        cursor  = db.cursor()
        cursor.execute("TRUNCATE TABLE inventario_temporal")
        db.commit()
        cursor.close()
        NewInventario.NewInventario()

    def NuevaOrdenSalida(self, button):
        NuevaOrden.NuevaOrden()
        MainW.lista.clear()
        MainWin.addTreeView(MainW)
        #MainWin.addTreeView()

    def ProcesarOrden(self, button):
        global db
        (model, iter) = MainW.TreeView.get_selection().get_selected()

        if iter != None:
            folio  = int(list(model[iter])[0])
            estado = int(list(model[iter])[7])
            clave_moldura = list(model[iter])[1]
            total = float(list(model[iter])[5])


            if estado == 0:
                dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

                dict_cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s",(clave_moldura,))
                for i in dict_cursor:
                    moldura_id = i['moldura_id']

                print (moldura_id)

                dict_cursor.execute("SELECT cantidad FROM inventario_teorico WHERE moldura_id = %s",(moldura_id,))

                for i in dict_cursor:
                    cantidad = i['cantidad']

                try:
                    if total <= cantidad:
                        dict_cursor.execute("UPDATE orden_salida_moldura SET estado = 1, fecha_procesado = now() WHERE folio = %s",(folio,))
                        db.commit()
                        MainW.lista.clear()
                        MainWin.addTreeView(MainW)

                except UnboundLocalError:
                    pass

                dict_cursor.close()


    def CancelarOrden(self, button):
        (model, iter) = MainW.TreeView.get_selection().get_selected()
        if iter != None:
            estado = int(list(model[iter])[7])
            folio  = int(list(model[iter])[0])
            if estado == 0:
                dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
                dict_cursor.execute("UPDATE orden_salida_moldura SET estado = 2, fecha_procesado = now() WHERE folio = %s",(folio,))
                MainW.lista.clear()
                MainWin.addTreeView(MainW)
                db.commit()
                dict_cursor.close()


class MainWin:
    def __init__(self):
        global MainW
        MainW = self
        builder = Gtk.Builder()

        builder.add_from_file("gui/Inicio.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()

    def addTreeView(self):
        global db

        dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        dict_cursor.execute("""SELECT folio, moldura_id, base_marco, altura_marco, estado, fecha_recepcion, fecha_procesado, tienda_id
                               FROM orden_salida_moldura ORDER BY estado, fecha_recepcion, fecha_procesado""")

        dict_cursor2 = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        for row in dict_cursor:
            folio = row['folio']
            #print (type(row['moldura_id']))
            dict_cursor2.execute("SELECT clave_interna, nombre_moldura FROM maestro_moldura WHERE moldura_id = %s",(row['moldura_id'],))
            for i in dict_cursor2:
                clave  = i['clave_interna']
                nombre = i['nombre_moldura']
            base   = row['base_marco']
            altura = row['altura_marco']
            total  = base*2 + altura*2

            dict_cursor2.execute("SELECT direccion FROM tienda WHERE tienda_id = %s",(row['tienda_id'],))
            for i in dict_cursor2:
                tienda = i['direccion']

            estado    = row['estado']
            fecha_rec = str(row['fecha_recepcion']).split('.')[0]
            fecha_pro = str(row['fecha_procesado']).split('.')[0]

            datos = [("%6d"%(folio)).replace(' ', '0'), str(clave), str(nombre), str(base), str(altura), str(total), str(tienda), str(estado), str(fecha_rec), str(fecha_pro)]
            self.lista.append(datos)

        dict_cursor.close()
        dict_cursor2.close()

    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Folio", render, text = 0),
                   Gtk.TreeViewColumn("Clave Interna", render, text = 1),
                   Gtk.TreeViewColumn("Nombre", render, text = 2),
                   Gtk.TreeViewColumn("Base", render, text = 3),
                   Gtk.TreeViewColumn("Altura", render, text = 4),
                   Gtk.TreeViewColumn("Total", render, text = 5),
                   Gtk.TreeViewColumn("Tienda", render, text = 6),
                   Gtk.TreeViewColumn("Estado", render, text = 7),
                   Gtk.TreeViewColumn("Fecha Recibido", render, text = 8),
                   Gtk.TreeViewColumn("Fecha Procesado", render, text = 9)]

        self.TreeView.set_model(self.lista)
        self.addTreeView()

        for col in columna:
            col.set_resizable(True)
            self.TreeView.append_column(col)

if __name__ == "__main__":
    global db
    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')
    MainWin()
    Gtk.main()
