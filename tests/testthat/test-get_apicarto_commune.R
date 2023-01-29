test_that("match_arg works", {
   expect_error(get_apicarto_commune("pouet", "erreur"),
                "'arg' should be one of")
})

with_mock_dir("get_api_com_error", {
   test_that("error no returned features character", {
      skip_on_cran()
      skip_if_offline()
      expect_warning(get_apicarto_commune("29760"),
                   "No data found, NULL is returned.")
      })
}, simplify = FALSE)

with_mock_dir("get_api_com", {
   test_that("character object works",{
      skip_on_cran()
      skip_if_offline()
      res <- get_apicarto_commune("29158")
      expect_s3_class(res, "sf")
      expect_equal(dim(res), c(1, 6))
   })
}, simplify = FALSE)

with_mock_dir("get_api_com_sfc", {
   test_that("sf and sfc object works",{
      skip_on_cran()
      skip_if_offline()

      res <- get_apicarto_commune(point)
      expect_s3_class(res, "sf")
      expect_equal(dim(res), c(1, 6))
   })
}, simplify = F)

