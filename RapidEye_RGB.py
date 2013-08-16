#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      leandro.biondo
#
# Created:     02/08/2013
# Copyright:   (c) leandro.biondo 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python

# importar modulo


import os, glob
import fileinput
import string
import arcpy
from arcpy import env
from arcpy import da

for infile in glob.glob('d:\\Biondo\\gcad\\rapideye\\*\\*.tif'):    
    arcpy.MakeRasterLayer_management(infile, "layer4.tif", "#", "", "4")
    arcpy.MakeRasterLayer_management(infile, "layer5.tif", "#", "", "5")
    arcpy.MakeRasterLayer_management(infile, "layer2.tif", "#", "", "2")
    arcpy.CompositeBands_management("layer4.tif;layer5.tif;layer2.tif","rgb452.tif")





#-------------------------------------------------------------------------------
