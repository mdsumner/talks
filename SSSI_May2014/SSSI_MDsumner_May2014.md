R tools, gridded data 
========================================================
author: Michael Sumner
date: 16 May 2014
css: myslides.css
Southern Ocean Ecosystem Change Program, AAD
michael.sumner@aad.gov.au

![alt text][affil]
[affil]: affil.png "affil"

 
Summary
========================================================
- Tools in R for spatio-temporal data
- Extending R tools for AAD data
- Extensible extraction functions
- Map projections, frequently hidden
- Prospects - open development, web delivery with Shiny

The data repository
========================================================
<small>
- sea ice concentration
- chlorophyll-a
- sst
- wind vectors
- current vectors
- ssh/ssha
- model outputs [lon, lat, [depth], time]
- bathymetry

Habitat assessment, Southern Ocean ecosystem models, data exploration, map production, etc. 

Extracting data for polygonal regions, boundaries, transects, point samples etc

Tool development captured in R packages
</small>


R Tools
========================================================
R and extension packages provide a wide variety of spatial tools
- Raster and vector, read/write: gdal, ncdf, 'native'
- Formal classes, metadata-rich objects
- Map projections and transformations
- Geometry manipulation, union, intersection, buffers

See the Spatial 'Task View' http://cran.csiro.au/web/views/Spatial.html

Raster tools for 2D and 3D grids
==========================================================
<small>
- cellFromXY(x, pts)
- xyFromCell(x, cellnum)
- getValues(x, format = "matrix")
- adjacent(x, 10)
- writeRaster(x, filename, ...)

High level
- extent(x); dim(x); projection(x)
- merge, crop, projectRaster, aggregate, reclass, rasterize, distance, focal, terrain ...
- Raster algebra: x + y; sqrt(y); log(x) etc. 
- Temporal or 'Z' axis for 3D

Regridding and extraction
- nearest-neighbour / bilinear-interpolation resampling
- aggregation/disaggregation to coarser/lower resolution
- warping (resampling grid points via projection transformation)

</small>



Example: Etopo2 and aggregated depth values
========================================================
<small>
- Read grid data and crop
- Extract aggregate grid values under polygon objects
- Reproject grid to polygons (for plotting)


```r
library(raster)
bb <- extent(25, 90, -70, -40)
topo <- crop(raster("Etopo2.tif"), bb)
topo[topo > -1] <- NA
```

```r
polys <- readOGR(".", "SSRUs")
polys$meantopo <- extract(topo, polys, fun = mean, na.rm = TRUE)
```


```r
## reproject the raster and plot both layers
projtopo <- projectRaster(topo, crs = projection(polys))
plot(projtopo)
incl <- !is.na(polys$meantopo)
plot(polys[incl,], add = TRUE, col = "#333333333B3")
text(coordinates(polys)[incl,], lab = format(polys$meantopo[incl], digits = 5), cex = 0.7)
```
</small>
<small>
Example: Etopo2 and aggregated depth values
========================================================
</small>
![alt text][etopo2plot]

[etopo2plot]: etopo2plot.png "Etopo2 and CCAMLR SSRUs"

R tools - time series grid
========================================================
High-level work flow also applies to time series grid data
<small>

```r
library(raster)
bb <- extent(100, 160, -70, -50)

## leave bulk data on disk, read on demand
sst <- crop(brick("sst.wkmean.1990-present.nc"), bb, filename = "ReynoldsSST_subset.nc")
polys <- readOGR(".", "PolygonShapefile")
## matrix of [polyID,weeks]
(sstmatrix <- extract(sst, polys, fun = mean))
```
</small>
<img src="reynoldssummary.png" height="137px" width="893px" />

R Tools - time-series data
========================================================
<small>
Raster can read from a variety of file types, and deal with 3D space-time grids, or assemble them from individual files

```r
library(raster)
dp <- "//aad.gov.au/files/AADC/Scientific_Data/Data/gridded/data"
sp <- "seaice/ssmi/ifremer/antarctic/daily/2013"
files <- c("20130719.nc", "20130726.nc", "20130802.nc", "20130809.nc", "20130816.nc", "20130823.nc", "20130830.nc", "20130906.nc")
fs <- file.path(dp, sp, files)
icedata <- stack(fs)
```
R AAD tools adds simplified helpers for rogue file collections:  

```r
library(raadtools)
dates <- seq(as.Date("2013-07-19"), by = "1 week", length = 8)
icedata <- readice(dates, product = "ssmi")
```
</small>
<img src="icedata.png" height="188px" width="1089px" />

