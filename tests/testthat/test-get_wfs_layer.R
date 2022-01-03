library(httr)
library(sf)

test_that("format_bbox return expected format", {
   # Test for errors
   expect_error(format_bbox())

   # Test for point
   point = st_point(1:3)
   expect_match(format_bbox(point),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)

   # Test for multipoint
   multipoint = st_multipoint(matrix(1:10,5))
   expect_match(format_bbox(multipoint),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)

   # Test for polygon
   outer = matrix(c(0,0,10,0,10,10,0,10,0,0),ncol=2, byrow=TRUE)
   hole1 = matrix(c(1,1,1,2,2,2,2,1,1,1),ncol=2, byrow=TRUE)
   hole2 = matrix(c(5,5,5,6,6,6,6,5,5,5),ncol=2, byrow=TRUE)
   pts = list(outer, hole1, hole2)
   polygon = st_polygon(pts)
   expect_match(format_bbox(polygon),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)
})
test_that("format_url return good url", {
   expect_error(format_url())

   apikey = "apikey"
   layer_name = "layer_name"
   startindex = 1

   shape = st_polygon(list(matrix(c(0,0,10,0,10,10,0,10,0,0),ncol=2, byrow=TRUE)))
   shape = st_sfc(shape)
   st_crs(shape) <- st_crs(4326)

   expect_false(is.na(st_crs(shape)))
   expect_equal(st_crs(shape), st_crs(4326))

   expect_type(format_url(apikey, layer_name, shape, startindex), "character")

})
test_that("get_wfs_layer error", {
   shape = st_polygon(list(matrix(c(0,0,10,0,10,10,0,10,0,0),ncol=2, byrow=TRUE)))
   shape = st_sfc(shape)
   st_crs(shape) <- st_crs(4326)
   expect_error(get_wfs_layer(shape))
})

