test_that("wmts_base_case", {
   skip_on_cran()
   skip_if_offline()

   rast <- get_wmts(poly)

   expect_true(terra::has.RGB(rast))
   expect_s4_class(rast, "SpatRaster")
   expect_equal(dim(rast), c(4, 2, 4))
   expect_true(sf::st_crs(rast) == sf::st_crs(2154))
})

test_that("wmts_crs", {
   skip_on_cran()
   skip_if_offline()

   rast <- get_wmts(poly, crs = 4326)

   expect_true(terra::has.RGB(rast))
   expect_s4_class(rast, "SpatRaster")
   expect_equal(dim(rast), c(3, 3, 4))
   expect_true(sf::st_crs(rast) == sf::st_crs(4326))
})

test_that("wmts_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   rast <- get_wmts(poly, filename = filename)
   expect_message(get_wmts(poly, crs = 4326, filename = filename, overwrite = F),
                  "File already exists at")
})

test_that("wmts_bad_apikey", {
   expect_error(get_wmts(poly, apikey = "bad_apikey"))
})

test_that("wmts_bad_layer", {
   expect_error(get_wmts(poly,layer = "bad_layer"), "Check that")
})

test_that("wmts_png", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   rast <- get_wmts(poly, filename = filename)
   expect_true(terra::has.RGB(rast))
   expect_s4_class(rast, "SpatRaster")
   expect_equal(dim(rast), c(4,2,4))
})

test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   rast <- get_wmts(happign:::multipoly)

   expect_s4_class(rast, "SpatRaster")
   expect_equal(dim(rast), c(5, 7, 4))

})

