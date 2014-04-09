# Gets a group of PALSAR unigned int 16bit dataset and returns
# a 32bit float GeoTIFF image in DB values then filters
# the result with a 25 and a 9 average convolution matrix
#
# The images are georeferenced based on file names of
# PALSAR data and mainly works with GeoTiff format for raster
# inputs and outputs.
# 
# Generates a binary raster with 1 value for pixels that
# are inside a range of dB values, primary to classify what
# should be forests
#
# Then gets a shapefile containing features with areas of interest that
# are intended to be analised, rasterize those areas to binary
# in tiles of the same size as the object PALSAR scenes
# and multiplies the resulting forest classification and the
# rasterized interest areas, therefore resulting in a binary
# raster where the interest areas pixels that have a forest classification
# from the PALSAR data has 1 value.
#
# At the end the same is done reversely for the classification, so
# negative images of classification are generated and multiplied to
# interest areas, getting and image with 1 value for interest areas that
# have no classification for forest from PALSAR data.
#
# Finishes with simple statistics of alls reulting classification images
# compared to the whole PALSAR scenes used in processing and with the
# total pixels and values of the interest areas.


import glob
import gdal
from gdalconst import *
import ogr
import osr
import numpy as np
from struct import *
import array
from scipy import ndimage
from osgeo.gdalnumeric import *
import math
import os
from os.path import exists
from os.path import basename
from os.path import splitext
from os import remove
import sys
import operator




import warnings
warnings.filterwarnings(action="ignore", category=RuntimeWarning)





def export_alos(arquivo, destino, refer, bino):

    pos = arquivo.find(refer)
    lat = -1*int(arquivo[pos+6:pos+8])
    lon = -1*int(arquivo[pos+9:pos+12])
    if arquivo[pos+5]=="N":
        lat = lat*(-1)
        #print "Norte:", lat
    #else:
        #print "Sul:", lat
    #return 0


    f = open(arquivo, "rb")
    print f
    count = 0
    print os.stat(arquivo).st_size

    npa = np.fromfile(f, dtype=np.dtype('<H'))
    f.close()
    npa = npa.astype(np.float32)

    npa = npa**2
    npr = npa.reshape(4500,4500)
    #m81 = 0.8/81
    #med81 = np.zeros((9,9))
    #med81.fill(m81)

    m25 = 1.0/25
    med25 = np.zeros((5,5))
    med25.fill(m25)
    med9 = np.array([
    [0.1,0.1,0.1],
    [0.1,0.2,0.1],
    [0.1,0.1,0.1],
    ])

    #convolucao = ndimage.convolve(npr,med81)
    convolucao = ndimage.convolve(npr,med25)
    convolucao = ndimage.convolve(convolucao,med9)
    convolucao = ndimage.convolve(convolucao,med9)


    npalog = 10*np.log10(convolucao)-83
    np.putmask(npalog, npalog<-500, -500)
    npalog = npalog.reshape(4500,4500)


    format = "GTiff"
    driver = gdal.GetDriverByName( format )
    metadata = driver.GetMetadata()
    srs = osr.SpatialReference()
    srs.SetWellKnownGeogCS( 'WGS84' )

    dst_ds = driver.Create( destino, 4500, 4500, 1, gdal.GDT_Float32 )
    dst_ds.SetGeoTransform( [ lon-0.000111111, 0.000222222, 0, lat-0.000111111, 0, -0.000222222 ] )
    dst_ds.SetProjection( srs.ExportToWkt() )

    dst_ds.GetRasterBand(1).WriteArray(npalog)


    dst2_ds = driver.Create( destino.replace(".","_Class."), 4500, 4500, 1, gdal.GDT_Byte )
    dst2_ds.SetGeoTransform( dst_ds.GetGeoTransform() )
    dst2_ds.SetProjection( srs.ExportToWkt() )

    np.putmask(npalog, npalog>-0.5, 0+bino)
    np.putmask(npalog, npalog<-9.5, 0+bino)
    np.putmask(npalog, npalog<0, 1-bino)
    dst2_ds.GetRasterBand(1).WriteArray(npalog)



    # Once we're done, close properly the dataset
    dst_ds = None
    print "Gerada imagem %s" %destino




