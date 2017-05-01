## Example
##  wind magnitude in the Australian Southern Ocean
library(raadtools)
library(maps)
files <- readwind(returnfiles = TRUE)
dates <- tail(files$date, 100)
xlim <- c(120, 210); ylim <- c( -50, -20)
ext <- extent(xlim, ylim)
dmap <- map(plot = FALSE, xlim = xlim, ylim = ylim)
raw <- vector("list", length(dates))
for (date in files$date) {
  
}