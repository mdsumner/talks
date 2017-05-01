## Example
##  current magnitude in the Australian Southern Ocean
library(raadtools)
library(maps)
files <- readwind(returnfiles = TRUE)
dates <- tail(files$date, 100)
xlim <- c(120, 210); ylim <- c( -50, -20)
ext <- extent(xlim, ylim)
dmap <- map(plot = FALSE, xlim = xlim, ylim = ylim)
raw <- vector("list", length(dates))
for (i in seq_along(dates)) {
  raw[[i]] <- readcurr(dates[i], magonly = TRUE, xylim = ext)
}

curr <- stack(raw)
library(animation)
saveHTML(animate(curr, pause = 0, col = sst.pal(50)))

         
