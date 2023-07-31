test_that("check input", {

   wrap_fun <- function(){
      check_get_wms_raster_input(x, apikey, layer,
                                 res, filename, crs, overwrite,
                                 version, styles, interactive)
   }

   x <- happign:::poly
   apikey <- "altimetrie"
   layer <- "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES"
   res <- 5
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

})
