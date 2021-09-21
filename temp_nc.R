################################################################################
## MODIFICATION HISTORY:
##   Written by:  Xinyan Fan (x.fan-1@utwente.nl), August 2019
##   Modified September 2021 for extracting max/min temperature data from gridded daily temperature dataset  
##
## NAME:
##   temp_nc

## PURPOSE:
##   Output multi-temporal max/min temperature data from gridded daily temperature dataset
##
## INPUTS:
##   - shapefile of maize fields within the Netherlands
##   - grided daily max/min temperature data (nc files)
##
################################################################################
library(ncdf4)
library(raster)
shpfile<-shapefile("D:/FieldWork_covercrop/ShapeFile_fieldwork/Maize_shapefile/mais/2017maize_Overijssel_expend_buffer5.shp")
spei_nc=nc_open("D:/WeatherData/season2017/min.nc") 
data= matrix(data=NA, nrow=14835, ncol=153)


mtrx <- ncvar_get(spei_nc, varid="prediction")[,,1] # extact value. i is for time step number 3
spei_r <- raster(t(mtrx),xmn=-180, xmx=180, ymn=-90, ymx=90) # create a raster with data (it is flipped)
spei_r <- flip(spei_r,2) # correct raster
projection(spei_r) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ' # add CRS
g <- spTransform(shpfile, spei_r@crs) # reproject shapefile
ID<-data.frame(ID=g$OBJECTID)

for (i in 92:126){
  mtrx <- ncvar_get(spei_nc, varid="prediction")[,,i] # extact value. i is for time step number 3
  spei_r <- raster(t(mtrx),xmn=-180, xmx=180, ymn=-90, ymx=90) # create a raster with data (it is flipped)
  spei_r <- flip(spei_r,2) # correct raster
  projection(spei_r) <- '+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 ' # add CRS
  g <- spTransform(shpfile, spei_r@crs) # reproject shapefile
  spei_values <- extract(spei_r,g) # extract values by ecah feature
  spei_mean <- extract(spei_r,g,fun=mean,na.rm=T) # extract mean by each feature
  data[,i]<-spei_mean 
} 
data1<-data.frame(ID,data)
write.csv(data1,'D:/WeatherData/season2018/tempMin_2018-1.csv')


