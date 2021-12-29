library(testthat)
library(happign)

test_that("hello() returns a character", {
   output <- hello()
   expect_type(output, "character")
})

test_that("hello() returns hello_world", {
   output <- hello()
   expect_equal(output, "Hello, world!")
})
