## Ice extent
library(raadtools)
dates <- c("2014-07-01", "2014-10-15", "2015-02-14")
ice <- readice(dates)
cont <- vector("list", nlayers(ice))
for (i in seq_along(cont)) {
  cont[[i]] <- rasterToContour(ice[[i]], level = 15)
}

plot(ice[[nlayers(ice)]])
lapply(cont, lines)