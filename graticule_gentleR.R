
plan <- FALSE  ## projected plane or sphere?
if (plan) {
    library(rgdal)
	roxyz <- ro; roxyz$vb[1:2,] <- t(project(t(ro$vb[1:2,]), proj))
ll <- mshlen(roxyz$vb, roxyz$ib) 
bad0 <- ll > quantile(ll, 0.99907)

	roxyz$vb[3,] <- roxyz$vb[3,]  * 50  ## arbitrary exaggeration
roxyz$ib <- roxyz$ib[,!bad0]
} else {
   roxyz <- ro; roxyz$vb[1:3, ] <- t(llh2xyz(t(roxyz$vb[1:3, ]), exag = 50))
}

shade3d(roxyz, col = rep(bmcols[!bad0], each = 4), lit = FALSE)
#for (i in seq(nrow(l))) {xy <- coordinates(as(l[i,], "SpatialPoints")); rgl.lines(cbind(xy, 1000), col = "white")}

sfiles <- c("ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20140601_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20140701_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20140801_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20140901_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20141001_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20141101_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/south/daily/2014/nt_20141201_f17_v01_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/south/nt_20150101_f17_nrt_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/south/nt_20150201_f17_nrt_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/south/nt_20150301_f17_nrt_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/south/nt_20150401_f17_nrt_s.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/south/nt_20150501_f17_nrt_s.bin" 
)

nfiles <- c("ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20140601_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20140701_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20140801_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20140901_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20141001_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20141101_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0051_gsfc_nasateam_seaice/final-gsfc/north/daily/2014/nt_20141201_f17_v01_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/north/nt_20150101_f17_nrt_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/north/nt_20150201_f17_nrt_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/north/nt_20150301_f17_nrt_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/north/nt_20150401_f17_nrt_n.bin", 
"ftp://sidads.colorado.edu/pub/DATASETS/nsidc0081_nrt_nasateam_seaice/north/nt_20150501_f17_nrt_n.bin"
)

for (i in seq_along(sfiles)) {
   if (!file.exists(basename(sfiles[i]))) download.file(sfiles[i], basename(sfiles[i]), mode = "wb")
    if (!file.exists(basename(nfiles[i]))) download.file(nfiles[i], basename(nfiles[i]), mode = "wb")
}

sf <- basename(sfiles)
nf <- basename(nfiles)

s_ <- stack(sf)
n_ <- stack(nf)
i <- 12
#for (i in 1:1000) {
 ii <-  ((i - 1) %% 12) + 1
vn <- values(n_[[ii]])
vs <- values(s_[[ii]])

nbad <- is.na(vn) | !(vn > 0)
nicecols <- grey(vn[!nbad]/100)
ngl <- bgl(raster(n_[[1]]))
if (!plan) {
 nqverts <- llh2xyz(cbind(project(t(ngl$vb[1:2, ]), projection(n_), inv = TRUE), 0))
} else {
 nqverts <- cbind(project(project(t(ngl$vb[1:2, ]), projection(n_), inv = TRUE), proj), 0)
}
ngl$vb[1:3, ] <- t(nqverts)
ngl$ib <- ngl$ib[,!nbad]

sbad <- is.na(vs) | !(vs > 0)
sicecols <- grey(vs[!sbad]/100)
sgl <- bgl(raster(s_[[1]]))
if (!plan) {
 sqverts <- llh2xyz(cbind(project(t(sgl$vb[1:2, ]), projection(s_), inv = TRUE), 10000))
} else {
sqverts <- cbind(project(project(t(sgl$vb[1:2, ]), projection(s_), inv = TRUE), proj), 0)
}
sgl$vb[1:3, ] <- t(sqverts)
sgl$ib <- sgl$ib[,!sbad]
#rgl.clear()
#shade3d(roxyz, col = rep(bmcols, each = 4), lit = FALSE)
shade3d(ngl, col = rep(nicecols, each = 4))
shade3d(sgl, col = rep(sicecols, each = 4))


  library(graticule)
l <- graticule(proj = if (plan) proj else NULL)
 for (i in seq(nrow(l))) {
xy <- coordinates(as(l[i,], "SpatialPoints")) 
  if (!plan) {
   xy <- llh2xyz(cbind(xy, 20000))
} 
rgl.lines(cbind(xy, 1000), col = "white")}
}