R AAD Tools - extensions to existing tools
========================================================

```r
(icedata <- readice(dates, product = "smmi"))
```

The raadtools package provides
- integration with standard R tools
- catalogue of available files in the repository
- normalization of input dates; uniques; sort; match to repository dates
- read[x] function for product [x] with consistent structure
- record/fix incomplete/missing metadata, orientation, etc.
- flexible extraction methods, read slabs or extract point values

R Tools - data extraction from "slabs"
========================================================
Reading slabs (stack, brick, array) is not necessarily what we want. 

Obviously it's smarter to only read today's slab: 
<small>

```r
myPoints$ice <- as.numeric(NA)
for (i in seq_along(levs)) {  
  ## match this day's myPoints data to the ice
  isub <- myPoints[levs == levs[i], c("long", "lat")]  
  
  ice <- readice(isub$datetime[1L])  
  vals <- extract(ice, isub, method = "bilinear")
  myPoints$ice[levs == levs[i]] <- vals
}
```

This is getting there but
- cannot extract with longitude / latitude because the grid is in Polar Stereographic
- need extra handling to interpolate in time
- perhaps aggregate the grid to a lower resolution
- code required starts to get complicated
- and we need to write this for each data type . . .

</small>


R  Tools - extract methods
========================================================
<small>
The raster construct for extracting data from grids: 

```r
library(raster)
r <- raster("myMegaSplat.grd")
extract(r, [query])
```

Where, [query] is:
- a data.frame/matrix of coordinates (must match projection of raster)
- SpatialPoints\*, SpatialLines\*, SpatialPolygons\* (reprojection will be performed if required)



```r
extract(x, query, fun = mean)
extract(x, query, fun = function(x) dowhatever(x))
```
- if raster is 2D, we get value/s for each point/line/polygon
- if raster is 3D, we get a *matrix* of values for each point/line/polygon at each time step 

</small>


R AAD Tools - extract methods
=========================================================
<small>
The raadtools package applies extract() to functions, with query a table of longitude, latitude, date-time: 


```r
xyt <- c("long", "lat", "datetime")
## extract                                                                                              
myPoints$iceconcentration <- extract(readice, myPoints[,xyt])
```
We can do the same with other read functions, and provide options: 


```r
myPoints$uCurr <- extract(readcurr, myPoints[,xyt], uonly = TRUE)

myPoints$vCurr <- extract(readcurr, myPoints[,xyt], vonly = TRUE)

myPoints$interpsst <- extract(readsst, myPoints[,xyt], ctstime = TRUE, method = "bilinear")
```


R AAD Tools - extract methods
=========================================================

```r
myPoints$interpsst <- extract(readsst, myPoints[,xyt], ctstime = TRUE, method
                              
myPoints$regridSSHA <- extract(readssh, myPoints[,xyt], fact = 8, ssha = TRUE)
```
This is *extensible*: by adding new functions we can use those, without rebuilding/reinstalling the package providing the extract method. It doesn't matter what projection the source grid uses. 

Similar extraction methods are possible for other scenarios, such as polygonal regions, track lines, transects, depth-varying data, etc. 

</small>


R AAD Tools - read / extract 
========================================================

<small>
If *readwhatever()* knows the grid, projection, time axis, catalogue, *extract* just applies the same engine to that. 

- **readchla**: weekly/monthly, SeaWIFS/MODIS, oceancolor/Robert Johnson
- **readcurrents**: weekly AVISO surface currents
- **readice**: daily/monthly, NSIDC/SSMI, southern hemisphere
- **readssh**: weekly Sea Surface height/anomaly, global
- **readsst**: daily/monthly SST, global
- **readwind**: weekly surface wind vectors, global


- *readtopo*: Gebco 2008, IBCSO, Etopo1/2, Kerguelen, George V Terre Adelie, Smith and Sandwell
- *readfastice*: East Antarctic Fast Ice Coverage, 2000-2008
- *readfronts*: weekly Sokolov/Rintoul frontal regions
- *readmld*: montly climatology Sallee mixed layer depth, Southern Ocean
- *readrapid_response*: daily RGB MODIS image, southern hemisphere

</small>

Data and map projections
=========================================================
![alt text][mercator1]

[mercator1]: mercator1.png "AVISO surface currents"

This is what some GIS packages see from AVISO ocean currents stored in NetCDF.

