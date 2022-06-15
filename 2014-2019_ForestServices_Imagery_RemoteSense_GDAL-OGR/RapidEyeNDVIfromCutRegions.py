#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
#-------------------------------------------------------------------------------
# Name:        RapidEyeNDVIfromCutRegions
# Purpose:     Calculates the NDVI of a defined region based on centroid of features from a shapefile.
#
# Author:      leandro.biondo@florestal.gov.br
#
# Created:     29/11/2013
# Copyright:   (c) leandro.biondo 2013
# Licence:     GPL
#-------------------------------------------------------------------------------
"""
import os
import sys
import numpy as np

from osgeo import gdal
from osgeo import ogr

import glob


#Funcao para calculo do NDVI, externa
def calculate_ndvi ( red_filename, nir_filename ):
    """
    A function to calculate the Normalised Difference Vegetation Index
    from red and near infrarred reflectances. The reflectance data ought to
    be present on two different files, specified by the varaibles
    `red_filename` and `nir_filename`. The file format ought to be
    recognised by GDAL
    """

    g_red = gdal.Open ( red_filename )
    red = g_red.ReadAsArray()
    g_nir = gdal.Open ( nir_filename )
    nir = g_nir.ReadAsArray()
    if ( g_red.RasterXSize != g_nir.RasterXSize ) or \
            ( g_red.RasterYSize != g_nir.RasterYSize ):
        print "ERROR: Input datasets do't match!"
        print "\t Red data shape is %dx%d" % ( red.shape )
        print "\t NIR data shape is %dx%d" % ( nir.shape )

        sys.exit ( -1 )
    passer = np.logical_and ( red > 1, nir > 1 )
    ndvi = np.where ( passer,  (1.*nir - 1.*red ) / ( 1.*nir + 1.*red ), -999 )
    return ndvi


#Funcao para salvar um raster em formato de imagem
def save_raster ( output_name, raster_data, dataset, driver="GTiff" ):
    """
    A function to save a 1-band raster using GDAL to the file indicated
    by ``output_name``. It requires a GDAL-accesible dataset to collect
    the projection and geotransform.
    """

    # Open the reference dataset
    g_input = gdal.Open ( dataset )
    # Get the Geotransform vector
    geo_transform = g_input.GetGeoTransform ()
    x_size = g_input.RasterXSize # Raster xsize
    y_size = g_input.RasterYSize # Raster ysize
    srs = g_input.GetProjectionRef () # Projection
    # Need a driver object. By default, we use GeoTIFF
    if driver == "GTiff":
        driver = gdal.GetDriverByName ( driver )
        dataset_out = driver.Create ( output_name, x_size, y_size, 1, \
                gdal.GDT_Float32, ['TFW=YES', \
                'COMPRESS=LZW', 'TILED=YES'] )
    else:
        driver = gdal.GetDriverByName ( driver )
        dataset_out = driver.Create ( output_name, x_size, y_size, 1, \
                gdal.GDT_Float32 )

    dataset_out.SetGeoTransform ( geo_transform )
    dataset_out.SetProjection ( srs )
    dataset_out.GetRasterBand ( 1 ).WriteArray ( \
            raster_data.astype(np.float32) )
    dataset_out.GetRasterBand ( 1 ).SetNoDataValue ( float(-999) )
    dataset_out = None


# Funcao que prepara um TIF e calcula o NDVI para uma area relacionada  um ponto central
# Entradas: caminhoi = caminho da pasta de trabalho, imagemtif = imagem que sera processada
#           ptcenter = Ponto central da area a ser considerada, TileId = Identificador do Grid RapidEye
#           distamost = distancia a ser considerada para amostragem, metade do comprimento de amostragem
def prep_cut_call (caminhoi, imagemtif, ptcenter, TileId, distamost):


#Ponto para corte, utilizando o ponto informado. 
    redcorte = (map(sum,zip(ptcenter,(-1*distamost,-1*distamost))), map(sum,zip(ptcenter,(distamost,distamost))))
#Corte imagem com comprimento e altura 2 vezes a variável distamost
    os.system("gdalwarp -overwrite -te "+str(redcorte[0][0])+" "+str(redcorte[0][1])+" "\
    +str(redcorte[1][0])+" "+str(redcorte[1][1])+\
    " %s %sRD_cut.tif"%(imagemtif, caminhoi))
#criadas 2 imagens temporárias com as bandas NIR e RED separadas, para calculo do NDVI
    os.system("gdal_translate -b 3 %sRD_cut.tif %sred2_cut.tif" %(caminhoi, caminhoi))
    os.system("gdal_translate -b 5 %sRD_cut.tif %snir2_cut.tif" %(caminhoi, caminhoi))


#Calculo NDVI do corte RED/NIR, criada imagem com dados de NDVI calculados
    c_ndvi = calculate_ndvi ( "%sred2_cut.tif"%caminhoi, "%snir2_cut.tif"%caminhoi)
    save_raster ( "%sndvi2_cutdes%s.tif"%(caminhoi,TileId), c_ndvi,\
    "%sred2_cut.tif"%caminhoi, "GTiff" )
#Estatisticas do resultado, devolvidas estatísticas básicas para a funcao.
    src_ds = gdal.Open("%sndvi2_cutdes%s.tif"%(caminhoi,TileId))
    srcband = src_ds.GetRasterBand(1)
    stats = srcband.GetStatistics(0,1)
    return (stats[0], stats[1], stats[2], stats[3] )








if __name__ == "__main__":

    caminhoi="//home//leandro//GINF//"

#Arquivo de feicoes que se deseja usar os centroides
shapefile = "//home//leandro//GINF//pr_300_wgs84b.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, 0)
layer = dataSource.GetLayer()

#Arquivo de feicoes que representam o grid de imagens
shapefile2 = "//home//leandro//GINF//pr_RapidEye_wgs84b.shp"
dataSource2 = driver.Open(shapefile2, 0)
layer2 = dataSource2.GetLayer()
c5 = 0

# Laco para percorrer as imagens do Grid RapidEye
for feature2 in layer2:
    c = 0
    dentro = 0
    geom2 = feature2.GetGeometryRef()
    TileId = int(feature2.GetField("TILE_ID"))
# Laco para percorrer os pontos de amostragem, usa os centroides como ponto de comparacao
    for feature in layer:
        geom = feature.GetGeometryRef()
        pt = geom.Centroid()
        ptcenter = (pt.GetX(), pt.GetY())
#  Teste para verificar se cada ponto central do shape de amostragens intercepta o shape do mosaico RapidEye
        if pt.Intersects(geom2):
            dentro+=1
#Laco que encontra todos os arquivos TIF a serem processados conforme a identificacao no mosico RapidEye
            for infile in glob.glob(r'/mnt/hgfs/Biondo/GINF/Florestas_Parana/Imagens_RapidEye/*%s*.tif'%TileId):
            #Ignora arquivos "browse."
                if infile.find("browse.") == -1:
            #Ignora arquivos "udm."
                    if infile.find("udm.") == -1:
#Imagem TIF que sera cortada, ter as bandas NIR e RED separadas e calculado o seu NDVI
                        imagemtif = infile
            #Execucao das funcoes tomando como entrada os dados resultantes da filtragem pelos pontos.
                        Statistica = prep_cut_call (caminhoi, imagemtif, ptcenter, TileId, 150)
            # Estatísticas simples do arquivo NDVI do corte em torno do ponto de amostragem
                        print TileId, "(Min, Max, Mean, StDv)", Statistica
# Limite para evitar que todos os pontos e imagens sejam processados, comentar para processar todos os dados
                        c5+=1
                        if c5>5:
                            exit(0)
        c+=1
#Importante, resta a leitura do shape de amostragem para que ele possa ser percorrido novamente no próximo Tile do R-E
    layer.ResetReading()
    print "Pontos: %i sendo %i contidas e %i nao" %( c, dentro, (c-dentro))
#Apenas indica quais feições do RapidEye Grid continham pontos de amostragem.
    if dentro > 0:
        print TileId
