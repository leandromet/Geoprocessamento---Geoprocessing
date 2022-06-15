#python function to export ALOS binary data. Receives a file name, destiny path, reference tag on name for coordinates and a binary to invert the mask
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
