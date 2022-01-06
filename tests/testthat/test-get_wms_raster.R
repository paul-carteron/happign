library(sf)
library(terra)

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

test_that("get_wms_layer", {
   # example shape for testing
   shape <- st_polygon(list(matrix(c(-4.373, -4.373,
                                     -4.372, -4.372,
                                     -4.373, 47.798,
                                     47.799, 47.799,
                                     47.798, 47.798),
                                   ncol = 2)))
   shape <- st_sfc(shape, crs = st_crs(4326))

   layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE"
   apikey <- "altimetrie"

   layer <- get_wms_raster(shape = shape,
                          apikey = apikey,
                          layer_name = layer_name,
                          width_height = 500)

   expect_equal(dim(layer)[1:2], c(500, 500))
   expect_s4_class(layer, "SpatRaster")
})
