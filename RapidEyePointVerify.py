from osgeo import ogr
import os
from osgeo import osr
import glob

shapefile = "//home//leandro//GINF//pr_300_SIRGAS2000.shp"
driver = ogr.GetDriverByName("ESRI Shapefile")
dataSource = driver.Open(shapefile, 0)
layer = dataSource.GetLayer()



shapefile2 = "//home//leandro//GINF//pr_RapidEye_SIRGAS2000.shp"
dataSource2 = driver.Open(shapefile2, 0)
layer2 = dataSource2.GetLayer()

for feature2 in layer2:
    c = 0
    dentro = 0
    geom2 = feature2.GetGeometryRef()
    TileId = int(feature2.GetField("TILE_ID"))
    for feature in layer:
        geom = feature.GetGeometryRef()
        pt = geom.Centroid()
        if pt.Intersects(geom2):
            dentro+=1
            #Laco que encontra todos os arquivos TIF a serem processados
            for infile in glob.glob(r'/mnt/hgfs/Biondo/GINF/Florestas_Parana/Imagens_RapidEye/*%s*.tif'%TileId):
            #Ignora arquivos "browse."
                if infile.find("browse.") == -1:
            #Ignora arquivos "udm."
                    if infile.find("udm.") == -1:
                        print infile
        c+=1
    layer.ResetReading()
    print "Pontos: %i sendo %i contidas e %i nao" %( c, dentro, (c-dentro))
    if dentro > 0:
        print TileId