Reorient the grid, looks right, but map doesn't line up . . .

Mercator-grid, longlat vs native
=========================================================
![alt text][mercator2]

[mercator2]: mercator2.png "AVISO surface currents - in a World Mercator"

<small>
PROJ.4
+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +over +units=m +no_defs

- Left panel is  *rectilinear*, latitude lines are denser towards the poles. 
- Right panel is *regular in native projection*, and this allows straightforward usage (and fast extraction methods). 

</small>


Other map projections in common use
=========================================================
<small>
<b>Spherical Mercator</b> Smith/Sandwell topography-bathymetry
<small>+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs</small>

<b>WGS84 Mercator</b> AVISO currents, SSH/SSHA, Sokolov/Rintoul front zones
<small> +proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs</small>

<b> Equal Area Cylindrical</b> Fraser / Massom fast ice
<small>+proj=cea +lon_0=91 +lat_0=-90 +lat_ts=-65 +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0</small>
<br><small>+proj=cea +ellps=WGS84</small>

<b>Lambert Azimuthal Equal Area </b> CCAMLR management zone shapefiles
<small>+proj=laea +lat_0=-90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m
+no_defs +ellps=WGS84 +towgs84=0,0,0</small>

</small>

More projections in common use
=========================================================
<small>
<b> (North Polar) Stereographic </b> NSIDC, SSMI products,  North-Hemi Snow Cover Extent
<small> +proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs</small>
<br><small>+proj=stere +lat_0=90 +lon_0=10 +ellps=WGS84</small>

<b> (South Polar) Stereographic on the sphere</b> Arrigo/Dijken primary production 

<small>+proj=stere +lat_0=-90 +lon_0=180 +ellps=sphere</small>
 
<b> Longitude / latitude on WGS84</b> (no kidding!)

<small>
+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0
</small>

<b> Sinusoidal on WGS84 (or sphere?)</b> SeaWiFS/MODIS Level 3 binned ocean colour

<small>
+proj=sinu +ellps=WGS84] = +proj=sinu +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs
</small>
</small>


R tools code
==========================================================

<small>

```r
library(raadtools)
library(rgdal)
library(maptools)
data(wrld_simpl)
## prepare base data, transform copies to LAEA for comparison
xst <- readice()
library(rgdal);library(maptools);data(wrld_simpl)
wst <- spTransform(wrld_simpl, CRS(projection(xst)))
xla <- projectRaster(xst, crs = gsub("stere", "laea", projection(xst)))
wla <- spTransform(wrld_simpl, CRS(projection(xla)))
## extents for both
est <- extent(xst) + 1.2e7
lst <- extent(xla) + 1.2e7

## plot
par(mfcol = c(1, 2), cex = 1.5)
plot(est, col = "white", axes = FALSE, xlab = "", ylab = "", asp = 1, main = "Stereographic")
plot(xst, add = TRUE, legend = FALSE)
plot(wst, add = TRUE)
plot(lst, col = "white", axes = FALSE, xlab = "", ylab = "", asp = 1, main = "Lambert Eq Area");
plot(xla, add = TRUE, legend = FALSE)
plot(wla, add = TRUE)
```

</small>

20 lines of R tools code
========================================================

<img src="Conformal.png" height="1000px" width="1000px" />

Other code
========================================================
Work with the coordinate system as delivered, transform to/from the native projection

<small>
Not this! 



```r
##' load data arrays from binary files
nn = 209091
fid = open('data.bin','rb')
x=readBin(fid,"integer",n=nn,size=1)
close(fid)
##' load lons/lats
fid = open('lats','rb')
lat=readBin(fid,"integer",n=nn,size=4)/1e5
close(fid)
fid = open('lons','rb')
lon=readBin(fid,"integer",n=nn,size=4)/1e5
close(fid)

##' area-cell or point-cell?
##' ?? ...
```


(This approach looks the same in any language). 
</small>

Open development
========================================================
- RStudio server
- users log-in via web browser
- interface identical to RStudio, shared R installation, shared network, etc. 
- streamlining tools to update/synchronize the file collections


Open development
========================================================
![alt text][rstudio1]


[rstudio1]: rstudio1.png "RStudio"


Deploying to the web with Shiny
========================================================
<small>
Shiny lets us write very simple R code, with a little bit of wrapping and spin it up in a browser: 

