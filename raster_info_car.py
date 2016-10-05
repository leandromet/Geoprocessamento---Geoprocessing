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

for infile in glob.glob(r'C:\Users\pedro.mendes\Desktop\Brasil_00_2016.shp'):


    print infile
   

#    for featurebr in layerbr:
#        print featurebr.GetField(1)
#        geom = featurebr.GetGeometryRef()
#        print 'estado', geom.GetEnvelope()
    rapideye = infile
    driver = ogr.GetDriverByName("ESRI Shapefile")
    dataSource_rd = driver.Open(rapideye, True)
    layer_rd = dataSource_rd.GetLayer()







    shapefile = "C:/Users/pedro.mendes/Desktop/Brasil_01_2016.shp"
    dataSource = driver.Open(shapefile, True)
    layer = dataSource.GetLayer()
          
    
    SpatialRef = osr.SpatialReference()
    SpatialRef.SetWellKnownGeogCS( "EPSG:102033" )
        
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
    
    
    
    
    for feat_rd in layer_rd:
        caminho_img = feat_rd.GetField("caminho")
        print caminho_img
        try:
            src_ds = gdal.Open( caminho_img)
        except RuntimeError, e:
            print 'Unable to open INPUT'
            print e
            break
        try:
            srcband = src_ds.GetRasterBand(1)
            print srcband
        except RuntimeError, e:
            # for example, try GetRasterBand(10)
            print 'Band ( %i ) not found' % band_num
            print e
            sys.exit(1)
        banda_class = srcband.ReadAsArray().astype(np.float)
        
        
        geom=feat_rd.GetGeometryRef()
        contorno = geom.GetEnvelope()
        x_min = contorno[0]
        y_max = contorno[3]
        x_res = 5000
        y_res = 5000
        target_ds = gdal.GetDriverByName('MEM').Create('', x_res, y_res, gdal.GDT_Byte)
        target_ds.SetGeoTransform((x_min, pixel_size, 0, y_max, 0, -pixel_size))
        band = target_ds.GetRasterBand(1)
        band.SetNoDataValue(NoData_value)       
        
         
        
        conta=0
        for feature in layer:
            geom2=feature.GetGeometryRef()
            #print 'feat' , caminho_feat
            if geom2.Intersects(geom2):
                print "aqui"
                conta+=1
                if os.path.exists('C:\\Users\\pedro.mendes\\Desktop\\temporario.shp'):
                    driver.DeleteDataSource('C:\\Users\\pedro.mendes\\Desktop\\temporario.shp')
                
                dstdata = driver.CreateDataSource('C:\\Users\\pedro.mendes\\Desktop\\temporario.shp')
                dstlayer = dstdata.CreateLayer("teste3") 
                intersect = geom.Intersection(geom2)
                
                dstfeature = ogr.Feature(dstlayer.GetLayerDefn())
                dstfeature.SetGeometry(intersect)
                dstlayer.CreateFeature(dstfeature)
                #print 'resultado', dstfeature.GetGeometryRef().GetEnvelope()

                # Rasterize
                gdal.RasterizeLayer(target_ds, [1], dstlayer, burn_values=[1])
                array = band.ReadAsArray()
                print np.histogram(array, bins=[0,1,250,300]) 
                # Read as array
                dstlayer=None
                dstdata.Destroy()


                #tabela = srcband.ReadAsArray()
                #print tabela
                classes = banda_class
                resposta1 = np.histogram(classes, bins=[0,1,20])
                if classes.size==(5000*5000):
                    classes = classes*array
                resposta = np.histogram(classes, bins=[0,1,2,3,4,5,6,7,8,9,10,11,12,20])
                
                print 'valor', resposta[1][0], 'contagem', resposta[0][0]
                print 'valor', resposta[1][2], 'contagem', resposta[0][2]
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
                
            #break
        layer.ResetReading()
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
