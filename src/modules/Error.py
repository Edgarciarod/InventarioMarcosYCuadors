from gi.repository import Gtk
import psycopg2
import psycopg2.extras

global builder

class Handler:
    def onDestroyWindow(self, *args):
        Gtk.main_quit(*args)

    def Ok_clicked(self, button):
        global builder
        window = builder.get_object("window1")
        window.destroy()

class WinError:
    def __init__(self, mensaje):
        global builder

        builder = Gtk.Builder()
        builder.add_from_file("gui/Error.glade")
        builder.connect_signals(Handler())

        label = builder.get_object("ErrorLabel")
        label.set_text(mensaje)

def Error(mensaje):
    WinError(mensaje)
    Gtk.main()
