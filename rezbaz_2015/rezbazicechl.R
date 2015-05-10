## Example
## build map of recent Southern Ocean chlorophyll-a
##  with 
library(raadtools)
library(rworldmap)
library(rgdal)
library(geosphere)
library(roc)
data(countriesLow)

## transform to projection
prj <- "+proj=stere +lat_0=-90 +lon_0=145 +lat_ts=-70 +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs"
w <- spTransform(subset(countriesLow, coordinates(countriesLow)[,2] < 10), CRS(prj))
w2 <- spTransform(coastmap("ant_coast10"), CRS(prj))

## pre-determined extent in map projection
e <- new("Extent"
         , xmin = -3182988.38223535
         , xmax = 2549350.8917791
         , ymin = 1212351.63713354
         , ymax = 6776092.69720639
)
dummy <- as(raster(e, nrow = 12, ncol =12, crs = prj), "SpatialPoints")

## obtain latest files and work through dates
ocf <- ocfiles()
range(ocf$date)

## read the data, calculate chlorophyll-a
d <- readL3(ocf$fullname[nrow(ocf)-1])
d$chla <- chla(d, sensor = "MODISA", algo = "johnson")
xy <- do.call(cbind, bin2lonlat(d$bin_num, d$NUMROWS))
xy <- project(xy, prj)
ice <- readice(ocf$date[nrow(ocf)])
pice <- projectRaster(ice, crs = prj)
recentdays <- projectRaster(readice(getZ(ice) - c(51, 31, 21) * 24 * 3600), crs = prj)

## set up and plot
##png(width = 960, height = 960)
par(bg = "aliceblue")
plot(e + 1e4, type = "n", asp = 1, axes = FALSE, xlab = "", ylab = "")
plot(w2, col = c("grey80", "grey")[w2$cst10srf], add = TRUE)
plot(subset(w, SOVEREIGNT != "Antarctica"), add = TRUE, col = "grey")
pice[!pice > 0] <- NA_real_
plot(pice, col = grey(seq(0.3, .9, length = 100)), add = TRUE, legend = FALSE)
points(xy, pch = ".", col = chl.pal(d$chla))
for (i in 1:nlayers(recentdays)) contour(recentdays[[i]], label = "", lev = 15, add = TRUE, lwd = i)
title("MODISA chlorophyll-a and recent sea ice cover", format(as.Date(getZ(ice))))
##dev.off()
