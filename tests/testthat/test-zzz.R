test_that("on_attach", {

   expect_message(happign:::.onAttach(),
                  "Please make sure you have an internet connection.")
   expect_message(happign:::.onAttach(),
                  "Use happign::get_last_news()")

   expect_equal(options()$timeout, 3600)
})
