from osgeo import ogr
import os

shapefile = "//mnt//hgfs//Biondo//GINF//Florestas_Parana//pr_300_f22.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, 0)
layer = dataSource.GetLayer()

for feature in layer:
    geom = feature.GetGeometryRef()
    pt = geom.Centroid()
    pto = (pt.GetX(),pt.GetY())
    print pto
