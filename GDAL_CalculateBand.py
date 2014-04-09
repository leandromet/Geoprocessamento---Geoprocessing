
#simple math calculation with raster bands using gdal

def get_operator_fn(op):
#translates a character to be used as operator on calculation
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
        #each file, can be used with same raster file and different bands, receives 
        #2 data sources, the intended band of each, output file name and the operator (+,-,*,/,%,^)


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
