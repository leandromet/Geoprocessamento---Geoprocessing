from osgeo import ogr
import os
from osgeo import osr
from qgis.core import *

shapefile = "C:/Users/pedro.mendes/Desktop/Brasil_00_2016.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, 0)
layer = dataSource.GetLayer()
proj=layer.GetSpatialRef()


outputMergefn =  "C:/Users/pedro.mendes/Desktop/Brasil_01_2016.shp"


driverName = 'ESRI Shapefile'
geometryType = ogr.wkbPolygon
out_driver = ogr.GetDriverByName( driverName )
if os.path.exists(outputMergefn):
    out_driver.DeleteDataSource(outputMergefn)
out_ds = out_driver.CreateDataSource(outputMergefn)
out_layer = out_ds.CreateLayer(outputMergefn, geom_type=geometryType, srs=proj)




juntaDefn=layer.GetLayerDefn()
juntaFeat=ogr.Geometry(3)

c=0

for feature in layer:
    geom = feature.GetGeometryRef()
    geom2 = geom.Difference(juntaFeat)
    juntaFeat= juntaFeat.Union(geom)
    out_feat = ogr.Feature(out_layer.GetLayerDefn())
    out_feat.SetGeometry(geom2)
    out_layer.CreateFeature(out_feat)
    out_layer.SyncToDisk()
    c+=1
    #break

    
layer = None
dataSource=None
    
print "total de feicoes: %i " %( c)
