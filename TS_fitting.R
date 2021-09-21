################################################################################
## Title: Fit a double logistic function to a Sentinel-2 vegetation index (VI) time series
## 
## Requirements:
## - install package 'greenbrown': http://greenbrown.r-forge.r-project.org/
## - Sentinel-2(S2) global observation: load S2 time-series observations in the CSV format
## - Two separated local time-series (maize growth and decline; maize decline and cover crop growth) in the CSV format: 
##   note: to obtain the two separated local time-series, pre-processing could be done outside R 
##   (1) Daily interpolation of S2 time-series using Piecewise Cubic Hermite Interpolation 
##   (2) Separate interpolated time-series into two local time-series based on defined principles (specific thresholds) in time  
##
################################################################################

################################################################################
##
## Preparation
##
################################################################################
## Set working space
setwd("D:/Theia/aggregate") 

## Importing the sample data
NDVI_S2 <- read.csv('NDVI_S2.csv',header=FALSE)     # Sentinel-2 observation (global)
maizedat <- read.csv('maize_TS.csv',header=FALSE)   # Interpolated time-series for maize growth and decline
coverdat <- read.csv('cover_TS.csv',header=FALSE)	  # Interpolated time-series for maize decline and cover crop growth

################################################################################
##
## Fitting of two local time-series
##
################################################################################

library(greenbrown)
ndvi_maize<-maizedat[,2]
ndvi_cover<-coverdat[,2]
fit_maize=FitDoubleLogElmore(ndvi_maize, hessian=TRUE, ninit=3000)
fit_cover=FitDoubleLogElmore(ndvi_cover, hessian=TRUE, ninit=3000)

################################################################################
##
## Merging of two fitted local time-series
##
################################################################################
mergeLength = maizedat[nrow(maizedat),1]-coverdat[1,1]+1;
mergeTS <- c()

for (i in 1:mergeLength){
  weightLeft  = 1.-1./(mergeLength-1)*(i-1);
  weightRight =    1./(mergeLength-1)*(i-1);
  dat_maize=fortify.zoo(fit_maize$predicted)[,2]
  dat_cover=fortify.zoo(fit_cover$predicted)[,2]
  mergeTS[i] = weightLeft*dat_maize[length(fit_maize$predicted)-mergeLength+i]+weightRight*dat_cover[i]}

TS = c(head(dat_maize,length(dat_maize)-mergeLength),mergeTS,tail(dat_cover,length(dat_cover)-mergeLength))
time_TS=maizedat[1,1]:(length(TS)+maizedat[1,1]-1);

# Figure
plot(NDVI_S2[,1],NDVI_S2[,2], col="black",xlab="Date", ylab=" (1e+04) X NDVI")
lines(time_TS,TS,type="l", col="red")

