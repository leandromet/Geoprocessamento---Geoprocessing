import os
from osgeo import ogr, osr
import glob

print 'inicio'

lista = ('RO', 'RR', 'TO')

for item in lista:
    outputMergefn = 'C:\\Biondo\\ALOS_PRODES\\floresta\\merge\\'+item+'_merge.shp'
    driverName = 'ESRI Shapefile'
    geometryType = ogr.wkbPolygon

    out_driver = ogr.GetDriverByName( driverName )
    if os.path.exists(outputMergefn):
	out_driver.DeleteDataSource(outputMergefn)
    out_ds = out_driver.CreateDataSource(outputMergefn)
    out_layer = out_ds.CreateLayer(outputMergefn, geom_type=geometryType)

    fileList = glob.glob('C:\\Biondo\\ALOS_PRODES\\floresta\\P*'+item+'*.shp')

    for file in fileList:
	if file.endswith('.shp'):
	    print file
	    ds = ogr.Open(file)
	    lyr = ds.GetLayer()
	    for feat in lyr:
		out_feat = ogr.Feature(out_layer.GetLayerDefn())
		out_feat.SetGeometry(feat.GetGeometryRef().Clone())
		out_layer.CreateFeature(out_feat)
		out_layer.SyncToDisk()
	

print 'FIM'
