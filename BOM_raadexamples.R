library(raadtools)

## NSIDC 25km daily Southern hemisphere
ice <- readice(latest = TRUE)

## Advanced Microwave Scanning Radiometer (6.25 km)
ice625 <- readice(product = "amsr")

## northern hemisphere, monthly
nice <- readice(hemisphere = "north", time.resolution = "monthly")

amsrfiles <- icefiles(product = "amsr")

range(amsrfiles$date)
range(diff(amsrfiles$date))

## latest OISST map, Southern Ocean
sst <- readsst(latest = TRUE, xylim = extent(-180, 180, -90, -30))

## matching 25km ice and SST
ice <- readice(getZ(sst))
icecontours <- rasterToContour(ice, level = c(15, 95))
icecontoursll <- spTransform(icecontours, projection(sst))
plot(sst)
plot(as(icecontoursll, "SpatialPoints"), add = TRUE, pch = 16, cex = 0.2)

## or take the SST to the ice
plot(ice)
plot(spTransform(rasterToContour(sst), projection(ice)), add = TRUE)

## calculate climatologies
icef <- icefiles()  ## all NSIDC 25km days of ice concentration
## subset files to only 2014
files10 <- subset(icef, format(date, "%m") == "10" & date > as.POSIXct("2005-02-15"))
ice10 <- readice(files10$date)
maxice <- calc(ice10, max)
sdice <- calc(ice10, sd)
plot(sdice, addfun = function() contour(maxice, lev = 15, add = TRUE))



