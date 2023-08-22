# rast <- get_wmts(poly, "ortho", "ORTHOIMAGERY.ORTHOPHOTOS")
# has.RGB(rast) == T
# st_crs(rast) == st_crs(2154)
#
# rast <- get_wmts(poly, "ortho", "ORTHOIMAGERY.ORTHOPHOTOS", crs = 4326)
# st_crs(rast) == st_crs(4326)
#
# rast <- get_wmts(poly, "altimetrie", "ELEVATION.ELEVATIONGRIDCOVERAGE.SHADOW", crs = 4326)
#
# #test bad apikey
