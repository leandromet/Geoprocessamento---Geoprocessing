import os
from osgeo import ogr

caminho = "C:\\Users\\ana.lucio\\Downloads\\" # path to files
daShapefile = caminho+"Grid_1_pol.shp" #source geometry

driver = ogr.GetDriverByName('ESRI Shapefile')

dataSource = driver.Open(daShapefile, 0) # 0 means read-only. 1 means writeable.

# Check to see if shapefile is found.
if dataSource is None:
    print 'Could not open %s' % (daShapefile)
else:
    print 'Opened %s' % (daShapefile)
    layer = dataSource.GetLayer()
    featureCount = layer.GetFeatureCount()
    print "Number of features in %s: %d" % (os.path.basename(daShapefile),featureCount)

#Iteration over geometries, uses envelope coordinates to call gdal_translate and generate one GeoTiff file for each.

for tijolo in range(0, 40) :    #layer.GetFeatureCount()
    feat = layer.GetFeature(tijolo+410)
    geom = feat.GetGeometryRef()
    envelope = geom.GetEnvelope()
    print envelope
    print "minX: %d, minY: %d, maxX: %d, maxY: %d" %(envelope[0],envelope[2],envelope[1],envelope[3])
    
    print "\"\"C:\Program Files\QGIS Dufour\\bin\gdal_translate\" -projwin "+str(envelope[0])+" "+str(envelope[3])+" "+str(envelope[1])+" "+str(envelope[2])+" -of GTiff \""+caminho+"mosaico07-04.bil\" \""+caminho+"tiles\\grid_"+str(tijolo)+".tif\"\""
    
    os.system("\"\"C:\Program Files\QGIS Dufour\\bin\gdal_translate\" -projwin "+str(envelope[0])+" "+str(envelope[3])+" "+str(envelope[1])+" "+str(envelope[2])+" -of GTiff \""+caminho+"mosaico07-04.bil\" \""+caminho+"tiles\\grid_"+str(tijolo+410)+".tif\"\"")
    
    
    
    
