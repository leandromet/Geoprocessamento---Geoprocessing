#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        Copia selecionados no txt
# Purpose:  copiar arquivos que tenham uma string em seu nome
# Author:      leandro.biondo
#
# Created:     06/03/2014
# Copyright:   (c) leandro.biondo 2014
# Licence:     GNU
#-------------------------------------------------------------------------------


# importar modulos

import datetime
import os, glob
import os.path
import fileinput
import sys
import string
import shutil





hoje = datetime.datetime.today()
print hoje.strftime('Executado %Y/%m/%d %H:%M:%S')
conta=0
#Laco que encontra todos os arquivos TIF a serem processados
for infile in open(r"C:\Biondo\ALOS_PRODES\cenas_interesse_restante_lista08.txt"):
                infile = infile.replace("\n","")
                print infile
                entra = glob.glob(r"U:\imagens\ALOS\brasil_jaxa\PALSAR_FBD_ORT_2007\*"+infile+"*")
                for item in entra:
                    print item
#Verifica arquivo de entrada, cria arquivo de saida a partir do de entrada
                    shutil.copy(item, r"C:\Biondo\ALOS_PRODES\ALOS_Cenas\interesse_restante")
                
         
sys.exit()

    





#-------------------------------------------------------------------------------
