test_that("on_attach", {

   expect_message(happign:::.onAttach(),
                  "Please make sure you are connected to the internet.")
   expect_message(happign:::.onAttach(),
                  "Use happign::get_last_news()")
})
