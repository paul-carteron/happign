test_that("get_apicarto_gpu error", {
   expect_error(get_apicarto_gpu(x = "character"))
   expect_error(get_apicarto_gpu(NULL, partition = "poor little string"))
   expect_error(get_apicarto_gpu(NULL, ressource = "Don't expecting this ressource !"))
})

with_mock_dir("get_apicarto_gpu partition", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("work when partition is known", {
      skip_on_cran()
      skip_if_offline()

      partition <- "DU_17345"
      poly <- get_apicarto_gpu(x = NULL,
                               ressource = "zone-urba",
                               partition = partition,
                               categorie = NULL)

      expect_equal(dim(poly), c(39, 17))
      expect_s3_class(poly, "sf")
   })
}, simplify = FALSE)

with_mock_dir("get_apicarto_gpu geom", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("work when geom is provided", {
      skip_on_cran()
      skip_if_offline()

      point <- st_sfc(st_point(c(-0.49, 45.42)), crs = 4326)
      poly <- get_apicarto_gpu(x = point, ressource = "zone-urba")

      expect_equal(dim(poly), c(1, 17))
      expect_s3_class(poly, "sf")
   })
}, simplify = FALSE)
