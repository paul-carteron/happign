test_that("error when bad format", {
   shape <- st_sfc(st_point(1:3), crs = st_crs(4326))
   expect_error(get_wms_raster(shape,
                               format = "bad_format",
                               filename = "bad_filename"))
})
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
test_that("grid", {
   shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
                                         -4.375615, 47.79738,
                                         -4.375147, 47.79683,
                                         -4.373898, 47.79790,
                                         -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
   shape <- st_sfc(shape, crs = st_crs(4326))

   verif_matrix_res_10 <- matrix(c(47.796830, -4.375615,
                                   47.796830, -4.373898,
                                   47.798590, -4.373898,
                                   47.798590, -4.375615,
                                   47.796830, -4.375615), ncol = 2, byrow = TRUE)

   expect_equal(suppressMessages(grid(shape, resolution = 10, crs = st_crs(4326))[[1]][[1]]),
                verif_matrix_res_10)
   expect_equal(length(grid(shape, resolution = 0.05, crs = st_crs(4326))),
                4)
   expect_type(suppressMessages(grid(shape, resolution = 10, crs = st_crs(4326))), "list")
})
test_that("nb_pixel_bbox", {
   shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
                                         -4.375615, 47.79738,
                                         -4.375147, 47.79683,
                                         -4.373898, 47.79790,
                                         -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
   shape <- st_sfc(shape, crs = st_crs(4326))

   expect_equal(nb_pixel_bbox(shape, resolution = 10, crs = 4326), c(13,20))
   expect_equal(nb_pixel_bbox(shape, resolution = 0.1, crs = 4326), c(1283, 1958))
   expect_type(nb_pixel_bbox(shape, resolution = 10, crs = 4326), "double")
   expect_equal(length(nb_pixel_bbox(shape, resolution = 10, crs = 4326)), 2)
})
test_that("construct_filename", {

   format <- "image/geotiff"
   layer_name <- "test.with.point.inside.name"
   resolution <- 25

   expect_equal(construct_filename(format, layer_name, "test", resolution),
                "./test_25m.tif")

   expect_equal(construct_filename(format, layer_name, "output/test", resolution),
                "output/test_25m.tif")

   expect_equal(construct_filename(format, layer_name, NULL, resolution),
                "test_with_point_inside_name_25m.tif")

})
test_that("construct_urls", {
   urls <- construct_urls("apikey", "version", "format", "layer_name", "styles", c(6, 8), c("bbox1", "bbox2"), crs = 4326)
   expect_length(urls, 2)
   expect_equal(urls[1],
                "https://wxs.ign.fr/apikey/geoportail/r/wms?version=version&request=GetMap&format=format&layers=layer_name&styles=styles&width=6&height=8&crs=EPSG:4326&bbox=bbox1")
})
test_that("combine_tiles", {

   rast_1 <- terra::rast(ncol=10, nrow=10, xmin=0, xmax=10, ymin=0, ymax=10)
   terra::values(rast_1) <- runif(terra::ncell(rast_1))
   rast_2 <- terra::rast(ncol=10, nrow=10, xmin=0, xmax=10, ymin=10, ymax=20)
   terra::values(rast_2) <- runif(terra::ncell(rast_2))

   terra::writeRaster(rast_1, tempfile(pattern = "tile1", fileext = ".tif"), overwrite=TRUE)
   terra::writeRaster(rast_2, tempfile(pattern = "tile2", fileext = ".tif"), overwrite=TRUE)

   tiles_list <- list.files(tempdir(), pattern = "tile1|tile2", full.names = T)

   filename <- tempfile(pattern = "combined", fileext = ".tif")

   rast <- combine_tiles(tiles_list, filename)

   expect_s4_class(rast, "SpatRaster")
   expect_equal(dim(rast), c(20, 10, 1))
})
test_that("download_tiles", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(pattern = "download", fileext = "tif")

   urls <- "https://wxs.ign.fr/altimetrie/geoportail/r/wms?version=1.3.0&request=GetMap&format=image/geotiff&layers=ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES&styles=&width=6&height=8&crs=EPSG:4326&bbox=47.79683,-4.375615,47.79859,-4.373898"

   tiles <- download_tiles(filename, urls, crs = 4326)
   expect_type(tiles, "list")
   expect_length(tiles, 1)

})
# test_that("the whole function", {
#    skip_on_cran()
#    skip_if_offline()
#
#    filename <- tempfile(pattern = "whole_function", fileext = ".tif")
#    shape <- st_polygon(list(matrix(c(-4.373937, 47.79859, -4.375615, 47.79738,
#                                      -4.375147, 47.79683, -4.373898, 47.79790,
#                                      -4.373937, 47.79859), ncol = 2, byrow = TRUE)))
#    shape <- st_sfc(shape, crs = st_crs(4326))
#    mnt <- get_wms_raster(shape = shape, resolution = 25, filename = filename)
#
#    expect_s4_class(mnt, "SpatRaster")
#    expect_equal(dim(mnt), c(8, 6, 1))
#
#    expect_message(get_wms_raster(shape = shape, resolution = 25, filename = filename),
#                   "already exist at")
#
# })

