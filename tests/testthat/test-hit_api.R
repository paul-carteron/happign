test_that("build_req works", {

   # normal case
   path  <- "path_to_test"
   res <- build_req(path, param1 = "param1")
   expect_s3_class(res, "httr2_request")
   expect_equal(res$url, "https://apicarto.ign.fr/path_to_test?param1=param1")
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
