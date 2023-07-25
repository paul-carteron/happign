test_that("build_url", {
   url <- build_url("apikey", "layer_name")

   expect_equal(url,
                paste0("WMS:https://wxs.ign.fr/apikey/geoportail/r/wms?",
                       "VERSION=1.3.0&REQUEST=GetMap&LAYERS=layer_name&",
                       "CRS=EPSG:4326&BBOX=-90,-180,90,180"))
})
test_that("wms_base_case", {
      skip_on_cran()
      skip_if_offline()

      filename <- tempfile(fileext = ".tif")

      mnt <- get_wms_raster(shape = happign:::poly,
                            res = 25,
                            filename = filename,
                            overwrite = TRUE)

      expect_s4_class(mnt, "SpatRaster")
      expect_true(st_crs(mnt) == st_crs(2154))
      expect_equal(dim(mnt), c(18, 8, 3))
})
test_that("wms_crs", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(shape = happign:::poly,
                         res = 25,
                         filename = filename,
                         crs = 27572,
                         overwrite = TRUE)

   expect_s4_class(mnt, "SpatRaster")
   expect_true(st_crs(mnt) == st_crs(27572))
   expect_equal(dim(mnt), c(18, 8, 3))
})
test_that("wms_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(shape = happign:::poly,
                         res = 25,
                         filename = filename)

   expect_message(get_wms_raster(shape = happign:::poly,
                              res = 25,
                              filename = filename),
                     "File already exists at")
})
test_that("wms_jpg", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   mnt <- get_wms_raster(shape = happign:::poly,
                         res = 25,
                         filename = filename)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(18, 8, 3))
})
test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(shape = happign:::multipoly,
                         res = 25,
                         filename = filename)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(20, 29, 3))
})
test_that("wms_bad_name", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   expect_error(get_wms_raster(shape = happign:::poly,
                         res = 25,
                         layer_name = "badname",
                         filename = filename,
                         overwrite = TRUE),
                " Check that `layer_name` is valid")
})
test_that("wms_bad_res", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   expect_error(get_wms_raster(shape = happign:::poly,
                               res = 1,
                               filename = filename,
                               crs = 4326,
                               overwrite = TRUE),
                "Check that `res` is given")
})

