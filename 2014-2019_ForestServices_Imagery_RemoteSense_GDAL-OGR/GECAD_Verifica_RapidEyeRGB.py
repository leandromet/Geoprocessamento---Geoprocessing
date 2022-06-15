#-------------------------------------------------------------------------------
# Name:        Continua funcoes do Extrator de camadas RGB para imagens RapidEye
# Purpose:      Exportar colecao de arquivos de imagem do rapid eye para um novo local, mantendo estrutura de pastas e extraindo apenas as camadas RGB
#
# Author:      leandro.biondo
#
# Created:     02/08/2013
# Copyright:   (c) leandro.biondo 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

# importar modulos

import datetime
import os, glob
import os.path
import fileinput
import sys
import string
import shutil
import arcpy
from arcpy import env
from arcpy import da





#Define funcao para ignorar arquivos na criacao de arvore
#def ig_f(dir, files):
#    return [f for f in files if os.path.isfile(os.path.join(dir, f))]

#Copia estrutura de pastas para onde vao os resultados
#shutil.copytree('U:\\imagens2\\RapidEye\\NORDESTE\\FUSO_22S\\', 'D:\\Biondo\\gcad\\rapideye\\dados\\Teste\\', symlinks=False, ignore=ig_f)
hoje = datetime.datetime.today()
print hoje.strftime('Executado %Y/%m/%d %H:%M:%S')
conta=0
#Laco que encontra todos os arquivos TIF a serem processados
for infile in glob.glob('U:\\imagens2\\RapidEye\\NORDESTE\\FUSO_24S\\*\\*.tif'):
#Ignora arquivos "browse."
    if infile.find("browse.") == -1:
#Ignora arquivos "udm."
        if infile.find("udm.") == -1:
#Verifica arquivo de entrada, cria arquivo de saida a partir do de entrada
                conta+=1
                print conta
                outfile = infile.replace('.tif', 'rgb.tif')
                outfile = outfile.replace('U:\\imagens2\\RapidEye\\NORDESTE\\', 'W:\\IMAGENS\\RapidEye\\NE\\')
#Verifica se pasta da Ginf tem imagem processada
                if os.path.isfile(outfile):
                    print 'saida existe'
                else:
                    print 'Sem arquivo, criando imagem'               
#Extrai apenas as camadas da imagem referentes a bandas RGB
                    arcpy.env.workspace = 'D:\\Biondo\\gcad\\rapideye\\dados\\'
                    arcpy.MakeRasterLayer_management(infile, "layer4.tif", "#", "", "4")
                    arcpy.MakeRasterLayer_management(infile, "layer5.tif", "#", "", "5")
                    arcpy.MakeRasterLayer_management(infile, "layer2.tif", "#", "", "2")
                    print 'camadas extraidas'
#Compoe nova imagem e salva na estrutura criada com nome do arquivo original e um "rgb" no final
                    arcpy.CompositeBands_management("layer4.tif;layer5.tif;layer2.tif",outfile)
                    print 'arquivo criado'

sys.exit()

    





#-------------------------------------------------------------------------------
