#-------------------------------------------------------------------------------
# Name:        Raster information from vector relations
# Purpose:     Classify features of interest based on a raster with pixels that have classification values.
#               Having a catalog in a vector layer with adresses of images related to each polygon, count
#               the pixels with given values that are inside any given polygon. The raster files have a
#               land usage classification that was automaticaly generated, this classification covers the
#               whole country. We have rural properties boundaries and other poligons that we want to verify
#               how much area was classified as being one of 13 distinct classes. This aproach gets each
#               image boundary polygon intersection with each feature of interest and builds a raster mask.
#               The mask has the same resolution as the original image (RapidEye, 5 meters) with binary values,
#               being 1 if the pixel is part of the intersection and 0 if it is not. This mask is then multiplied
#               as a matrix by the matrix of pixel values from the image (in this case 14 possible values).
#               Finally a histogram is made with bins that separate the intended classes and the count of
#               each bin is added to the vector layer with features of interest.
#
# Author:      leandro.biondo
#
# Created:     05/10/2016
# Copyright:   (c) leandro.biondo 2016
# Licence:     GNU GLP
#-------------------------------------------------------------------------------
#!/usr/bin/env python

# import modules


import gdal
import numpy as np
from osgeo import ogr, osr
import glob
import os


gdal.UseExceptions()
#
#shapefilebr =  "C:/biondo/buff_nasc.shp"
#driver = ogr.GetDriverByName("ESRI Shapefile")
#dataSourcebr = driver.Open(shapefilebr, True)
#layerbr = dataSourcebr.GetLayer()

#Here should be given the vector layer with the catalog, This catalog can be built with the Qgis plugin
#"Image Footprint", it is necessary to select image boudary option. The path (caminho) field will be used to open
#the images with classified pixels, you can use a * as mask if there are more then 1 catalog

