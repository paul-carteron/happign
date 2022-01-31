test_that(".onAttach() with internet connection", {
   skip_if_offline()
   expect_message(happign:::.onAttach(), regexp = "IGN", fixed = TRUE)
})
