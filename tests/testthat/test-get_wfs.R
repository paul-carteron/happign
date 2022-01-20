library(sf)
library(webmockr)

test_that("format_bbox return expected format", {
   # Test for errors
   expect_error(format_bbox_wfs())

   # Test for point
   point <- st_point(1:3)
   expect_match(format_bbox_wfs(point),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)

   # Test for multipoint
   multipoint <- st_multipoint(matrix(1:10, 5))
   expect_match(format_bbox_wfs(multipoint),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)

   # Test for polygon
   outer <- matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,  byrow = TRUE)
   hole1 <- matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,  byrow = TRUE)
   hole2 <- matrix(c(5, 5, 5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,  byrow = TRUE)
   pts <- list(outer, hole1, hole2)
   polygon <- st_polygon(pts)
   expect_match(format_bbox_wfs(polygon),
                "(\\d*\\.\\d*+,)*+epsg:4326",
                perl = TRUE)
})
test_that("format_url return good url", {
   expect_error(format_url())

   apikey <- "apikey"
   layer_name <- "layer_name"
   startindex <- 1

   shape <- st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0),
                                   ncol = 2, byrow = TRUE)))
   shape <- st_sfc(shape)
   st_crs(shape) <- st_crs(4326)

   expect_false(is.na(st_crs(shape)))
   expect_equal(st_crs(shape), st_crs(4326))

   expect_type(format_url(apikey, layer_name, shape, startindex), "character")

})

vcr::use_cassette("get_wfs", {
   test_that("get_wfs", {
      # example shape for testing
      shape <- st_polygon(list(matrix(c(-4.373, -4.373,
                                        -4.372, -4.372,
                                        -4.373, 47.798,
                                        47.799, 47.799,
                                        47.798, 47.798),
                                      ncol = 2)))
      shape <- st_sfc(shape, crs = st_crs(4326))

      layer_name <- "BDCARTO_BDD_WLD_WGS84G:troncon_route"
      apikey <- "cartovecto"
      layer <- get_wfs(shape = shape,
                                apikey = apikey,
                                layer_name = layer_name)

      expect_s3_class(layer, "sf")
      })
   })

test_that("get_wfs errors when the API doesn't behave", {
   # example shape for testing
   shape <- st_polygon(list(matrix(c(-4.373, -4.373,
                                     -4.372, -4.372,
                                     -4.373, 47.798,
                                     47.799, 47.799,
                                     47.798, 47.798),
                                   ncol = 2)))
   shape <- st_sfc(shape, crs = st_crs(4326))
   url <- paste0("https://wxs.ign.fr/cartovecto/geoportail/wfs?",
                 "service=WFS&",
                 "version=2.0.0&",
                 "request=GetFeature&",
                 "outputFormat=json&",
                 "srsName=EPSG%3A4326&",
                 "typeName=BDCARTO_BDD_WLD_WGS84G%3Atroncon_route&",
                 "bbox=-4.373%2C47.798%2C-4.372%2C47.799%2Cepsg%3A4326&",
                 "startindex=0")
   enable()
   stub <- stub_request("get",
                       url)
   to_return(stub, status = 503)
   expect_error(get_wfs(shape), regexp = "layer_name", fixed = TRUE)
   disable()
})
