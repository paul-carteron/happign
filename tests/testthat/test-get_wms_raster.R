library(sf)
library(stars)

test_that("format_bbox_wms", {
   expect_error(format_bbox_wms())

   # Test for point
   point <- st_point(1:3)
   expect_match(format_bbox_wms(point),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)

   # Test for multipoint
   multipoint <- st_multipoint(matrix(1:10, 5))
   expect_match(format_bbox_wms(multipoint),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)

   # Test for polygon
   outer <- matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,  byrow = TRUE)
   hole1 <- matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,  byrow = TRUE)
   hole2 <- matrix(c(5, 5, 5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,  byrow = TRUE)
   pts <- list(outer, hole1, hole2)
   polygon <- st_polygon(pts)
   expect_match(format_bbox_wms(polygon),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)
})
test_that("normalize_path argument have to be FALSE for now", {
   # If this test doesn't it means that stars updates my issues on cran #497 !
   #± So now, I can remove normalize_path = FALSE from get_wms_raster, line 88
   url <- paste0("/vsicurl_streaming/https://wxs.ign.fr/altimetrie/",
                 "geoportail/r/wms?VERSION=1.3.0&",
                 "REQUEST=GetMap&FORMAT=image%2Fgeotiff&",
                 "LAYERS=ELEVATION.ELEVATIONGRIDCOVERAGE&",
                 "STYLES=&WIDTH=500&HEIGHT=500&CRS=EPSG%3A4326&",
                 "BBOX=47.789171%2C-4.379489%2C47.841275%2C-4.15839")
   expect_error(read_stars(url, normalize_path = TRUE),
                "file not found",
                fixed = TRUE)
})
