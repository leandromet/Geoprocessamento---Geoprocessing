#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
#-------------------------------------------------------------------------------
# Name:        ALOS_RFDI and dB
# Purpose:     Calculates the RFDI and HH dB stats of a defined region based on centroid of features from a shapefile.
#               (Radar Forest Devastation Index)
# Author:      leandro.biondo@florestal.gov.br
#
# Created:     07/11/2014
# Copyright:   (c) leandro.biondo 2014
# Licence:     GPL
#-------------------------------------------------------------------------------
"""
import os
import sys
import numpy as np

from osgeo import gdal
from osgeo import ogr

import glob

def calculate_rrfdi ( red_filename, nir_filename ):
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
    passer = True
    rrfdi = np.where ( passer,  (1.*red - 1.*nir ) / ( 1.*nir + 1.*red ), -999 )
    return rrfdi*(-1)

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

def prep_cut_call (caminhoi, imagemtif, ptcenter, NameT):
# "Funcao que prepara um TIF e calcula o rrfdi para uma area relacionada  um ponto central"

#Ponto para corte, no caso o centro da imagem pelos seus dados
    redcorte = (map(sum,zip(ptcenter,(-0.0015,-0.0015))), map(sum,zip(ptcenter,(0.0015,0.0015))))
    print 'redcorte', redcorte
#Corte imagem
    os.system("gdalwarp -overwrite -te "+str(redcorte[0][0])+" "+str(redcorte[0][1])+" "\
    +str(redcorte[1][0])+" "+str(redcorte[1][1])+\
    " %s %shorz_cut.tif"%(imagemtif, caminhoi))

    imagemtif=imagemtif.replace("HH","HV")
    os.system("gdalwarp -overwrite -te "+str(redcorte[0][0])+" "+str(redcorte[0][1])+" "\
    +str(redcorte[1][0])+" "+str(redcorte[1][1])+\
    " %s %svert_cut.tif"%(imagemtif, caminhoi))



#Calculo rrfdi do corte RED/NIR
    c_rrfdi = calculate_rrfdi ( "%shorz_cut.tif"%caminhoi, "%svert_cut.tif"%caminhoi)
    save_raster ( "%srfdi_cutdes.tif"%(caminhoi), c_rrfdi,\
    "%shorz_cut.tif"%caminhoi, "GTiff" )
#Estatisticas do resultado
    src_ds = gdal.Open("%srfdi_cutdes.tif"%(caminhoi))
    srcband = src_ds.GetRasterBand(1)
    stats = srcband.GetStatistics(0,1)
    M_rrfdi = srcband.ReadAsArray().astype(np.float)
    print M_rrfdi, (stats[0], stats[1], stats[2], stats[3] ), np.histogram(M_rrfdi, bins=[-10,0.0,0.1,0.2,0.3,0.4,0.5,10])


#Estatisticas dB HH
    src_ds2 = gdal.Open("%shorz_cut.tif"%(caminhoi))
    srcband2 = src_ds2.GetRasterBand(1)
    stats2 = srcband2.GetStatistics(0,1)
    M_rrfdi2 = srcband2.ReadAsArray().astype(np.float)
    print M_rrfdi2, (stats[0], stats[1], stats[2], stats[3] ), np.histogram(M_rrfdi2, bins=[-25,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,5])
    return (stats[0], stats[1], stats[2], stats[3] ), np.histogram(M_rrfdi, bins=[-10,0.0,0.1,0.2,0.3,0.4,0.5,10]),\
    (stats2[0], stats2[1], stats2[2], stats2[3] ), np.histogram(M_rrfdi2, bins=[-25,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,5])









if __name__ == "__main__":

    caminhoi="//home//leandro//temp//"

#Arquivo de feicoes que se deseja usar os centroides
shapefile = "//home//leandro//DiscoLocal//PALSAR_RFDI//BRASIL_COMPLETO3a.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, True)
layer = dataSource.GetLayer()
#Cria campos para saidas estatisticas

layer.CreateField(ogr.FieldDefn("rrfdi_med", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_min", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_max", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_dvP", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_neg", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p0", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p1", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p2", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p3", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p4", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("rrfdi_0p5", ogr.OFTReal),False)

layer.CreateField(ogr.FieldDefn("dB_med", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_min", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_max", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_dvP", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n25", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n20", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n18", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n16", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n14", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n12", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n10", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n08", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n06", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n04", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n02", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("dB_n00", ogr.OFTReal),False)


#exit(0)
#Arquivo de feicoes que representam o grid de imagens
shapefile2 = "//home//leandro//DiscoLocal//PALSAR_RFDI//grid_palsar_Brasil.shp"
dataSource2 = driver.Open(shapefile2, 0)
layer2 = dataSource2.GetLayer()
c5 = 0
for feature2 in layer2:
    c = 0
    dentro = 0
    geom2 = feature2.GetGeometryRef()
    TileId = str(feature2.GetField("TILE_ID"))
    for feature in layer:
        geom = feature.GetGeometryRef()
        ptcenter = (geom.GetX(), geom.GetY())
#        print ptcenter
        if geom.Intersects(geom2):
            dentro+=1
            print "dentro",dentro
#            print ptcenter
            #Laco que encontra todos os arquivos TIF a serem processados
            samef=0
            for infile in glob.glob(r'/home/leandro/DiscoLocal/PALSAR_RFDI/*%s*sl_HH*.tif'%TileId):
            #Ignora arquivos "browse."
                print infile
                if infile.find("browse.") == -1:
            #Ignora arquivos "udm."
                    if infile.find("udm.") == -1:
                        print "c5=",c5
                        samef+=1
                        imagemtif = infile
                        NameT = "_"+str(TileId)+"_"+str(dentro)+"_"+str(samef)
                        Statistica, ( Stat2, Bins ),Statistica2, ( Stat22, Bins2 ) = prep_cut_call (caminhoi, imagemtif, ptcenter, NameT)
                        print caminhoi, imagemtif, ptcenter, NameT, TileId, "(Min, Max, Mean, StDv)", Statistica, Stat2, Bins, "dB", Statistica2,Stat22, Bins2
                        feature.SetField("rrfdi_med", round(Statistica[2], 3))
                        feature.SetField("rrfdi_min", round(Statistica[0], 3))
                        feature.SetField("rrfdi_max", round(Statistica[1], 3))
                        feature.SetField("rrfdi_dvP", round(Statistica[3], 3))
                        feature.SetField("rrfdi_neg", int(Stat2[0]))
                        feature.SetField("rrfdi_0p0", int(Stat2[1]))
                        feature.SetField("rrfdi_0p1", int(Stat2[2]))
                        feature.SetField("rrfdi_0p2", int(Stat2[3]))
                        feature.SetField("rrfdi_0p3", int(Stat2[4]))
                        feature.SetField("rrfdi_0p4", int(Stat2[5]))
                        feature.SetField("rrfdi_0p5", int(Stat2[6]))
                        feature.SetField("dB_med", round(Statistica2[2], 3))
                        feature.SetField("dB_min", round(Statistica2[0], 3))
                        feature.SetField("dB_max", round(Statistica2[1], 3))
                        feature.SetField("dB_dvP", round(Statistica2[3], 3))
                        feature.SetField("dB_n25", int(Stat22[0]))
                        feature.SetField("dB_n20", int(Stat22[1]))
                        feature.SetField("dB_n18", int(Stat22[2]))
                        feature.SetField("dB_n16", int(Stat22[3]))
                        feature.SetField("dB_n14", int(Stat22[4]))
                        feature.SetField("dB_n12", int(Stat22[5]))
                        feature.SetField("dB_n10", int(Stat22[6]))
                        feature.SetField("dB_n08", int(Stat22[7]))
                        feature.SetField("dB_n06", int(Stat22[8]))
                        feature.SetField("dB_n04", int(Stat22[9]))
                        feature.SetField("dB_n02", int(Stat22[10]))
                        feature.SetField("dB_n00", int(Stat22[11]))
                        layer.SetFeature(feature)
                        c5+=1
                        if c5==5:
                            exit(0)
        c+=1
        feature.Destroy()
    layer.ResetReading()
    print "Pontos: %i sendo %i contidas e %i nao" %( c, dentro, (c-dentro))
    if dentro > 0:
        print TileId

layer=None
layer2=None
dataSource=None
dataSource2=None
