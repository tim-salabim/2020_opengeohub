library("mapview")
# GDAL version >= 3.1.0 | setting mapviewOptions(fgb = TRUE)

library("leafem")
library("leafgl")
library("leaflet")
library("sf")
# Linking to GEOS 3.8.0, GDAL 3.1.0, PROJ 7.0.0
library("stars")
library("raster")

library("RColorBrewer")

#' # 1. leaflet
#'
#' ### A very basic call
#+ eval=TRUE
leaflet() %>%
  addTiles()

#' ### Setting the view

leaflet() %>%
  addTiles() %>%
  setView(lng = 5.66, lat = 51.97, zoom = 13)

#' ### Using other basemaps & layers control
#+ eval=TRUE
basemaps = c("CartoDB.DarkMatter", "CartoDB.Positron")
#'
leaflet() %>%
  addProviderTiles(
    basemaps[1]
    , group = basemaps[1]
  ) %>%
  addProviderTiles(
    basemaps[2]
    , group = basemaps[2]
  ) %>%
  setView(
    lng = 5.66
    , lat = 51.97
    , zoom = 13
  ) %>%
  addLayersControl(
    baseGroups = basemaps
  )

#' ### Adding data

leaflet() %>%
  addProviderTiles(
    basemaps[1]
    , group = basemaps[1]
  ) %>%
  addProviderTiles(
    basemaps[2]
    , group = basemaps[2]
  ) %>%
  addPolygons(
    data = mapview::franconia
    , group = "franconia"
  ) %>%
  addPolylines(
    data = atlStorms2005
    , group = "storms"
  ) %>%
  addLayersControl(
    baseGroups = basemaps
    , overlayGroups = c("franconia", "storms")
    , position = "topleft"
  )

#' ### Adding popups & lables
#+ eval=TRUE
leaflet() %>%
  addProviderTiles(
    basemaps[1]
    , group = basemaps[1]
  ) %>%
  addProviderTiles(
    basemaps[2]
    , group = basemaps[2]
  ) %>%
  addPolygons(
    data = mapview::franconia
    , group = "franconia"
    , popup = ~district
    , label = ~NUTS_ID
  ) %>%
  addPolylines(
    data = atlStorms2005
    , label = ~Name
    , color = "#ff0000" #"red"
    , opacity = 1
    , weight = 2
  ) %>%
  addLayersControl(
    baseGroups = basemaps
    , overlayGroups = "franconia"
    , position = "bottomleft"
  )

#'
#' -----
#'
#' # 2. mapview
#'
#' `mapview` is based on leaflet and wraps much of its functionality into a
#' data-driven API that is designed to be quick and comprehensive, yet customisable.
#'
#' ### Basic usage
#+ eval=TRUE
mapview()

#' ### with some vector data
#+ eval=TRUE
mapview(franconia)
m = mapview(breweries)
m

#' ### raster data
tif = system.file("tif/L7_ETMs.tif", package = "stars")
(x1 = read_stars(tif))

mapview(x1)

f <- system.file("external/test.grd", package="raster")
(rst = raster(f))
mapview(rst)

#' ### mapview structure
#+ eval=TRUE
str(m, 3)
m@object[[1]]
class(m@object[[1]])
class(m@map)
class(m)

#' ### mapview methods
#+ eval=TRUE
showMethods("mapView")
#'

#' ### no or specific CRS? no problem
#+ eval=TRUE
brew = st_set_crs(breweries, NA)
mapview(brew)

brew = st_transform(breweries, 3035)
mapview(brew)
mapview(brew, native.crs = TRUE)

mapview(rst, native.crs = TRUE)
mapview(x1, native.crs = TRUE) # error!

#' ### styling options & legends
#+ eval=TRUE
mapview(franconia, color = "grey90", col.regions = "white")

#'
mapview(breweries, zcol = "founded", layer.name = "Year of <br> foundation")
mapview(breweries, zcol = "founded", at = seq(1300, 2200, 200))
mapview(franconia, zcol = "district", legend = FALSE, label = FALSE)

