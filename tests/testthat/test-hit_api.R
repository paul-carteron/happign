test_that("build_req works", {

   # normal case
   path  <- "path_to_test"
   res <- build_req(path, param1 = "param1")
   expect_s3_class(res, "httr2_request")
   expect_equal(res$url, "https://apicarto.ign.fr/path_to_test?param1=param1")

   # error case
   expect_error(build_req(path = 1234), "must be of class character")
   expect_error(build_req(path = NA), "must be of class character")
   expect_error(build_req(path = NULL), "must be of class character")
   expect_error(build_req(path, "test"), "All components of ... must be named")
})

test_that("hit_api_error_offline",{
   # bad path and too complex shape
   req <- build_req(path = "api/rpg/v1",
                    annee = 2013,
                    geom = shp_to_geojson(sf::st_buffer(point, 100)))
   expect_error(hit_api(req), "overly complex shape")
   expect_error(hit_api(NA), "`req` must be an HTTP request")
})

with_mock_dir("hit_api_error", {
   test_that("hit_api_error_online", {
      skip_on_cran()
      skip_if_offline()

      # bad param
      req <- build_req(path = "api/rpg/v1", param1 = "param1")
      expect_error(hit_api(req))
   })
},
simplify = FALSE)
