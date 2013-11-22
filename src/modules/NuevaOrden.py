#! /usr/bin/env python3
# -*- encoding: utf-8 -*-

from gi.repository import Gtk

class MainWin:
    def __init__(self):
        builder = Gtk.Builder()
        builder.add_from_file("gui/NuevaOrden.glade")
        builder.connect_signals(Handler())


def NuevaMoldura():
    MainWin()
    Gtk.main()