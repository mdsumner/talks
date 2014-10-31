setwd("~/data")

file.copy("/rdsi/PRIVATE/bathymetry/etopo1/ETOPO1_Ice_g_gdal.grd", "ETOPO1_Ice_g_gdal.grd")
file.copy("/rdsi/PRIVATE/sst/OI-daily-v2/daily/2014/avhrr-only-v2_20140301.nc", "avhrr-only-v2_20140301.nc")

f <- "ftp://www.usgodae.org/pub/outgoing/argo/latest_data/D20140725_prof.nc"
download.file(f, basename(f))

file.copy("/rdsi/PRIVATE/wind/ncep2/daily/uwnd.10m.gauss.2013.nc", "uwnd.10m.gauss.2013.nc")
file.copy("/rdsi/PRIVATE/wind/ncep2/daily/vwnd.10m.gauss.2013.nc", "vwnd.10m.gauss.2013.nc")
file.copy( "/rdsi/PRIVATE/chl/johnson/modis/8d/A20123612012366.L3m_8D_SO_Chl_9km.Johnson_SO_Chl.nc", 
           "A20123612012366.L3m_8D_SO_Chl_9km.Johnson_SO_Chl.nc")


Mike: stick to open.nc(), print.nc(), readlon, readlat, readsst - plot it
    - then repeat but do it for uwnd and vwnd - topic of slicing, either in R or with NetCDF
    - 



ncETOPO1_Ice_g_gdal.grd
ncdump -h avhrr-only-v2_20140301.nc  
ncdump -h D20140725_prof.nc  
ncdump -h uwnd.10m.gauss.2013.nc  
ncdump -h vwnd.10m.gauss.2013.nc
ncdump -h A20123612012366.L3m_8D_SO_Chl_9km.Johnson_SO_Chl.nc


On katabatic: 
  
module load netcdf/4.0.1-intel
ncdump -h /ds/projects/iomp/caisom/mdl/caisom008/ocean_hisq_0005.nc  > ocean_hisq_0005.txt


## Basic R code

library(RNetCDF)
nc <- open.nc("D20140725_prof.nc")
print.nc(nc)


## two things we might actually be interested in "PRES_ADJUSTED" and "PSAL_ADJUSTED": 

# float PRES_ADJUSTED(N_LEVELS, N_PROF) ;
# PRES_ADJUSTED:long_name = "Sea water pressure, equals 0 at sea-level" ;
# PRES_ADJUSTED:standard_name = "sea_water_pressure" ;
# PRES_ADJUSTED:_FillValue = 99999 ;
# PRES_ADJUSTED:units = "decibar" ;
# PRES_ADJUSTED:valid_min = 0 ;
# PRES_ADJUSTED:valid_max = 12000 ;
# PRES_ADJUSTED:C_format = "%7.1f" ;
# PRES_ADJUSTED:FORTRAN_format = "F7.1" ;
# PRES_ADJUSTED:resolution = 0.1 ;
# 
# 
# float PSAL_ADJUSTED(N_LEVELS, N_PROF) ;
# PSAL_ADJUSTED:long_name = "Practical salinity" ;
# PSAL_ADJUSTED:standard_name = "sea_water_salinity" ;
# PSAL_ADJUSTED:_FillValue = 99999 ;
# PSAL_ADJUSTED:units = "psu" ;
# PSAL_ADJUSTED:valid_min = 2 ;
# PSAL_ADJUSTED:valid_max = 41 ;
# PSAL_ADJUSTED:C_format = "%9.3f" ;
# PSAL_ADJUSTED:FORTRAN_format = "F9.3" ;
# PSAL_ADJUSTED:resolution = 0.001 ;
# 


## Recursively, we can find coordinates for the dimensions of the variables:

# double LATITUDE(N_PROF) ;
# LATITUDE:long_name = "Latitude of the station, best estimate" ;
# LATITUDE:standard_name = "latitude" ;
# LATITUDE:units = "degree_north" ;
# LATITUDE:_FillValue = 99999 ;
# LATITUDE:valid_min = -90 ;
# LATITUDE:valid_max = 90 ;
# LATITUDE:axis = "Y" ;

# double LONGITUDE(N_PROF) ;
# LONGITUDE:long_name = "Longitude of the station, best estimate" ;
# LONGITUDE:standard_name = "longitude" ;
# LONGITUDE:units = "degree_east" ;
# LONGITUDE:_FillValue = 99999 ;
# LONGITUDE:valid_min = -180 ;
# LONGITUDE:valid_max = 180 ;
# LONGITUDE:axis = "X" ;

# double JULD_LOCATION(N_PROF) ;
# JULD_LOCATION:long_name = "Julian day (UTC) of the location relative to REFERENCE_DATE_TIME" ;
# JULD_LOCATION:units = "days since 1950-01-01 00:00:00 UTC" ;
# JULD_LOCATION:conventions = "Relative julian days with decimal part (as parts of day)" ;
# JULD_LOCATION:resolution = 1e-05 ;
# JULD_LOCATION:_FillValue = 999999 ;

pres <- var.get.nc(nc, "PRES_ADJUSTED")
image(pres)
psal <- var.get.nc(nc, "PSAL_ADJUSTED")
lon <- as.vector(var.get.nc(nc, "LONGITUDE"))
lon180 <- !is.na(lon) & lon < 0
lon[lon180] <- lon[lon180] + 360
lat <- as.vector(var.get.nc(nc, "LATITUDE"))
time <- as.vector(var.get.nc(nc, "JULD_LOCATION")) * 24 * 3600 + as.POSIXct("1950-01-01 00:00:00", tz = "GMT")
 

end <- which(diff(time) < 0)[1] - 1

image(time[1:end], 1:115, t(psal)[1:end, nrow(pres):1], col = sst.pal(256))


