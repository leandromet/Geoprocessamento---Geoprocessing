#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
#-------------------------------------------------------------------------------
# Name:        RapidEyeNDVIfromCutRegions
# Purpose:     Calculate the NDVI of a defined region based on centroid of features from a shapefile. 
#              builds a histogram of ndvi values on the attribute table of the shapefile
#
# Author:      leandrometATgmail
#
# Created:     2015
# Copyright:   (c) leandro.biondo 2015
# Licence:     GPL
#-------------------------------------------------------------------------------
"""
import os
import sys
import numpy as np

from osgeo import gdal
from osgeo import ogr

import glob

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
# "Funcao que prepara um TIF e calcula o NDVI para uma area relacionada  um ponto central"

#Ponto para corte, no caso o centro da imagem pelos seus dados
    redcorte = (map(sum,zip(ptcenter,(-150,-150))), map(sum,zip(ptcenter,(150,150))))
    print 'redcorte', redcorte
#Corte imagem
    os.system("gdalwarp -overwrite -te "+str(redcorte[0][0])+" "+str(redcorte[0][1])+" "\
    +str(redcorte[1][0])+" "+str(redcorte[1][1])+\
    " %s %sRD_cut.tif"%(imagemtif, caminhoi))

    os.system("gdal_translate -b 3 %sRD_cut.tif %sred2_cut.tif" %(caminhoi, caminhoi))
    os.system("gdal_translate -b 5 %sRD_cut.tif %snir2_cut.tif" %(caminhoi, caminhoi))


#Calculate NDVI from the cut images of RED/NIR
    c_ndvi = calculate_ndvi ( "%sred2_cut.tif"%caminhoi, "%snir2_cut.tif"%caminhoi)
    save_raster ( "%sndvi2_cutdes.tif"%(caminhoi), c_ndvi,\
    "%sred2_cut.tif"%caminhoi, "GTiff" )
#Statistics, including a histogram of the pixel values
    src_ds = gdal.Open("%sndvi2_cutdes.tif"%(caminhoi))
    srcband = src_ds.GetRasterBand(1)
    stats = srcband.GetStatistics(0,1)
    M_ndvi = srcband.ReadAsArray().astype(np.float)
    print M_ndvi, (stats[0], stats[1], stats[2], stats[3] ), np.histogram(M_ndvi, bins=[-10,0.0,0.2,0.4,0.6,0.8,1.0,10])
    return (stats[0], stats[1], stats[2], stats[3] ), np.histogram(M_ndvi, bins=[-10,0.0,0.2,0.4,0.6,0.8,1.0,10])








if __name__ == "__main__":
#location of processing
    caminhoi="//home//leandro//NDVI_UTM//s25//"

#File with features that will have thei centroid used, needs to be in the same projection as the images

shapefile = "//home//leandro//NDVI_UTM//s25//grid_comp_S25.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, True)
layer = dataSource.GetLayer()

#Create fields for the statistics result from the images

layer.CreateField(ogr.FieldDefn("ndvi_med", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_desvP", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_neg", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_0p0", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_0p2", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_0p4", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_0p6", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_0p8", ogr.OFTReal),False)
layer.CreateField(ogr.FieldDefn("ndvi_1p0", ogr.OFTReal),False)


#exit(0)
#Image grid file with a unique identification for the tiles, same id as the RapidEye file names

shapefile2 = "//home//leandro//NDVI_UTM//s25//rd_comp_S25.shp"
dataSource2 = driver.Open(shapefile2, 0)
layer2 = dataSource2.GetLayer()

#Iterate over features that we want the centroid and the features representing the tiles of images
#start a counter for iterated features from the target layer for the centroid estimation
c5 = 0
for feature2 in layer2:
    #start a counter for iterated features from the rapideye tiles
    c = 0
    #start a counter for different centroids inside the same image
    dentro = 0
    geom2 = feature2.GetGeometryRef()
    TileId = int(feature2.GetField("TILE_ID"))
    for feature in layer:
        geom = feature.GetGeometryRef()
        ptcenter = (geom.GetX(), geom.GetY())
#        print ptcenter
        if geom.Intersects(geom2):
        #checks if the centroid is inside a image tile, iterates over all centroids that are
            dentro+=1
            print "dentro",dentro
#            print ptcenter
            #Find image files to be processed (this case TIF), starts a counter for same point in different images
            samef=0
            for infile in glob.glob(r'/home/leandro/geodados/imagens/RapidEye/brasil/*/fuso_25s/*/*%s*.tif'%TileId):
            #Ignore the "browse." files that have the same tile number and are in the same folder as the scene we want
                print infile
                if infile.find("browse.") == -1:
            #Ignore "udm." files
                    if infile.find("udm.") == -1:
                        print "c5=",c5
                        samef+=1
                        # get the tif image and 
                        imagemtif = infile
                        #builds the name for the tile, with the id from the image, the order of centroids inside the tile and the order of images for the same centroid
                        NameT = "_"+str(TileId)+"_"+str(dentro)+"_"+str(samef)
                        #calls the preparation, cuting and ndvi calculation for each centroid
                        Statistica, ( Stat2, Bins ) = prep_cut_call (caminhoi, imagemtif, ptcenter, NameT)
                        print caminhoi, imagemtif, ptcenter, NameT, TileId, "(Min, Max, Mean, StDv)", Statistica, Stat2, Bins
                        #set values for fields of the target shapefile with the results
                        #mean
                        feature.SetField("ndvi_med", round(Statistica[2], 3))
                        #standard deviation
                        feature.SetField("ndvi_DesvP", round(Statistica[3], 3))
                        #counting of pixels for each histogram bin
                        feature.SetField("ndvi_neg", int(Stat2[0]))
                        feature.SetField("ndvi_0p0", int(Stat2[1]))
                        feature.SetField("ndvi_0p2", int(Stat2[2]))
                        feature.SetField("ndvi_0p4", int(Stat2[3]))
                        feature.SetField("ndvi_0p6", int(Stat2[4]))
                        feature.SetField("ndvi_0p8", int(Stat2[5]))
                        feature.SetField("ndvi_1p0", int(Stat2[6]))
                        #update feature information
                        layer.SetFeature(feature)
                        c5+=1
                        #if c5==5:
                        #    exit(0)
        c+=1
        #close feature from target layer, so that the process can be repeated
        feature.Destroy()
    #reset reading of the feaures for comparison with the next tile
    layer.ResetReading()
    print "Pontos: %i sendo %i contidas e %i nao" %( c, dentro, (c-dentro))
    #warns if there were any points inside the tile
    if dentro > 0:
        print TileId
#close all sources in order to update the modified tables and release any locks for the sources
layer=None
layer2=None
dataSource=None
dataSource2=None
