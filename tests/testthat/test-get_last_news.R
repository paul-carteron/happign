with_mock_dir("get_last_news", {
   test_that("get_last_news", {

      expect_message(get_last_news(), "Last news from Geoservice website")
   })
}, simplify = FALSE)
