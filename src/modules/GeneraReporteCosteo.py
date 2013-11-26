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

from datetime import datetime
import locale
import time


def get_data():
    db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')
    data = [['Clave','Nombre','Cantidad(m)','Cantidad(ft)','Precio(m/mxn)','Precio(m/usd)']]
    try:
        dict_cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            dict_cursor.execute("""
            SELECT clave_interna, nombre_moldura, cantidad as cantidad_m, cantidad*3.2808399 as canntidad_ft,
            precio_unitario as precio_m, precio_unitario*(SELECT pesos_a_dolares FROM conversiones) as precio_usd
                FROM inventario_teorico as i, maestro_moldura as m
                WHERE i.moldura_id = m.moldura_id;
            """)
            cur_list = [i for i in dict_cursor]
            k = 1
            total_usd = 0.0
            total_mxn = 0.0
            total_m   = 0.0
            total_ft  = 0.0
            for i in cur_list:
                j = [i['clave_interna'],
                     i['nombre_moldura'],
                     "%.2f"%(i['cantidad_m']),
                     "%.2f"%(i['canntidad_ft']),
                     "%.2f"%(i['precio_m']),
                     "%.2f"%(i['precio_usd'])]
                data.append(j)
                total_usd += i['precio_usd']
                total_mxn += i['precio_m']
                total_m   += i['cantidad_m']
                total_ft  += i['canntidad_ft']
            data.append(["Totales", "", ("%.2f"%(total_m)), ("%.2f"%(total_ft)), ("$ %.2f mxn"%(total_mxn)), ("$ %.2f usd"%(total_usd))])
            #print("holi")
            #print(data)

        except Exception as e:
            print ('ERROR:',type(e) ,e.args)
            db.rollback()
        else:
            db.commit()
        dict_cursor.close()
    except Exception as e:
        print ('ERROR:',type(e) ,e.args)

    return data

def main():
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
    texto = ("El siguiente reporte correspondiente al "+
             time.strftime("%d %b %Y a las %H:%M:%S ")+
             "inidica los niveles de abasto dentro del almacén de"+
             " la empresa Marcos y Cuadros SA de CV "+
             " se genera con fines de uso interno, cualquier mal uso será sancionado."
    )
    texto_largo = texto
    #texto_largo=texto*100
    P = Paragraph(texto_largo,style)
    story.append(P)
    story.append(Spacer(0,12))
    data = get_data()
    cord = len(data)-1
    GRID_STYLE = TableStyle(
            [('GRID', (0,0), (-1,-2), 0.25, colors.black),
             ('ALIGN', (1,1), (-1,-1), 'RIGHT'),
             ('BOX',(-1,-1), (-1,-1), 1.0, colors.red)
            ])
    t = Table(data, colWidths=None, rowHeights=None, style=GRID_STYLE)
    #print(data)
    story.append(t)
    doc=SimpleDocTemplate("reportes/"+time.strftime("%d_%b_%Y_%H_%M_%S.pdf"),pagesize=A4,showBoundary=1)
    print("reportes/"+time.strftime("%d_%b_%Y_%H_%M_%S.pdf"), end='')
    doc.build(story)




if __name__ == "__main__":
    main()