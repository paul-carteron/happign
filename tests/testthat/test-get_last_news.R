with_mock_dir("get_last_news", {
   test_that("get_last_news", {

      expect_message(get_last_news(), "Last news from IGN website")
   })
}, simplify = FALSE)

with_mock_dir("get_last_news_error", {
   test_that("get_last_news_error", {
      # get_last_news_error moxk is modify to respond 404 error
      expect_message(get_last_news(), "IGN actuality is unavailable")
   })
}, simplify = FALSE)
