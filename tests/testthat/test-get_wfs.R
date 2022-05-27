test_that("req_function", {
   expect_error(req_function())

   apikey <- "apikey"
   layer_name <- "layer_name"
   startindex <- 0

   shape <- sf::st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0),
                                   ncol = 2, byrow = TRUE)))
   shape <- sf::st_sfc(shape)
   sf::st_crs(shape) <- sf::st_crs(2154)

   expect_error(req_function(apikey, layer_name, shape, startindex))

})

test_that("get_wfs", {
      skip_on_cran()
      # example shape for testing
      shape <- sf::st_polygon(list(matrix(c(-4.373, -4.373,
                                        -4.372, -4.372,
                                        -4.373, 47.798,
                                        47.799, 47.799,
                                        47.798, 47.798),
                                      ncol = 2)))
      shape <- sf::st_sfc(shape, crs = sf::st_crs(4326))

      layer_name <- "BDCARTO_BDD_WLD_WGS84G:troncon_route"
      apikey <- "cartovecto"
      vcr::use_cassette("get_wfs", {
         layer <- get_wfs(shape = shape,
                          apikey = apikey,
                          layer_name = layer_name)
         })
      expect_s3_class(layer, "sf")
})
