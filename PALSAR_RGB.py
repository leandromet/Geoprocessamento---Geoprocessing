# Gets a PALSAR unigned int 16bit dataset and returns
# a 32bit float GeoTIFF image in DB values normalized
# with the image global MAX and MIN DB values then filters
# the result with a 9 average convolution matrix
import glob
import gdal
from gdalconst import *
import osr
import numpy as np
from struct import *
import array
from scipy import ndimage
import math
import os


for files in glob.glob("C:\Biondo\\GECAD\\ALTAMIRA\\pals\\*S05*HH_img.tif"):

    entrada = files
    saida = files.Replace("img", "rgb")
    referencia = "pals"
    print entrada, ">>>",saida
    entraHH = gdal.Open(entrada)
    entraHV= gdal.Open(entrada.Replace("HH", "HV"))
    entraRFDI= gdal.Open(entrada.Replace("sl_HV_img", "RFDI"))
    
    bandHH = entraHH.GetRasterBand(1)
    bandHV = entraHV.GetRasterBand(1)
    bandRFDI = entraRFDI.GetRasterBand(1)
    
       
    
    format = "GTiff"
    driver = gdal.GetDriverByName( format )
    metadata = driver.GetMetadata()
    if metadata.has_key(gdal.DCAP_CREATE) \
       and metadata[gdal.DCAP_CREATE] == 'YES':
        print 'Driver %s supports Create() method.' % format
    if metadata.has_key(gdal.DCAP_CREATECOPY) \
       and metadata[gdal.DCAP_CREATECOPY] == 'YES':
        print 'Driver %s supports CreateCopy() method.' % format

    dst_ds = driver.Create( saida, 4500, 4500, 3, gdal.GDT_Float32, ['COMPRESS=LZW'] )
    dst_ds.SetGeoTransform( [ lon-0.000111111, 0.000222222, 0, lat-0.000111111, 0, -0.000222222 ] )

    srs = osr.SpatialReference()
    srs.SetWellKnownGeogCS( 'WGS84' )
    dst_ds.SetProjection( srs.ExportToWkt() )


    dst_ds.GetRasterBand(1).WriteArray(bandHH.ReadAsArray())
    dst_ds.GetRasterBand(2).WriteArray(bandHV.ReadAsArray())
    dst_ds.GetRasterBand(3).WriteArray(bandRFDI.ReadAsArray())
    
    c+=1
    print c
        #if c >= 5:
        #    exit(0)


print "end"