def copyAttributes(fromFeature, toFeature):
    for i in range(fromFeature.GetFieldCount()):
        fieldName = fromFeature.GetFieldDefnRef(i).GetName()
        toFeature.SetField(fieldName,fromFeature.GetField(fieldName))



def extract(in_file, out_file, filter_field, filter_values):
    '''
    Opens the input file, copies it into the oputput file, checking
    the filter.
    '''
    print "Extracting data"

    in_ds = ogr.Open( in_file )
    if in_ds is None:
        print "Open failed.\n"
        sys.exit( 1 )
    in_lyr = in_ds.GetLayerByName( splitext(basename(in_file))[0] )
    if in_lyr is None:
        print "Error opening layer"
        sys.exit( 1 )


    ##Creating the output file, with its projection
    if exists(out_file):
        remove(out_file)
    driver_name = "ESRI Shapefile"
    drv = ogr.GetDriverByName( driver_name )
    if drv is None:
        print "%s driver not available.\n" % driver_name
        sys.exit( 1 )
    out_ds = drv.CreateDataSource( out_file )
    if out_ds is None:
        print "Creation of output file failed.\n"
        sys.exit( 1 )
    proj = in_lyr.GetSpatialRef()
    ##Creating the layer with its fields
    out_lyr = out_ds.CreateLayer(
        splitext(basename(out_file))[0], proj, ogr.wkbMultiPolygon )
    lyr_def = in_lyr.GetLayerDefn ()
    for i in range(lyr_def.GetFieldCount()):
        out_lyr.CreateField ( lyr_def.GetFieldDefn(i) )


    ##Writing all the features
    in_lyr.ResetReading()

    for feat in in_lyr:
        value = feat.GetFieldAsString(feat.GetFieldIndex(filter_field))
        if filter_func(value, filter_values):
            out_lyr.CreateFeature(feat)

    in_ds = None
    out_ds = None



def filter_func(value, filter_values):
    '''
    The custom filter function. In this case, we chack that the value is in the
    value list, stripping the white spaces. In the case of numeric values, a
    comparaison could be done
    '''
    if value.strip() in filter_values:
        return True
    else:
        return False





def get_operator_fn(op):
    return {
        '+' : operator.add,
        '-' : operator.sub,
        '*' : operator.mul,
        '/' : operator.div,
        '%' : operator.mod,
        '^' : operator.xor,
        }[op]



def calculate_band(dsf1, dsf2, bnd1, bnd2, outfile, oper):

        #gets 2 raster files (tif) ds1 and s2, then does a calculation with one band from
        #each file, can be used with same raster file and different bands


    #Open the dataset
    ds1 = gdal.Open(dsf1, GA_ReadOnly )
    ds2 = gdal.Open(dsf2, GA_ReadOnly )
    band1 = ds1.GetRasterBand(bnd1)
    band2 = ds2.GetRasterBand(bnd2)

    #Read the data into numpy arrays
    data1 = BandReadAsArray(band1)
    data2 = BandReadAsArray(band2)

    #The actual calculation
    dataOut = get_operator_fn(oper)(data1, data2)

    #Write the out file
    driver = gdal.GetDriverByName("GTiff")
    metadata = driver.GetMetadata()
    srs = osr.SpatialReference()
    srs.SetWellKnownGeogCS( 'WGS84' )


    dsOut = driver.Create(outfile, ds1.RasterXSize, ds1.RasterYSize, 1, band1.DataType )
    dsOut.SetGeoTransform( ds1.GetGeoTransform() )
    dsOut.SetProjection( srs.ExportToWkt() )

    CopyDatasetInfo(ds1,dsOut)
    bandOut=dsOut.GetRasterBand(1)
    BandWriteArray(bandOut, dataOut)

    #Close the datasets
    band1 = None
    band2 = None
    ds1 = None
    ds2 = None
    bandOut = None
    dsOut = None






if __name__ == "__main__":

