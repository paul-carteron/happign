test_that("multiplication works", {

   shape <- st_polygon(list(matrix(
      c(-4.373937,47.79859,
         -4.375615,47.79738,
         -4.375147,47.79683,
         -4.373898,47.79790,
         -4.373937,47.79859),
      ncol = 2,byrow = TRUE
   )))
   shape <- st_sfc(shape, crs = st_crs(4326))

   apikey = "altimetrie"
   layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES"
   resolution = 5
   filename = NULL
   crs = 2154
   overwrite = FALSE
   version = "1.3.0"
   styles = ""
   interactive = FALSE

   res <- check_get_wms_raster_input(shape, apikey, layer_name, resolution, filename,
                              crs, overwrite, version, styles, interactive)

   # If res is false it means everything works, if not res will be an error
   expect_false(res)

})
