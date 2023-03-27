test_that("error", {
   expect_error(get_apicarto_cadastre(29760))
})

with_mock_dir("get_api_codes_postaux", {
   test_that("get_api_codes_postaux", {
      skip_on_cran()
      skip_if_offline()

      simple_req <- get_apicarto_codes_postaux("29760")
      multi_req <- get_apicarto_codes_postaux(c("29760", "29160"))

      expect_equal(dim(simple_req), c(1, 4))
      expect_equal(class(simple_req), "data.frame")

      expect_equal(dim(multi_req), c(3, 4))
      expect_equal(class(simple_req), "data.frame")
   })
}, simplify = FALSE)