#Exports PALSAR binary data to TIF, with 5x5 mean filter and
#3x3 mean center weght 2 filter, with export_alos() function


  SCENES = "/mnt//hgfs//Biondo//ALOS_PRODES//cenas_interesse_60_lista.txt"
  for infile in SCENES:
    infile = infile.replace("\n","")
#command line arguments for extracting only the HH files from tar.gz archives from target scenes
    #os.system("ls /mnt/hgfs/Biondo/ALOS_PRODES/ALOS_Cenas/interesse_60/*.gz | xargs --verbose -n1 -i tar 
    #          -xzf '{}' -C /home/leandro/ALOS_PRODES/ALOS_Cenas/alpr --wildcards '*"+infile+"*HH'")


    pathto = "/home//leandro//arquivos//ALOS_PRODES//ALOS_Cenas//alpr//"
    driver = ogr.GetDriverByName("ESRI Shapefile")


    for files in glob.glob(pathto+"*HH"):
        entrada = files
        saida = files+"DB.tif"
        referencia = "alpr"
        export_alos(entrada,saida,referencia,0)


# Extracting only features that have atribute "class_name" equals to "NUVEM" (cloud)

    for files in glob.glob(r'/mnt/hgfs/Biondo/ALOS_PRODES/2006/PDigital2000_2006/*.shp'):
        extract(files, files.replace('.shp', '_NUVEM.shp') ,'class_name', ('NUVEM'))


#Open shapefile to be compared with DB images
    nuvem = glob.glob(pathto+"*N*.shp")[0]
    dataSourcen = driver.Open(nuvem, 0)
    layern = dataSourcen.GetLayer()


    for files in glob.glob(pathto+"*Class.tif"):
        datafile = gdal.Open(files)
        geoinfo = datafile.GetGeoTransform()
        largura= datafile.RasterXSize
        altura = datafile.RasterYSize
        xmin=geoinfo[0]
        ymax=geoinfo[3]
        pixsize = geoinfo[1]
        xmax=xmin+largura*pixsize
        ymin=ymax-altura*pixsize

        sainuvem = files.replace("Class.tif", "DB_nuvem.tif")
        print "coordenadas corte:",xmin,ymin,xmax,ymax, largura, altura, pixsize
        os.system("gdal_rasterize  -burn 1 -l NUVEM2006_Amazonia_erased -ts "+str(largura)+" "+str(altura)+" -te "+
        str(xmin)+" "+str(ymin)+" "+str(xmax)+" "+str(ymax)+" "+
        nuvem + ' ' + sainuvem + " -ot Byte")

        calculate_band(files, sainuvem , 1, 1, sainuvem.replace("_nuvem","_resultado"), '*')
    dataSourcen = None



    for files in glob.glob(pathto+"*ClassN.tif"):
        datafile = gdal.Open(files)
        geoinfo = datafile.GetGeoTransform()
        largura= datafile.RasterXSize
        altura = datafile.RasterYSize
        xmin=geoinfo[0]
        ymax=geoinfo[3]
        pixsize = geoinfo[1]
        xmax=xmin+largura*pixsize
        ymin=ymax-altura*pixsize

        sainuvem = files.replace("ClassN.tif", "DBN_nuvem.tif")
        print "coordenadas corte:",xmin,ymin,xmax,ymax, largura, altura, pixsize
        os.system("gdal_rasterize  -burn 1 -l NUVEM2006_Amazonia_erased -ts "+str(largura)+" "+str(altura)+" -te "+
        str(xmin)+" "+str(ymin)+" "+str(xmax)+" "+str(ymax)+" "+
        nuvem + ' ' + sainuvem + " -ot Byte")

        calculate_band(files, sainuvem , 1, 1, sainuvem.replace("_nuvem","_negativo"), '*')
    dataSourcen = None
    #os.system("gdalbuildvrt "+pathto+"Mosaico_Class.vrt "+pathto+"*Class.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_ClassNegativo.vrt "+pathto+"*ClassN.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_negativo.vrt "+pathto+"*DBN_negativo.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_DB.vrt "+pathto+"*HHDB.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_DB_nuvem.vrt "+pathto+"*DB_nuvem.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_DBN_Nuvem.vrt "+pathto+"*DBN_nuvem.tif")
    #os.system("gdalbuildvrt "+pathto+"Mosaico_Resultado.vrt "+pathto+"*resultado.tif")



