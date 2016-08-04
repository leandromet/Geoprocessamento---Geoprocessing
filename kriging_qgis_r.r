
##Basic statistics=group
##Layer=vector
##Field=Field Layer
## by= number 0.1
##Output=output raster
##Bibliotecas utilizadas para a krigagem
library(gstat)
library(rgl)
library("spatstat")
library("maptools")
install.packages("pls")
library (pls)
library(automap)
library(raster)
##Abertura de dados e alocação de variáveis
Y<-as.factor(Layer[[Field]])
attribut<-as.data.frame(Y)
A<-as.numeric(Y)
for(j in (1:length(levels(Y))))
for(i in 1:dim(attribut)[1]){
if (attribut[i,1]==levels(Y)[j]){
A[i]=j } }
##Carregamento das informações espaciais
coords<-coordinates(Layer)
Mesure<- data.frame(LON=coords[,1], LAT=coords[,2], A)
coordinates(Mesure)<-c("LON","LAT")
MinX<-min(coords[,1])
MinY<-min(coords[,2])
MaxX<-max(coords[,1])
MaxY<-max(coords[,2])
Seqx<-seq(MinX, MaxX, by=by)
Seqy<-seq(MinY, MaxY, by=by)
MSeqx<-rep(Seqx, length(Seqy))
MSeqy<-rep(Seqy, length(Seqx))
MSeqy <- sort(MSeqy, decreasing=F)
##Criação da planilha para execução no R
Grille <- data.frame(X=MSeqx, Y=MSeqy)
coordinates(Grille)=c("X","Y")
gridded(Grille)<-TRUE
##Extração do variograma com regressão automática para modelagem com modelo de crescimento exponencial
v<-autofitVariogram(A~1,Mesure,model = "Exp")
##Krigagem simples com R
prediction <-krige(formula=A~1, Mesure, Grille, model="Exp")
##Saída de dados para o QGIS
result<-raster(prediction)
proj4string(Layer)->crs
proj4string(result)<-crs
Output<-result

