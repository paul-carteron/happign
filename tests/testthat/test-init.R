with_mock_dir("on_attach", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("on_attach", {
      skip_on_cran()
      skip_if_offline()

      expect_message(happign:::.onAttach(), "Last news from IGN website")
      expect_message(happign:::.onAttach(), "IGN web service API is available")
   })
}, simplify = FALSE)

with_mock_dir("on_attach_error", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("on_attach_error", {
      skip_on_cran()
      skip_if_offline()

      expect_message(happign:::.onAttach(), "is unavailable")
   })
}, simplify = FALSE)
