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

   verif_matrix_res_10 <- matrix(c(-4.375615, 47.79683,
                                   -4.373898, 47.79683,
                                   -4.373898, 47.79859,
                                   -4.375615, 47.79859,
                                   -4.375615, 47.79683), ncol = 2, byrow = TRUE)

   verif_matrix_res_20 <- matrix(c(-4.375615, 47.79683,
                                   -4.373898, 47.79683,
                                   -4.373898, 47.79859,
                                   -4.375615, 47.79859,
                                   -4.375615, 47.79683), ncol = 2, byrow = TRUE)

   expect_equal(suppressMessages(grid(shape, resolution = 10)[[1]][[1]]),
                verif_matrix_res_10)
   expect_equal(length(grid(shape, resolution = 0.05)),
                4)
   expect_type(suppressMessages(grid(shape, resolution = 10)), "list")
})
test_that("nb_pixel_bbox", {
   shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
                                         -4.375615, 47.79738,
                                         -4.375147, 47.79683,
                                         -4.373898, 47.79790,
                                         -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
   shape <- st_sfc(shape, crs = st_crs(4326))

   expect_equal(nb_pixel_bbox(shape, resolution = 10), c(13,20))
   expect_equal(nb_pixel_bbox(shape, resolution = 0.1), c(1283, 1958))
   expect_type(nb_pixel_bbox(shape, resolution = 10), "double")
   expect_equal(length(nb_pixel_bbox(shape, resolution = 10)), 2)
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
   urls <- construct_urls("apikey", "version", "format", "layer_name", "styles", c(6, 8), c("bbox1", "bbox2"))
   expect_length(urls, 2)
   expect_equal(urls[1],
                "https://wxs.ign.fr/apikey/geoportail/r/wms?version=version&request=GetMap&format=format&layers=layer_name&styles=styles&width=6&height=8&crs=EPSG:4326&bbox=bbox1")
})
test_that("combine_tiles", {

   temp <- tempdir()

   raster <- read_stars(system.file("tif/L7_ETMs.tif", package = "stars"))
   rast_1 <- raster[, 1:10, 1:10]
   rast_2 <- raster[, 11:20, 1:20]

   write_stars(rast_1, file.path(temp, "tile1_pouet.tif"))
   write_stars(rast_2, file.path(temp, "tile2_pouet.tif"))

   tiles_list <- list(rast_1, rast_2)
   filename <- file.path(temp, "pouet.tif")

   raster_final <- combine_tiles(tiles_list, filename)

   expect_s3_class(raster_final, "stars")
   expect_equal(dim(raster_final), c(x = 21, y = 20, band = 6))
   unlink(temp, recursive = TRUE,force = TRUE)
})
