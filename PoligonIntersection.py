from osgeo import ogr
import os
from osgeo import osr

shapefile = "//home//leandro//GINF//pr_300_SIRGAS2000.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, 0)
layer = dataSource.GetLayer()


c = 0
dentro = 0
shapefile2 = "//home//leandro//GINF//Pteste.shp"
dataSource2 = driver.Open(shapefile2, 0)
layer2 = dataSource2.GetLayer()
4674

for feature2 in layer2:
    geom2 = feature2.GetGeometryRef()
    print geom2.GetSpatialReference()

    print geom2
    for feature in layer:
        geom = feature.GetGeometryRef()
        pt = geom.Centroid()
        pto = (pt.GetX(),pt.GetY())
        if pt.Intersects(geom2):
            dentro+=1
        print pto
        c+=1
print "total de feicoes: %i sendo %i contidas e %i nao" %( c, dentro, (c-dentro))
