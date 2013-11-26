#! /usr/bin/env python
# -*- encoding: utf-8 -*-
from __future__ import print_function
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.platypus import Spacer, SimpleDocTemplate, Table, TableStyle
from reportlab.platypus import Paragraph, Image
from reportlab.lib import colors
import psycopg2
import psycopg2.extras
import subprocess

from datetime import datetime
import locale
import time

def main():

    db = psycopg2.connect(database = 'Almacen',
                          user = 'postgres',
                          password = 'homojuezhomojuezhomojuez',
                          port = '5432',
                          host = '127.0.0.1')

    styleSheet = getSampleStyleSheet()
    story = []
    h2 = styleSheet['Heading2']
    h2.pageBreakBefore=0
    h2.keepWithNext=1
    P = Paragraph("Reporte de Costeo",h2)
    story.append(P)
    style = styleSheet['BodyText']
    #locale.setlocale(locale.LC_TIME, "es_MX")
    #locale.nl_langinfo(locale.LC_TIME,"es_MX")
    texto = ("El siguiente reporte correspondiente a "+
             time.strftime("%d %b %Y a las %H:%M:%S ")+
             "muestra la cantidad de moldura dentro del Inventario Teorico, "+
             "Inventario Temporal y la diferencia entre ambos, "+
             "además de la cantidad de Desperdicio de"
             " la empresa Marcos y Cuadros SA de CV"+
             ".Se genera con fines de uso interno, cualquier mal uso será sancionado."
    )
    texto_largo = texto
    #texto_largo=texto*100
    P = Paragraph(texto_largo,style)
    story.append(P)
    story.append(Spacer(0,12))

    cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cursor.execute("SELECT * FROM desp_plus_comp_teor_temp()")

    data = [["Moldura ID", "Inventario Teórico", "Inventario Temporal", "Diferencia", "Cantidad Desperdicio"]]
    for row in cursor:
        data.append([row['moldura_id'], row['teo_cant'], row['temp_cant'], row['diferencia'], row['desp']])

    cord = len(data)-1
    GRID_STYLE = TableStyle(
            [('GRID', (0,0), (-1,-1), 0.25, colors.black),
             ('ALIGN', (1,1), (-1,-1), 'RIGHT')
            ])
    t = Table(data, colWidths=None, rowHeights=None, style=GRID_STYLE)
    #print(data)
    story.append(t)
    doc=SimpleDocTemplate("./ReporteInventario/Comparacion"+time.strftime("%d_%b_%Y_%H_%M_%S.pdf"),pagesize=A4,showBoundary=1)
    print("./ReporteInventario/Comparacion"+time.strftime("%d_%b_%Y_%H_%M_%S.pdf"), end='')
    doc.build(story)

    cursor.close()
    db.commit()


if __name__ == "__main__":
    #print("mamamam")
    main()