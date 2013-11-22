#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk
global builder

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def AgregarButton_clicked(self, button):
        global builder
        folioEntry = builder.get_object("FolioEntry")
        print(type(folioEntry))
        folio = folioEntry.get_text()
        print (folio)
        print ("lala")

    def CancelarButton_clicked(self, button):
        pass

class WinNuevaOrden:
    def __init__(self):
        global builder
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaOrden.glade")
        builder.connect_signals(Handler())

def NuevaOrden():
    WinNuevaOrden()
    Gtk.main()