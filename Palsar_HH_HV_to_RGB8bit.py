"""
#-------------------------------------------------------------------------------
# Name:        ALOS HH, HV and RFDI on RGB 16signedint GEOTIFF
# Purpose:     Calculates the RFDI , saves geotiff with HH, HV and RFDI layers 
#               in 8bit unsigned format, with values stretched for contrast enhancement.
# Author:      leandro.biondo@florestal.gov.br
#
# Created:     06/07/2015
# Copyright:   (c) leandro.biondo 2015
# Licence:     GPL
#-------------------------------------------------------------------------------
"""
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




 


def exporta_alos_geoTIFF(arquivo, destino, refer):

    pos = arquivo.find(refer)-1
    lat = -1*int(arquivo[pos+6:pos+8])
    lon = -1*int(arquivo[pos+9:pos+12])



    f = open(arquivo, "rb")
    print f
    count = 0
    print os.stat(arquivo).st_size

    npa = np.fromfile(f, dtype=np.dtype('<H'))
    f.close()
    npa = npa.astype(np.float32)
    npa = npa**2
    npr = npa.reshape(4500,4500)
    med9 = np.array([
    [0.11,0.11,0.11],
    [0.11,0.12,0.11],
    [0.11,0.11,0.11],
    ])

    #convolucao = ndimage.convolve(npr,med81)
    #convolucao = ndimage.convolve(npr,med25)
    convolucao = ndimage.convolve(npr,med9)
    npalog = 10*np.log10(convolucao)-83
    np.putmask(npalog, npalog<-500, -500)
    npalog = npalog.reshape(4500,4500)


    fv = open(arquivo.replace("HH","HV"), "rb")
    print fv
    count = 0
 
    npav = np.fromfile(fv, dtype=np.dtype('<H'))
    fv.close()
    npav = npav.astype(np.float32)
    npav = npav**2
    nprv = npav.reshape(4500,4500)


    #convolucao = ndimage.convolve(npr,med81)
    #convolucao = ndimage.convolve(npr,med25)
    convolucaov = ndimage.convolve(nprv,med9)
    npalogv = 10*np.log10(convolucaov)-83
    np.putmask(npalogv, npalogv<-500, -500)
    npalogv = npalogv.reshape(4500,4500)


    passer = True
    rfdi = np.where ( passer,  (1.*npalog - 1.*npalogv ) / ( 1.*npalog + 1.*npalogv ), -999 )


    format = "GTiff"
    driver = gdal.GetDriverByName( format )
    metadata = driver.GetMetadata()
    if metadata.has_key(gdal.DCAP_CREATE) \
       and metadata[gdal.DCAP_CREATE] == 'YES':
        print 'Driver %s supports Create() method.' % format
    if metadata.has_key(gdal.DCAP_CREATECOPY) \
       and metadata[gdal.DCAP_CREATECOPY] == 'YES':
        print 'Driver %s supports CreateCopy() method.' % format

    dst_ds = driver.Create( destino, 4500, 4500, 3, gdal.GDT_Byte, ['COMPRESS=LZW'] )
    dst_ds.SetMetadataItem("DateTime", "2009:00:00")
    dst_ds.SetGeoTransform( [ lon-0.000111111, 0.000222222, 0, lat-0.000111111, 0, -0.000222222 ] )

    srs = osr.SpatialReference()
    srs.SetWellKnownGeogCS( 'WGS84' )
    dst_ds.SetProjection( srs.ExportToWkt() )
    
    print "min", np.amin(npalog)
    print np.amin(npalogv)
    print np.amin(rfdi)
    
    print "max", np.amax(npalog)
    print np.amax(npalogv)
    print np.amax(rfdi)
    #new range
    npalog=npalog+np.abs(np.amin(npalog))
    npalogv=npalogv+np.abs(np.amin(npalogv))
    rfdi=rfdi+np.abs(np.amin(rfdi))
    npalog=(npalog-np.amin(npalog))*(255/((np.amax(npalog)-np.amin(npalog))))
    npalogv=(npalogv-np.amin(npalogv))*(255/((np.amax(npalogv)-np.amin(npalogv))))
    rfdi=(rfdi-np.amin(rfdi))*(255/((np.amax(rfdi)-np.amin(rfdi))))
    
    print "minpos", np.amin(npalog)
    print np.amin(npalogv)
    print np.amin(rfdi)
    
    print "maxpos", np.amax(npalog)
    print np.amax(npalogv)
    print np.amax(rfdi)
    
    print "meanpos", np.mean(npalog, dtype=np.float64)
    print np.mean(npalogv, dtype=np.float64)
    print np.mean(rfdi, dtype=np.float64)



    dst_ds.GetRasterBand(1).WriteArray(npalog.astype(int))
    dst_ds.GetRasterBand(2).WriteArray(npalogv.astype(int))
    dst_ds.GetRasterBand(3).WriteArray(rfdi.astype(int))
    
    # Once we're done, close properly the dataset
    dst_ds = None

    print "Gerada imagem %s" %destino


c=0
for files in glob.glob("C:\\Biondo\\PALSAR_Catalogo\\2009\\RGB\\*sl_HH"):

    entrada = files
    saida = files+"_img.tif"
    referencia = "RGB"
    print entrada, ">>>",saida
    exporta_alos_geoTIFF(entrada,saida,referencia)
    c+=1
    print c
    #if c >= 1:
    #        break


print "end"



