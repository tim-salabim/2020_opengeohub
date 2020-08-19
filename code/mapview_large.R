library("sf")
library("leaflet")
library("leafgl")
library("colourvalues")
library("mapview")
library("stars")

mapviewOptions(platform = "leafgl")

# points
n = 5e5

df1 = data.frame(id = 1:n,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
mapview(pts)

# polygons
grd = st_make_grid(pts, n = 700)
grd
mapview(grd)

# lines
lns = st_cast(grd, "LINESTRING")
mapview(lns)

# multiple layers
mapviewOptions(viewer.suppress = TRUE)
mapview(grd) + pts

# some more calculations - count number of points in each square
cnt = st_as_sf(
  data.frame(
    count = lengths(st_intersects(grd, pts))
    , geometry = grd
  )
)

mapview(cnt, lwd = 0)


# raster
chrpsfl = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/tifs/p05/2020/chirps-v2.0.2020.06.30.tif.gz"
dsn = file.path(tempdir(), basename(chrpsfl))
download.file(chrpsfl, dsn)
tiffl = gsub(".gz", "", dsn)
R.utils::gunzip(dsn, tiffl)

chrps = read_stars(tiffl, proxy = FALSE)
chrps[[1]][chrps[[1]] <= 0] = NA

mapview(chrps)


chrpsfl2 = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/tifs/p05/2020/chirps-v2.0.2020.06.29.tif.gz"
dsn2 = file.path(tempdir(), basename(chrpsfl2))
download.file(chrpsfl2, dsn2)
tiffl2 = gsub(".gz", "", dsn2)
R.utils::gunzip(dsn2, tiffl2)

chrps2 = read_stars(tiffl2, proxy = FALSE)
chrps2[[1]][chrps2[[1]] <= 0] = NA

mapview(chrps2) | mapview(chrps)


# chrpsfl_05 = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_monthly/tifs/chirps-v2.0.2020.05.tif.gz"
# chrpsfl_04 = "https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_monthly/tifs/chirps-v2.0.2020.04.tif.gz"
# dsn_05 = file.path(tempdir(), basename(chrpsfl_05))
# dsn_04 = file.path(tempdir(), basename(chrpsfl_04))
#
# download.file(chrpsfl_05, dsn_05)
# download.file(chrpsfl_04, dsn_04)
#
# tiffl_05 = gsub(".gz", "", dsn_05)
# R.utils::gunzip(dsn_05, tiffl_05)
#
# tiffl_04 = gsub(".gz", "", dsn_04)
# R.utils::gunzip(dsn_04, tiffl_04)
#
# chrps_05 = read_stars(tiffl_05, proxy = FALSE)
# chrps_04 = read_stars(tiffl_04, proxy = FALSE)
#
# chrps_04[[1]][chrps_04[[1]] < 0] = NA
# chrps_05[[1]][chrps_05[[1]] < 0] = NA
#
# mapview(chrps_04)
#
# mapview(chrps_04) | mapview(chrps_05)
