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

test_that("width_height", {
   shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
                                     -4.375615, 47.79738,
                                     -4.375147, 47.79683,
                                     -4.373898, 47.79790,
                                     -4.373937, 47.79859),
                                   ncol = 2, byrow = TRUE)))
   shape <- st_sfc(shape, crs = st_crs(4326))

   expect_equal(suppressMessages(width_height(shape)), c(2048, 2048))
   expect_equal(suppressMessages(width_height(shape, resolution = 5)),
                c(40, 26))
   expect_type(suppressMessages(width_height(shape)), "double")
})
