# Rcode
R code: multi-temporal image and temperature data analysis 
TS_fitting.R: Fit a double logistic function to a Sentinel-2 vegetation index (VI) time series. The first step is to fit separate double logistic functions to two (overlapping)   S2 NDVI time series. Then both local functions are merged to obtain a single global function
temp_nc.R: Retrieving multi-temporal max/min temperature data for specific locations from gridded nc files. The data are written in the CSV format.
