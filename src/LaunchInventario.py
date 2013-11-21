#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def onButtonPressed(self, button):
        print( "Hello World!" )


class MainWin:
    def __init__(self):
        builder = Gtk.Builder()

        builder.add_from_file("gui/Inicio.glade")
        builder.connect_signals(Handler())

        self.TreeView = builder.get_object("treeview")
        self.initTreeView()

    def initTreeView(self):
        lista = Gtk.ListStore(int, str, str, float, float, float, int, str)

        render = Gtk.CellRendererText()

        columna = [Gtk.TreeViewColumn("Folio", render, text = 0),
                   Gtk.TreeViewColumn("Clave", render, text = 1),
                   Gtk.TreeViewColumn("Nombre", render, text = 2),
                   Gtk.TreeViewColumn("Base", render, text = 3),
                   Gtk.TreeViewColumn("Altura", render, text = 4),
                   Gtk.TreeViewColumn("Total", render, text = 5),
                   Gtk.TreeViewColumn("Estado", render, text = 6),
                   Gtk.TreeViewColumn("Tienda", render, text = 7)]

        self.TreeView.set_model(lista)

        for col in columna:
            self.TreeView.append_column(col)

if __name__ == "__main__":
    MainWin()
    Gtk.main()