for infile in glob.glob(r'D:\compartilhado\_Denilson\Scripts_Finais\Extract_Info_class_CAR\catalogo_completo_class_fipe_sirgas1.shp'):

    print infile
    rapideye = infile
    driver = ogr.GetDriverByName("ESRI Shapefile")
    dataSource_rd = driver.Open(rapideye, True)
    layer_rd = dataSource_rd.GetLayer()


    shapefile = ('D:\\compartilhado\\_Denilson\\Scripts_Finais\\Extract_Info_class_CAR\\Imoveis_teste_Sobreposicao.shp')
    dataSource = driver.Open(shapefile, True)
    layer = dataSource.GetLayer()




    layer.CreateField(ogr.FieldDefn("0_indef", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("1_uso_cons", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("2_rvegnat", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("3_vereda", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("4_mangue", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("5_Salgado", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("6_Apicum", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("7_Restinga", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("8_Agua", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("9_Vegremo", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("10_Regene", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("11_Areaurb", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("12_Nuvens", ogr.OFTInteger),False)
    layer.CreateField(ogr.FieldDefn("13_ForaLi", ogr.OFTInteger),False)

    pixel_size = 5
    NoData_value = 255

    contard  =0
    c5=0

    for feat_rd in layer_rd:
        caminho_img = feat_rd.GetField("caminho")
        print caminho_img
        try:
            src_ds = gdal.Open( caminho_img)
        except RuntimeError, e:
            print 'Unable to open INPUT'
            print e
            #break
            continue
        try:
            srcband = src_ds.GetRasterBand(1)
            print srcband
        except RuntimeError, e:
            # for example, try GetRasterBand(10)
            print 'Band ( %i ) not found' % band_num
            print e
            #sys.exit(1)
            continue
        banda_class = srcband.ReadAsArray().astype(np.float)
        if banda_class.size==(5000*5000):
            classes = banda_class


            geom=feat_rd.GetGeometryRef()
            #print 'spat  ', layer_rd.GetSpatialRef()
           # print 'proj  ', src_ds.GetProjection()
            contorno=geom.GetEnvelope()
            x_min = contorno[0]
            y_max = contorno[3]
            x_res = 5000
            y_res = 5000
#            target_ds = gdal.GetDriverByName('MEM').Create('', x_res, y_res, gdal.GDT_Byte)
#            target_ds.SetGeoTransform(src_ds.GetGeoTransform())
#            target_ds.SetProjection(src_ds.GetProjection())
#            band = target_ds.GetRasterBand(1)
#            band.SetNoDataValue(NoData_value)
#

            contard=contard+1
            conta=0

            for feature in layer:
                geom2=feature.GetGeometryRef()
                #print 'feat' , caminho_feat
                if geom2.Intersects(geom):
                   
                    intersect = geom.Intersection(geom2)
                    #print intersect.GetArea()
                    #print (intersect.GetArea()/geom2.GetArea())
                    if (intersect.GetArea()/geom2.GetArea())<0.5:
                        continue
                 
                    #print "aqui"
                    conta+=1
                   # if os.path.exists('D:\\compartilhado\\_Denilson\Scripts_Finais\\Extract_Info_class_CAR\\temporario.shp'):
                   #     driver.DeleteDataSource('D:\\compartilhado\\_Denilson\Scripts_Finais\\Extract_Info_class_CAR\\temporario.shp')
                    
                    
                    
                    
                    SpatialRef = osr.SpatialReference()
                    SpatialRef.SetWellKnownGeogCS( "EPSG:4674" )
                    #dstdata = driver.CreateDataSource('D:\\compartilhado\\_Denilson\Scripts_Finais\\Extract_Info_class_CAR\\temporario.shp')
                    memoutdriver=ogr.GetDriverByName('MEMORY')
                    memsource=memoutdriver.CreateDataSource('memData')
                    tmp=memoutdriver.Open('memData', 1)
                    dstlayer = memsource.CreateLayer('teste', SpatialRef)
                    
                    target_ds = gdal.GetDriverByName('MEM').Create('', x_res, y_res, gdal.GDT_Byte)
                    target_ds.SetGeoTransform(src_ds.GetGeoTransform())
                    target_ds.SetProjection(src_ds.GetProjection())
                    band = target_ds.GetRasterBand(1)
                    band.SetNoDataValue(NoData_value)
                    
                    dstfeature = ogr.Feature(dstlayer.GetLayerDefn())
                    dstfeature.SetGeometry(intersect)
                    dstlayer.CreateFeature(dstfeature)
                   # print 'resultado', dstfeature.GetGeometryRef().GetEnvelope()

                    # Rasterize
                    gdal.RasterizeLayer(target_ds, [1], dstlayer, burn_values=[1])
                    array = band.ReadAsArray()
                   # print np.histogram(array, bins=[0,1,250,300])
                    # Read as array
                    dstlayer=None
                    memsource.Destroy()


                    #tabela = srcband.ReadAsArray()
                    #print tabela

                    resposta1 = np.histogram(classes, bins=[0,1,20])

                    classes2 = classes*array
                    resposta = np.histogram(classes2, bins=[0,1,2,3,4,5,6,7,8,9,10,11,12,20])

                    #print 'valor', resposta[1][0], 'contagem', resposta[0][0]
                   # print 'valor', resposta[1][2], 'contagem', resposta[0][2]
                    feature.SetField("0_indef", int(resposta1[0][0]*25))
                    feature.SetField("1_uso_cons", int(resposta[0][1]*25))
                    feature.SetField("2_rvegnat", int(resposta[0][2]*25))
                    feature.SetField("3_vereda", int(resposta[0][3]*25))
                    feature.SetField("4_mangue", int(resposta[0][4]*25))
                    feature.SetField("5_Salgado", int(resposta[0][5]*25))
                    feature.SetField("6_Apicum", int(resposta[0][6]*25))
                    feature.SetField("7_Restinga", int(resposta[0][7]*25))
                    feature.SetField("8_Agua", int(resposta[0][8]*25))
                    feature.SetField("9_Vegremo", int(resposta[0][9]*25))
                    feature.SetField("10_Regene", int(resposta[0][10]*25))
                    feature.SetField("11_Areaurb", int(resposta[0][11]*25))
                    feature.SetField("12_Nuvens", int(resposta[0][12]*25))
                    feature.SetField("13_ForaLi", int((resposta[0][0]-resposta1[0][0])*25))
                    layer.SetFeature(feature)
                    feature.Destroy()
                    print "ImagemImovel: %d | %d | %d" % (c5,contard,conta)

##create an image file and put the results in 3 band for testing purposes
#
#                    saida = "D:\\compartilhado\\_Denilson\\Scripts_Finais\\Extract_Info_class_CAR\\img%d%d.tif" % (contard,c5)
#                    format = "GTiff"
#                    driver2 = gdal.GetDriverByName( format )
#                    metadata = driver2.GetMetadata()
#                    if metadata.has_key(gdal.DCAP_CREATE) \
#                       and metadata[gdal.DCAP_CREATE] == 'YES':
#                        print 'Driver %s supports Create() method.' % format
#                    if metadata.has_key(gdal.DCAP_CREATECOPY) \
#                       and metadata[gdal.DCAP_CREATECOPY] == 'YES':
#                        print 'Driver %s supports CreateCopy() method.' % format
#
#                    dst_ds = driver2.Create( saida, 5000, 5000, 3, gdal.GDT_Float32, ['COMPRESS=LZW'] )
#                    srs = osr.SpatialReference()
#                    dst_ds.SetProjection(src_ds.GetProjection())
#                    dst_ds.SetGeoTransform(src_ds.GetGeoTransform())
#          
#                    dst_ds.GetRasterBand(1).WriteArray(classes)
#                    dst_ds.GetRasterBand(2).WriteArray(array)
#                    dst_ds.GetRasterBand(3).WriteArray(classes2)
#                    dst_ds=None
##
                    c5+=1
#                    if c5==30:
#                        layer=None
#                        dataSource=None
#                        layerbr=None
#                        dataSourcebr=None
#                        layer_rd=None
#                        dataSource_rd=None
#                        target_ds= None
#                        print 'fim'
#                        break
                        
                    target_ds= None

                #break
            layer.ResetReading()
            #break
            #break
        #break
    #break
layer=None
dataSource=None
layerbr=None
dataSourcebr=None
layer_rd=None
dataSource_rd=None
print 'fim'
