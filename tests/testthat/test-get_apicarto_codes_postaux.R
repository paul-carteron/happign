
# tests/testthat/test-cadastre-httptest2.R
with_mock_dir("apicarto-codes-postaux", {
   skip_on_cran()
   skip_if_offline()

   expect_work <- \(x, row = 1) {
      expect_s3_class(x, "data.frame")
      expect_true(nrow(x) >= row)
   }

   test_that("apicarto codes postaux works", {
      expect_work(get_apicarto_codes_postaux("29760"))
      expect_work(get_apicarto_codes_postaux(29760))
      expect_work(get_apicarto_codes_postaux(08170))
   })

   test_that("apicarto cadastre vectorization works", {
      expect_work(get_apicarto_codes_postaux(c("29760", "08170")), row = 2)
   })

   test_that("apicarto return warning and data", {
      warn_msg <- \(x) paste("No data found for :", x)

      expect_warning(get_apicarto_codes_postaux("1234"), warn_msg("01234"))
      expect_null(get_apicarto_codes_postaux("1234") |> suppressWarnings())

      expect_work(get_apicarto_codes_postaux(c("29760","1234")) |> suppressWarnings())
   })


 })
