test_that("error when bad format", {
   shape <- st_sfc(sf::st_point(1:3), crs = sf::st_crs(4326))
   expect_error(get_wms_raster(shape,
                               format = "bad_format",
                               filename = "bad_filename"))
})

test_that("format_bbox_wms", {
   expect_error(format_bbox_wms())

   # Test for point
   point <- sf::st_point(1:3)
   expect_match(format_bbox_wms(point),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)

   # Test for multipoint
   multipoint <- sf::st_multipoint(matrix(1:10, 5))
   expect_match(format_bbox_wms(multipoint),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)

   # Test for polygon
   outer <- matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,  byrow = TRUE)
   hole1 <- matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,  byrow = TRUE)
   hole2 <- matrix(c(5, 5, 5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,  byrow = TRUE)
   pts <- list(outer, hole1, hole2)
   polygon <- sf::st_polygon(pts)
   expect_match(format_bbox_wms(polygon),
                "(\\d*\\.\\d*+,)*",
                perl = TRUE)
})

test_that("grid", {
   shape <- sf::st_polygon(list(matrix(c(-4.373937, 47.79859,
                                         -4.375615, 47.79738,
                                         -4.375147, 47.79683,
                                         -4.373898, 47.79790,
                                         -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
   shape <- sf::st_sfc(shape, crs = sf::st_crs(4326))

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
   shape <- sf::st_polygon(list(matrix(c(-4.373937, 47.79859,
                                         -4.375615, 47.79738,
                                         -4.375147, 47.79683,
                                         -4.373898, 47.79790,
                                         -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
   shape <- sf::st_sfc(shape, crs = sf::st_crs(4326))

   expect_equal(nb_pixel_bbox(shape, resolution = 10), c(13,20))
   expect_equal(nb_pixel_bbox(shape, resolution = 0.1), c(1283, 1958))
   expect_type(nb_pixel_bbox(shape, resolution = 10), "double")
   expect_equal(length(nb_pixel_bbox(shape, resolution = 10)), 2)
})


