#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
#-------------------------------------------------------------------------------
# Name:        RaidEye Vegetation Indexes
# Purpose:     Calculate ndvi, ndvi_rededge, vari_rededge,
#              chlorophyl green, chlorophil rededge and MTCI
# Author:      leandro.biondo@florestal.gov.br
#
# Created:     09/05/2016
# Copyright:   (c) leandro.biondo 2016
# Licence:     GPL
#-------------------------------------------------------------------------------
"""


import os
import sys
import numpy as np
from osgeo import gdal
from osgeo import ogr
import glob


def calculate_ndvi ( rapideye_filename ):
    """
    A function to calculate the Normalised Difference Vegetation Index
    from red and near infrarred reflectances. The reflectance data ought to
    be present on two different files, specified by the varaibles
    `red_filename` and `nir_filename`. The file format ought to be
    recognised by GDAL
    """

    rapideyer = gdal.Open ( rapideye_filename )
    g_green = rapideyer.GetRasterBand(2)
    g_red = rapideyer.GetRasterBand(3)
    g_edge = rapideyer.GetRasterBand(4)
    g_nir = rapideyer.GetRasterBand(5)
    
    green= g_green.ReadAsArray()
    red = g_red.ReadAsArray()
    edge= g_edge.ReadAsArray()
    nir = g_nir.ReadAsArray()
    
    #NDVI - Normalized Difference Vegetation Index
    passer = np.logical_and ( red > 1, nir > 1 )
    ndvi = np.where ( passer,  (1.*nir - 1.*red ) / ( 1.*nir + 1.*red ), -999 )
    
    #NDVI_Red Edge

    passer = np.logical_and ( nir > 1, edge > 1 )
    ndviedge = np.where ( passer,  (1.*nir - 1.*edge ) / ( 1.*nir + 1.*edge ), -999 )
    
    #VARI Red Edge - Visible Atmospherically Resistant Indices
 
    passer = np.logical_and ( red > 1, edge > 1 )
    variedge = np.where ( passer,  (1.*edge - 1.*red ) / ( 1.*edge + 1.*red ), -999 )   
    
    #CI - Chlorophyll Indices - green

    passer = np.logical_and ( nir > 1, green > 1 )
    clgreen = np.where ( passer,  ((1.*nir / 1.*green )-1), -999 )
    
    #CI - Chlorophyll Indices - rededge
    passer = np.logical_and ( nir > 1, edge > 1 )
    cledge = np.where ( passer,  ((1.*nir / 1.*edge )-1), -999 )    
    
    #MTCI - MERIS terrestrial - chlorophyll index
    passer = np.logical_and ( red > 1, edge > 1 )
    mtci = np.where ( passer,  (1.*nir - 1.*edge ) / ( 1.*edge - 1.*red ), -999 )  
    
    
    return ndvi, ndviedge, variedge, clgreen, cledge, mtci

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



if __name__ == "__main__":
    caminhoi = "//media//leandro//back//EFL_UNB//2016//rapideye//"
c5=0
for infile in glob.glob(r'/media/leandro/back/EFL_UNB/2016/rapideye/*.tif'):
                        print "c5=",c5
                        imagemtif = infile
                        c_ndvi, c_ndviedge, c_variedge, c_clgreen, c_cledge, c_mtci = calculate_ndvi (imagemtif)
                        save_raster ( infile.replace('.tif','_ndvi.tif'), c_ndvi,infile , "GTiff" )
                        save_raster ( infile.replace('.tif','_edge.tif'), c_ndviedge,infile , "GTiff" )
                        save_raster ( infile.replace('.tif','_variedge.tif'), c_variedge,infile , "GTiff" )
                        save_raster ( infile.replace('.tif','_clgreen.tif'), c_clgreen,infile , "GTiff" )
                        save_raster ( infile.replace('.tif','_cledge.tif'), c_cledge,infile , "GTiff" )
                        save_raster ( infile.replace('.tif','_clmtci.tif'), c_mtci,infile , "GTiff" )
                        
                        c5+=1
                       # if c5==3:
                       #     break