```r
list.files("shinyrun")
##[1] "server.R" "ui.R" 
## server.R                                                           
library(shiny)
library(raadtools)
strf <- "NSIDC_%d_%b_%Y"
shinyServer(function(input, output) {
  output$rasterPlot <- renderPlot({
   dates <- input$dateRange
   x <- readice(dates)
   names(x) <- format(getZ(x), strf)
   plot(x)
  })})
## ui.R
library(shiny)
fs <- icefiles()
mindate <- as.Date(min(fs$date))
maxdate <- as.Date(max(fs$date))
shinyUI(pageWithSidebar(
  headerPanel("NSIDC daily sea ice"),
  sidebarPanel(dateRangeInput("dateRange", "Dates:",
      start = mindate, end = maxdate, 
      min = mindate, max = maxdate, separator = "and")
  ),
    mainPanel(plotOutput("rasterPlot"))))
```
</small>

Deploy on a server 
==========================================================================
(such as "localhost")

<small>

```r
## load the shiny package and point to a simple app
library(shiny)

dp <- "//aad.gov.au/files/Transfer"

runApp(file.path(dp, "shinyrun"))
```
</small>



Extract data for points with Shiny app
========================================================

```r
library(shiny)
runApp("shinyExtract")
```
![alt text][shinyApp0]


[shinyApp0]: shinyApp0.png "shinyApp0"

Extract data for points with Shiny app
========================================================

![alt text][shinyApp1]


[shinyApp1]: shinyApp1.png "shinyApp1"

Extract data for points with Shiny app
========================================================

![alt text][shinyApp2]


[shinyApp2]: shinyApp2.png "shinyApp2"

What next?
========================================================
<small>

Continue habitat assessment analyses for the Southern Ocean

Consolidate our public data repository on web services via TPAC, IMAS, NecTAR

Expand toolbox repertoire, contribute code back to community resources

Interested users, testers, developers, collaborators?  

michael.sumner@aad.gov.au

</small>

![alt text][affil]
[affil]: affil.png "affil"


Structure of read functions (1)
========================================================
<small><small>

```r
##' Read Polar model data.
##'
##' Polar biology model, on Stereographic grid.
##' @title Polar data
##' @param date date or dates of data to read
##' @param returnfiles if TRUE return just the files from \code{polarfiles}
##' @param time.resolution choice of temporal resolution, weekly only
##' @param xylim crop or not
##' @param ... ignored
##' @return RasterLayer or RasterBrick
##' @export
readpolar <- function(date,  time.resolution = "weekly", xylim = NULL, returnfiles = FALSE, ...) {
      ## private function to read a single file/time slice specific to this product
      read0 <- function(x) {
        proj <- "+proj=stere +lat_0=-90 +lon_0=180 +ellps=sphere"
        offset <- c(5946335, 5946335)
        dims <- c(1280L, 1280L)
        pdata <- readBin(x, numeric(), prod(dims), size = 4, endian = "little")
        pdata[pdata < 0] <- NA
        x <- list(x = seq(-offset[1L], offset[1L], length = dims[1L]),
                   y =  seq(-offset[2L], offset[2L], length = dims[2L]),
                   z = matrix(pdata, dims[1L])[rev(seq_len(dims[2L])),])
        raster(x, crs = proj)

    }
    ## process input options
    time.resolution <- match.arg(time.resolution)
    files <- polarfiles()
    if (returnfiles) return(files)

    ## provide a default for readpolar() with no input
    if (missing(date)) date <- min(files$date)
    date <- timedateFrom(date)
    
    
   ## continued . . . 
   
    
    
    }
```
</small></small>

Structure of read functions (2)
========================================================
<small><small>

```r
  ## readpolar <- function(date,  time.resolution = "weekly", xylim = NULL, returnfiles = FALSE, ...) {

  ## cont.

    ## normalize input to file dates
    files <- .processFiles(date, files, time.resolution)

    ## crop if requested
    cropit <- FALSE
    if (!is.null(xylim)) {
        cropit <- TRUE
        cropext <- extent(xylim)
    }

    ## collect individual slices and bundle as a RasterBrick
    nfiles <- nrow(files)
    r <- vector("list", nfiles)
    for (ifile in seq_len(nfiles)) {
        r0 <- read0(files$fullname[ifile])
        if (cropit) 
            r0 <- crop(r0, cropext)
        r[[ifile]] <- r0
    }
    r <- brick(stack(r))

    ## tidy up the names and the 3rd axis metadata
    names(r) <- sprintf("polar_%s", format(files$date, "%Y%m%d"))
    setZ(r, files$date)
}
```
</small></small>