#' #### If you can, it is recommended to use color genereating functions with mapview.
clrs = colorRampPalette(brewer.pal(3, "Set1"))
mapview(franconia, zcol = "district", col.regions = clrs, alpha.regions = 1)

cols = c("orange", "purple", "forestgreen")
mapview(franconia, zcol = "district", col.regions = cols, alpha.regions = 1)

#' ### mapview operators
#'
#' #### adding layers using '+'
#+ eval=TRUE
mapview(breweries) + mapview(franconia)
mapview(breweries) + franconia

#' currently some features with lists will only work if mapviewOptions(fgb = FALSE).
mapview(breweries, col.regions = "red") +
  mapview(franconia, col.regions = "grey") +
  trails

mapview(list(breweries, franconia, trails))

mapview(list(breweries, franconia),
        zcol = list("founded", "district"),
        legend = list(FALSE, TRUE),
        homebutton = list(TRUE, FALSE)) +
  trails

m1 = mapview(franconia, col.regions = "blue")
m2 = mapview(breweries, zcol = "founded", at = seq(1200, 2100, 300))

m1 + m2

mapview(x1, band = 1) + mapview(x1, band = 4)
#'
#' #### comparing layers using '|'
#+ eval=TRUE
m1 | m2

mapview(franconia) | mapview(trails)
mapview(franconia) + breweries | mapview(trails)

mapview(x1, band = 1) | mapview(x1, band = 4)

#' #### bursting layers
#'
mapview(franconia, burst = TRUE)
mapview(franconia, zcol = "district", burst = TRUE)
mapview(franconia, burst = "district")

#' ### view extents
#+ eval=TRUE
viewExtent(breweries)
mapview(st_bbox(breweries))
viewExtent(as(x1, "Raster")) + x1 # currently no viewExtent method for stars

#' ### basemaps
mapview(
  gadmCHE
  , map.types = c("Stamen.Toner", "NASAGIBS.ViirsEarthAtNight2012")
)

# see
# https://leaflet-extras.github.io/leaflet-providers/preview/
# for more options

#' ### changing options globally
#+ eval=TRUE
mapviewOptions()

mapviewOptions(
  basemaps = c("CartoDB.DarkMatter", "Esri.OceanBasemap")
  , raster.palette = colorRampPalette(rev(brewer.pal(9, "Greys")))
  , vector.palette = colorRampPalette(brewer.pal(9, "YlGnBu"))
  , na.color = "magenta"
  , layers.control.pos = "topright"
  , viewer.suppress = TRUE
)
#'
mapview(breweries, zcol = "founded")
mapview(x1)

mapviewOptions(default = TRUE)
mapview(x1)

mapviewGetOption("fgb")
mapviewOptions(fgb = TRUE)

#' ### watch global environment automagically and mapview all spatial data
#'
mapview::startWatching()

ls()
brew = brew[1, ]
rm(brew)

mapview(breweries)
brew = breweries

mapview::stopWatching()

rm(brew)

#' ### additional useful functions
#'
#' #### mapshot
#'
mapviewOptions(fgb = FALSE)
mymap = mapview(franconia, zcol = "district") + breweries
mapshot(mymap, url = "/home/timpanse/Desktop/mymap.html")
mapshot(mymap, file = "/home/timpanse/Desktop/mymap.png")
mapshot(mymap, file = "/home/timpanse/Desktop/mymap.png",
        remove_controls = c("zoomControl", "layersControl", "homeButton"))

#' #### viewRGB
#'
library(plainview)
viewRGB(poppendorf, r = 4, g = 3, b = 2)
viewRGB(x1) # error! will need to convert to stars internally...

#' #### files directly
#'
fl = "/home/timpanse/software/data/franconia.geojson"
mapview(fl)

#' #### tile folder
#'
tls = "/home/timpanse/software/tiles/bicycle-tiles/"
mapview(tls)
