layer <- "ELEVATION.ELEVATIONGRIDCOVERAGE"
res <- 25

test_that("wms_base_case", {
      skip_on_cran()
      skip_if_offline()

      crs <- 2154

      mnt_rgb <- get_wms_raster(happign:::poly, layer, res, crs)
      mnt <- get_wms_raster(happign:::poly, layer, res, crs, rgb = F)

      expect_s4_class(mnt_rgb, "SpatRaster")
      expect_s4_class(mnt, "SpatRaster")

      expect_true(st_crs(mnt_rgb) == st_crs(2154))
      expect_true(st_crs(mnt) == st_crs(2154))

      expect_equal(dim(mnt_rgb), c(17, 11, 3))
      expect_equal(dim(mnt), c(17, 11, 1))

      expect_named(mnt_rgb, c("red", "green", "blue"))

      expect_true(terra::minmax(mnt, compute=T)["max",] >= 0)
})

test_that("wms_crs", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::poly,
                         layer, res,
                         crs = 27572)

   expect_s4_class(mnt, "SpatRaster")
   expect_true(st_crs(mnt) == st_crs(27572))
   expect_equal(dim(mnt), c(17, 10, 3))
   expect_true(all(terra::minmax(mnt, compute=T)["max",] >= 0))
})

test_that("wms_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(happign:::poly, layer, res,
                         filename = filename)

   expect_message(get_wms_raster(happign:::poly, layer, res,
                                 filename = filename),
                  "File already exists at")
})

test_that("wms_png", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   mnt <- get_wms_raster(happign:::poly,
                         layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                         res = 25,
                         filename = filename)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(17, 11, 3))
   expect_true(terra::minmax(mnt, compute=T)["max",1] >= 0)
})

test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::multipoly, layer, res)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(15, 31, 3))
   expect_true(all(terra::minmax(mnt, compute=T)["max",] >= 0))

})

test_that("wms_bad_name", {
   skip_on_cran()
   skip_if_offline()

   expect_error(get_wms_raster(happign:::poly,
                               layer = "badname",
                               res = 25,
                               overwrite = TRUE),
                "isn't a valid layer.")
})
