# -*- coding: cp1252 -*-
#-------------------------------------------------------------------------------
# Name:        Glovis GRID
# Purpose:     Creates a GRID based on GLOVIS descriptor
#
# Author:      leandro.biondo
#
# Created:     23/10/2013
# Copyright:   (c) leandro.biondo 2013
# Licence:     GPL
#-------------------------------------------------------------------------------
#!/usr/bin/env python

# importar modulo

import ogr
import os, glob
import shutil
import osr
import gdal

c=0

Print = 'Indice: NomeArquivo : Coordenadas LT,RT,RB,LB; (Lat,Lon)'
Indice = {}
IndiceProd = {}
IndiceZona = {}

#loop para percorrer todas as pastas, extrair os nomes dos arquivos, criar
#novas pastas e mover arquivos dos locais originais para os locais novos
for infile in glob.glob("/home/leandro/GLOVIS/*MTL.*"):
    print infile
    f = open(infile, 'r')
#Abre descritivo da imagem
    workreport = f.read()
    PosicF = workreport.find('LANDSAT_SCENE_ID =')
    f.seek(PosicF+20)
    ProdAlos = f.read(21)
    nomearquivo=ProdAlos
    print nomearquivo
    PosicF = workreport.find('UTM_ZONE')
    f.seek(PosicF+11)
    ZonaUTM = f.read(2)
#Coordenada Superior Esquerda
    PosicF = workreport.find('CORNER_UL_LAT_PRODUCT')
    f.seek(PosicF+24)
    Lat = f.read(10)
    PosicF = workreport.find('CORNER_UL_LON_PRODUCT')
    f.seek(PosicF+24)
    Lon = f.read(10)
    CoordLT = [Lat.strip(),Lon.strip()]
#Coordenada Superior Direita
    PosicF = workreport.find('CORNER_UR_LAT_PRODUCT')
    f.seek(PosicF+24)
    Lat = f.read(10)
    PosicF = workreport.find('CORNER_UR_LON_PRODUCT')
    f.seek(PosicF+24)
    Lon = f.read(10)
    CoordRT = [Lat.strip(),Lon.strip()]
#Coordenada Inferior Direita
    PosicF = workreport.find('CORNER_LR_LAT_PRODUCT')
    f.seek(PosicF+24)
    Lat = f.read(10)
    PosicF = workreport.find('CORNER_LR_LON_PRODUCT')
    f.seek(PosicF+24)
    Lon = f.read(10)
    CoordRB = [Lat.strip(),Lon.strip()]
#Coordenada Inferior Esquerda
    PosicF = workreport.find('CORNER_LL_LAT_PRODUCT')
    f.seek(PosicF+24)
    Lat = f.read(10)
    PosicF = workreport.find('CORNER_LL_LON_PRODUCT')
    f.seek(PosicF+24)
    Lon = f.read(10)
    CoordLB = [Lat.strip(),Lon.strip()]
#Gera vetor com as coordenadas e adiciona ao dicionario
    Coordenadas = (CoordLT, CoordRT, CoordRB, CoordLB, CoordLT)
    Indice[nomearquivo] = Coordenadas
    IndiceProd[nomearquivo] = (ProdAlos, ZonaUTM)
    c+=1


#Imprime contagem de loops realizados
print Indice
print c


# Create the output Layer
outShapefile = "//home//leandro//Grid_GLOVISb.shp"
outDriver = ogr.GetDriverByName("ESRI Shapefile")

# Remove output shapefile if it already exists
if os.path.exists(outShapefile):
    outDriver.DeleteDataSource(outShapefile)


# Create the output shapefile
outDataSource = outDriver.CreateDataSource(outShapefile)
outLayer = outDataSource.CreateLayer("ImagensGlovis", geom_type=ogr.wkbPolygon)
idField = ogr.FieldDefn("id_GLOVIS", ogr.OFTString)
outLayer.CreateField(idField)
UTMField = ogr.FieldDefn("UTM_GLOVIS", ogr.OFTString)
outLayer.CreateField(UTMField)

# Get the output Layer's Feature Definition
outLayerDefn = outLayer.GetLayerDefn()
c2=0
# Create a Polygon from the tuple
for arquivo, conjunto in Indice.iteritems() :
    c2+=1
    p1, p2 = IndiceProd[arquivo]
    print arquivo, conjunto
    ring = ogr.Geometry(ogr.wkbLinearRing)
    for vetor in conjunto:
        print vetor
        ring.AddPoint (float((vetor[0])),float(vetor[1]))
    poly = ogr.Geometry(ogr.wkbPolygon)
    poly.AddGeometry(ring)
    featureDefn = outLayer.GetLayerDefn()
    feature = ogr.Feature(featureDefn)
    feature.SetGeometry(poly)
    feature.SetField("id_GLOVIS", arquivo)
    feature.SetField("UTM_GLOVIS", p2)
    outLayer.CreateFeature(feature)
print c2

# Close DataSources OGR
outDataSource.Destroy()


