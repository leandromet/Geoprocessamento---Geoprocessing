##!/usr/bin python
# -*- coding: utf-8 -*-
# Gets a PALSAR unigned int 16bit dataset and returns
# a 32bit float GeoTIFF image in DB values normalized
# with the image global MAX and MIN DB values then filters
# the result with a 9 average convolution matrix with a
# center weight of 2 (8 neighbor pixels weight 1)
import glob
import gdal
from gdalconst import *
import osr
import numpy as np
from struct import *
import array
from scipy import ndimage

#safely calculates the log10 of a number, avoid problems with zero division
def safe_ln(x, minval=0.0000000001):
    return np.log(x.clip(min=minval))


#exports an 32bit image geoTIFF from a binary 16bit unsigned integer ALOS dataset
def exporta_alos_geoTIFF(arquivo, destino, refer):

# gets the geographic coordinates from the file name

    pos = arquivo.find(refer)
    print arquivo, refer, pos
    lat = -1*int(arquivo[pos+6:pos+8])
    lon = -1*int(arquivo[pos+9:pos+12])

    print lat, lon
    
#opens source file (ALOS - PALSAR binary data)

    f = open(arquivo, "rb")
    print f

    count = 0

# Creates and populate an array with the 16bit data from opened file

    a =array.array("H")

    print len(a)

    a.fromfile(f, 4500*4500)

    print a[25], a[3000], a[4500*4500-1], len(a)

#set geotiff metadata

    format = "GTiff"
    driver = gdal.GetDriverByName( format )
    metadata = driver.GetMetadata()
    if metadata.has_key(gdal.DCAP_CREATE) \
       and metadata[gdal.DCAP_CREATE] == 'YES':
        print 'Driver %s supports Create() method.' % format
    if metadata.has_key(gdal.DCAP_CREATECOPY) \
       and metadata[gdal.DCAP_CREATECOPY] == 'YES':
        print 'Driver %s supports CreateCopy() method.' % format

#create desired destination file

    dst_ds = driver.Create( destino, 4500, 4500, 1, gdal.GDT_Float32 )
    dst_ds.SetGeoTransform( [ lon-0.000111111, 0.000222222, 0, lat-0.000111111, 0, -0.000222222 ] )

# georeferencing the image

    srs = osr.SpatialReference()
    srs.SetWellKnownGeogCS( 'WGS84' )
    dst_ds.SetProjection( srs.ExportToWkt() )

# creates a numpy array from the data array, for calculations

    npa = np.array(a, dtype = 'f32')

# extracting Normalised Radar Cross Section (NRCS)
# http://earth.eo.esa.int/pcs/alos/palsar/userinfo/ALOS-PALSAR-FAQ-001.3.pdf

    npa = (10*safe_ln((npa)**2))-83

#normalizing NRCS values and creating the raster matrix with destination resolution

    minval = np.min(npa[np.nonzero(npa)])
    maxval = np.max(npa[np.nonzero(npa)])
    print "maxmin", maxval, minval
    npa = (npa-minval)*((minval-maxval)/65536)+minval
    npr = npa.reshape(4500,4500)


# convolution of a 9x9 matrix with center wight 2 for attenuation of noise

    med25 = np.array([[0.0625,0.0625,0.0625],[0.0625,0.5,0.0625],[0.0625,0.0625,0.0625]])
    convolucao = ndimage.convolve(npr,med25)
    dst_ds.GetRasterBand(1).WriteArray(convolucao)

# Once we're done, close properly the dataset
    dst_ds = None
    return "Gerado imagem %s" %destino


# running the function on a group of files inside some folder (changes needed for MAIN module)

for files in glob.glob("/home//leandro//ALOS_PRODES//ALOS_Cenas//alpr//*"):

    entrada = files
    saida = files+".tif"
    referencia = "alpr"
    print entrada, ">>>",saida
    exporta_alos_geoTIFF(entrada,saida,referencia)
