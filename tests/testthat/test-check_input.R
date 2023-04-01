test_that("check input", {

   wrap_fun <- function(){
      check_get_wms_raster_input(shape, apikey, layer_name,
                                 resolution, filename, crs, overwrite,
                                 version, styles, interactive)
   }

   shape <- poly
   apikey <- "altimetrie"
   layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES"
   resolution <- 5
   filename <- NULL
   crs <- 2154
   overwrite <- FALSE
   version <- "1.3.0"
   styles <- ""
   interactive <- FALSE

   # everything good
   expect_null(wrap_fun())

   # shape
   shape <- NULL
   expect_null(wrap_fun())

   # bad apikey
   apikey <- "bad_apikey"
   expect_error(wrap_fun(),
                "`apikey` must be a character from")

   # personnal key
   apikey <- "abcdefghijklmno123456789"
   expect_null(wrap_fun())

   # resolution
   resolution <- 0.01
   expect_warning(wrap_fun(),
                  "`resolution` param is less than 0.2 cm")

})
