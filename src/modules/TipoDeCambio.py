#! /usr/bin/env pyton3
# -*- encoding: utf-8 -*-

import time
import psycopg2
import psycopg2.extras
from urllib.request import urlopen
import json

class TipoDeCambio:
    def __init__(self):
        self.db = psycopg2.connect(database='Almacen',
                        user='postgres',
                        password='homojuezhomojuezhomojuez',
                        port='5432',
                        host='127.0.0.1')
        self.fecha_actulizacion = None
        self.pesos_to_dolares = None
        self.dolares_to_pesos = None

    def actualizar(self):
        try:
            dict_cursor = self.db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                i = 0
                while True:
                    url = "http://currency-api.appspot.com/api/MXN/USD.json?key=54af78659133eca85c31ed7d3d72f00e4407ed3a"
                    url = urlopen(url)
                    result = url.read().decode('utf-8')
                    url.close()
                    resultado = json.loads(result)
                    if(resultado['success']):
                        self.pesos_to_dolares = resultado['rate']
                        break
                    elif(i <= 2):
                        i += 1
                    else:
                        break

                i = 0
                while True:
                    url = "http://currency-api.appspot.com/api/USD/MXN.json?key=54af78659133eca85c31ed7d3d72f00e4407ed3a"
                    url = urlopen(url)
                    result = url.read().decode('utf-8')
                    url.close()
                    resultado = json.loads(result)
                    if(resultado['success']):
                        self.dolares_to_pesos = resultado['rate']
                        break
                    elif(i <= 2):
                        i += 1
                    else:
                        break
                dict_cursor.execute("""
                        UPDATE  conversiones
                        SET(dolares_a_pesos, pesos_a_dolares, ultima_actualizacion)
                        = (%s, %s, CURRENT_TIMESTAMP);""",
                        (float(self.dolares_to_pesos), float(self.pesos_to_dolares)))
            except psycopg2.IntegrityError:
                self.db.rollback()
            else:
                self.db.commit()
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args)

    def is_actualizado(self):
        flag = True
        try:
            dict_cursor = self.db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                dict_cursor.execute("""
                SELECT (ultima_actualizacion)::date = (CURRENT_TIMESTAMP)::date as flag FROM conversiones ;""")
                flag = list(dict_cursor)[0]['flag']
            except psycopg2.IntegrityError:
                self.db.rollback()
            else:
                self.db.commit()
            dict_cursor.close()
            return flag
        except Exception as e:
            print ('ERROR:', e.args)
            return flag

    def get_mxn_to_usd(self):
        try:
            dict_cursor = self.db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                dict_cursor.execute("""
                SELECT pesos_a_dolares as rate FROM conversiones ;""")
                self.pesos_to_dolares = list(dict_cursor)[0]['rate']
            except psycopg2.IntegrityError:
                self.db.rollback()
            else:
                self.db.commit()
                return self.pesos_to_dolares
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args)

    def get_usd_to_mxn(self):
        try:
            dict_cursor = self.db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            try:
                dict_cursor.execute("""
                SELECT dolares_a_pesos as rate FROM conversiones ;""")
                self.dolares_to_pesos = list(dict_cursor)[0]['rate']
            except psycopg2.IntegrityError:
                self.db.rollback()
            else:
                self.db.commit()
                return self.dolares_to_pesos
            dict_cursor.close()
        except Exception as e:
            print ('ERROR:', e.args)

