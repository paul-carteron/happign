test_that("format_url return good url", {
   expect_error(format_url())

   apikey <- "apikey"
   layer_name <- "layer_name"
   startindex <- 1

   shape <- sf::st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0),
                                   ncol = 2, byrow = TRUE)))
   shape <- sf::st_sfc(shape)
   sf::st_crs(shape) <- sf::st_crs(4326)

   expect_false(is.na(sf::st_crs(shape)))
   expect_equal(sf::st_crs(shape), sf::st_crs(4326))

   expect_type(format_url(apikey, layer_name, shape, startindex), "character")

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

test_that("get_wfs errors when the API doesn't behave", {
   # example shape for testing
   shape <- sf::st_polygon(list(matrix(c(-4.373, -4.373,
                                     -4.372, -4.372,
                                     -4.373, 47.798,
                                     47.799, 47.799,
                                     47.798, 47.798),
                                   ncol = 2)))
   shape <- sf::st_sfc(shape, crs = sf::st_crs(4326))
   url <- paste0("https://wxs.ign.fr/cartovecto/geoportail/wfs?",
                 "service=WFS&",
                 "version=2.0.0&",
                 "request=GetFeature&",
                 "outputFormat=json&",
                 "srsName=EPSG%3A4326&",
                 "typeName=BDCARTO_BDD_WLD_WGS84G%3Atroncon_route&",
                 "bbox=-4.373%2C47.798%2C-4.372%2C47.799%2Cepsg%3A4326&",
                 "startindex=0")
   webmockr::enable()
   stub <- webmockr::stub_request("get",
                       url)
   webmockr::to_return(stub, status = 503)
   expect_error(get_wfs(shape), regexp = "layer_name", fixed = TRUE)
   webmockr::disable()
})
