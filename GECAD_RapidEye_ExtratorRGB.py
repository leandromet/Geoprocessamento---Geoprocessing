import os, glob
import fileinput
import string
import arcpy
import shutil
from arcpy import env
from arcpy import da

#Define funcao para ignorar arquivos na criacao de arvore
def ig_f(dir, files):
    return [f for f in files if os.path.isfile(os.path.join(dir, f))]

#Copia estrutura de pastas para onde vao os resultados
shutil.copytree('U:\\imagens2\\RapidEye\\NORDESTE\\FUSO_22S\\', 'D:\\Biondo\\gcad\\rapideye\\dados\\Teste\\', symlinks=False, ignore=ig_f)


#Laco que encontra todos os arquivos TIF a serem processados
for infile in glob.glob('U:\\imagens2\\RapidEye\\NORDESTE\\FUSO_22S\\*\\*.tif'):
#Ignora arquivos "browse."
    if infile.find("browse.") == -1:
#Ignora arquivos "udm."
        if infile.find("udm.") == -1:
#Verifica arquivo de entrada, cria arquivo de saida a partir do de entrada
                print infile
                outfile = infile.replace('.tif', 'rgb.tif')
                outfile = outfile.replace('U:\\imagens2\\RapidEye\\NORDESTE\\FUSO_22S\\', 'D:\\Biondo\\gcad\\rapideye\\dados\\Teste\\')
                print outfile
#Extrai apenas as camadas da imagem referentes a bandas RGB
                arcpy.env.workspace = 'D:\\Biondo\\gcad\\rapideye\\dados\\'
                arcpy.MakeRasterLayer_management(infile, "layer4.tif", "#", "", "4")
                arcpy.MakeRasterLayer_management(infile, "layer5.tif", "#", "", "5")
                arcpy.MakeRasterLayer_management(infile, "layer2.tif", "#", "", "2")

#Compoe nova imagem e salva na estrutura criada com nome do arquivo original e um "rgb" no final
                arcpy.CompositeBands_management("layer4.tif;layer5.tif;layer2.tif",outfile)
    





#-------------------------------------------------------------------------------
