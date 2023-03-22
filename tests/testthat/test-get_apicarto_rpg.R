x <- st_buffer(poly, 500)

with_mock_dir("get_apicarto_rpg", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("get_apicarto_rpg", {
      skip_on_cran()
      skip_if_offline()

      # simple poly
      res <- get_apicarto_rpg(x, 2020, dTolerance = 10)
      expect_equal(dim(res), c(9, 9))
      expect_s3_class(res, "sf")

      # multiple years from same version
      res <- get_apicarto_rpg(x, 2020:2021, dTolerance = 10)
      expect_equal(dim(res), c(18, 9))
      expect_s3_class(res, "sf")

      # multiple years from different version
      res <- get_apicarto_rpg(x, c(2010, 2021), dTolerance = 10)
      expect_equal(class(res), "list")
      expect_equal(length(res), 2)

      # code_cultu
      res <- get_apicarto_rpg(x, 2021, code_cultu = "MIE", dTolerance = 10)
      expect_equal(dim(res), c(3, 9))
      expect_s3_class(res, "sf")

      # multiple code_cultu, multiple years
      res <- get_apicarto_rpg(x, 2020:2021, code_cultu = c("MIE", "PPH"), dTolerance = 10)
      expect_equal(dim(res), c(6, 9))
      expect_s3_class(res, "sf")

      # vectorization
      res <- get_apicarto_rpg(x, 2020:2021, code_cultu = "MIE", dTolerance = 10)
      expect_equal(res$code_cultu, rep("MIE", 6))
      expect_s3_class(res, "sf")

   })
}, simplify = FALSE)


