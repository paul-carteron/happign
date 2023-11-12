test_that("wms_base_case", {
      skip_on_cran()
      skip_if_offline()

      mnt <- get_wms_raster(x = happign:::poly)

      expect_s4_class(mnt, "SpatRaster")
      expect_true(st_crs(mnt) == st_crs(2154))
      expect_equal(dim(mnt), c(11, 15, 1))
})
test_that("wms_crs", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::poly,
                         crs = 27572)

   expect_s4_class(mnt, "SpatRaster")
   expect_true(st_crs(mnt) == st_crs(27572))
   expect_equal(dim(mnt), c(12, 15, 1))
})
test_that("wms_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(happign:::poly,
                         filename = filename)

   expect_message(get_wms_raster(happign:::poly,
                                 res = 25,
                                 filename = filename),
                  "File already exists at")
})
test_that("wms_png", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   mnt <- get_wms_raster(happign:::poly,
                         apikey = "ortho",
                         layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                         res = 25,
                         filename = filename)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(11, 15, 3))
})
test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::multipoly)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(31, 12, 1))
})
test_that("wms_bad_name", {
   skip_on_cran()
   skip_if_offline()

   expect_error(get_wms_raster(happign:::poly,
                               res = 25,
                               layer = "badname",
                               overwrite = TRUE),
                " Check that `layer` is valid")
})
