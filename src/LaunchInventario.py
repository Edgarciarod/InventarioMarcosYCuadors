#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
from modules import NuevaOrden, NuevoPedido, NewInventario, CatalogoMaestro, ReportarMerma, ConsultaInventario, Error
from modules import TipoDeCambio
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


    def ProcesarOrden(self, button):
        global db
        (model, iter) = MainW.TreeView.get_selection().get_selected()

        if iter != None:
            datos = list(model[iter])
            folio  = int(datos[0])
            estado = int(datos[7])
            clave_moldura = datos[1]
            total = float(datos[5])


            if estado == 0:
                dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

                dict_cursor.execute("SELECT moldura_id FROM maestro_moldura WHERE clave_interna = %s",(clave_moldura,))
                for i in dict_cursor:
                    moldura_id = i['moldura_id']

                dict_cursor.execute("SELECT cantidad FROM inventario_teorico WHERE moldura_id = %s",(moldura_id,))
                for i in dict_cursor:
                    cantidad = i['cantidad']

                try:
                    if total <= cantidad:
                        dict_cursor.execute("UPDATE orden_salida_moldura SET estado = 1, fecha_procesado = now() WHERE folio = %s",(folio,))
                        db.commit()
                        MainW.lista.clear()
                        MainWin.addTreeView(MainW)
                except Exception as e:
                    Error.Error(str(e))

                db.commit()
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


    def CapturarPedido(self, button):
        NuevoPedido.NuevoPedido()


    def CatalogoMaestro(self, button):
        CatalogoMaestro.CatalogoMaestro()


    def ReportarMerma(self, button):
        ReportarMerma.ReportarMerma()


    def ConsultaInventario(self, button):
        ConsultaInventario.ConsultaInventario()

class MainWin:
    def __init__(self):
        global MainW
        MainW = self
        builder = Gtk.Builder()

        builder.add_from_file("gui/Inicio.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()
        cambio_del_dia = TipoDeCambio.TipoDeCambio()
        cambio_del_dia.actualizar()
        actualizado_label = builder.get_object("ActualizadoLabel")

        if not cambio_del_dia.is_actualizado():
            actualizado_label.set_markup('<span color = "red">No actualizado</span>')
        else:
            actualizado_label.set_markup('<span color = "#0C9E16">Actualizado</span>')


    def addTreeView(self):
        global db

        dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        dict_cursor.execute("""SELECT folio, base_marco, altura_marco, estado, fecha_recepcion, fecha_procesado, tienda_id,
                               clave_interna, nombre_moldura
                               FROM orden_salida_moldura, maestro_moldura
                               WHERE orden_salida_moldura.moldura_id = maestro_moldura.moldura_id
                               ORDER BY estado, fecha_recepcion, fecha_procesado""")

        for row in dict_cursor:
            folio  = row['folio']
            clave  = row['clave_interna']
            nombre = row['nombre_moldura']
            base   = row['base_marco']
            altura = row['altura_marco']
            total  = base*2 + altura*2

            dict_cursor.execute("SELECT direccion FROM tienda WHERE tienda_id = %s",(row['tienda_id'],))
            for i in dict_cursor:
                tienda = i['direccion']

            estado    = row['estado']
            fecha_rec = str(row['fecha_recepcion']).split('.')[0]
            fecha_pro = str(row['fecha_procesado']).split('.')[0]

            datos = [("%6d"%(folio)).replace(' ', '0'), str(clave), str(nombre), str(base), str(altura), str(total), str(tienda), str(estado), str(fecha_rec), str(fecha_pro)]
            self.lista.append(datos)

        db.commit()
        dict_cursor.close()

    def initTreeView(self):

        self.lista = Gtk.ListStore(str, str, str, str, str, str, str, str, str, str)
        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Folio", render, text = 0),
                   Gtk.TreeViewColumn("Clave Interna", render, text = 1),
                   Gtk.TreeViewColumn("Nombre", render, text = 2),
                   Gtk.TreeViewColumn("Base (m)", render, text = 3),
                   Gtk.TreeViewColumn("Altura (m)", render, text = 4),
                   Gtk.TreeViewColumn("Total (m)", render, text = 5),
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