#gera negativo dos resultados

    for files in glob.glob(pathto+"*HH"):
        entrada = files
        saida = files+"DB_N.tif"
        referencia = "alpr"
        export_alos(entrada,saida,referencia,1)

#Open shapefile to be compared with DB images
    nuvem = glob.glob(pathto+"*N*.shp")[0]
    dataSourcen = driver.Open(nuvem, 0)
    layern = dataSourcen.GetLayer()


    for files in glob.glob(pathto+"*ClassN.tif"):
        datafile = gdal.Open(files)
        geoinfo = datafile.GetGeoTransform()
        largura= datafile.RasterXSize
        altura = datafile.RasterYSize
        xmin=geoinfo[0]
        ymax=geoinfo[3]
        pixsize = geoinfo[1]
        xmax=xmin+largura*pixsize
        ymin=ymax-altura*pixsize

        sainuvem = files.replace("ClassN.tif", "DBN_nuvem.tif")
        print "coordenadas corte:",xmin,ymin,xmax,ymax, largura, altura, pixsize
        os.system("gdal_rasterize  -burn 1 -l NUVEM2006_Amazonia_erased -ts "+str(largura)+" "+str(altura)+" -te "+
        str(xmin)+" "+str(ymin)+" "+str(xmax)+" "+str(ymax)+" "+
        nuvem + ' ' + sainuvem + " -ot Byte")

        calculate_band(files, sainuvem , 1, 1, sainuvem.replace("_nuvem","_negativo"), '*')
    dataSourcen = None





    f = 0
    pixtot = 0.0
    pixsum = 0.0
    for files in glob.glob(pathto+"*resultado.tif"):
        #os.system("""gdal_polygonize.py -8 -f "ESRI Shapefile" """+files + " "+files.replace(".tif", ".shp") )
        mos_res = gdal.Open(files, GA_ReadOnly )
        band = mos_res.GetRasterBand(1)
        data = BandReadAsArray(band)
        #print "pixels:", np.size(data)
        #print "soma:", sum(data)
        #print "minimo:", data.min()
        #print "maximo:", data.max()
        #print "variancia:", data.var()
        #print "desvio padrao:", data.std()
        pixtot = pixtot + np.size(data)
        pixsum = pixsum + sum(data)
        f+=1
    print "ESTAT Resultados:"
    print "pixels:",pixtot
    print "valor 1:",pixsum
    print "porcentual 1:",pixsum/pixtot*100,"%"
    print "Area aprox total(ha):", 22.2*22.2*pixtot/10000
    print "Area aprox 1(ha):", 22.2*22.2*pixsum/10000
    print "Arquivos:", f
    band = None
    data = None
    mos_res = None


    f = 0
    pixtotn = 0.0
    pixsumn = 0.0
    for files in glob.glob(pathto+"*DB_nuvem.tif"):
        mos_res = gdal.Open(files, GA_ReadOnly )
        band = mos_res.GetRasterBand(1)
        data = BandReadAsArray(band)
        #print "pixels:", np.size(data)
        #print "soma:", sum(data)
        #print "minimo:", data.min()
        #print "maximo:", data.max()
        #print "variancia:", data.var()
        #print "desvio padrao:", data.std()
        pixtotn = pixtotn + np.size(data)
        pixsumn = pixsumn + sum(data)
        f+=1
    print "ESTAT nuvens:"
    print "pixels:",pixtotn
    print "valor 1:",pixsumn
    print "porcentual 1:",pixsumn/pixtotn*100,"%"
    print "Area aprox total(ha):", 22.2*22.2*pixtotn/10000
    print "Area aprox 1(ha):", 22.2*22.2*pixsumn/10000
    print "Arquivos:", f

    print "Resultado/nuvem:", pixsum/pixsumn*100, "%"

    band = None
    data = None
    Mos_res = None





