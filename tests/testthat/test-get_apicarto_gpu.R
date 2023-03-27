test_that("incorrect_partition", {
   p1 = "DU_93014"
   p2 = "DU_200057867"
   p3 = "PSMV_78646"
   p4 = "130007123_SUP_93_A7"
   p5 = "130007123_SUP_934_A7"
   p6 = "130007123_SUP_93014_A7"
   p7 = "SUP_93_A7"
   expect_false(all(incorrect_partition(p1)))
   expect_false(all(incorrect_partition(p2)))
   expect_false(all(incorrect_partition(p3)))
   expect_false(all(incorrect_partition(p4)))
   expect_false(all(incorrect_partition(p5)))
   expect_false(all(incorrect_partition(p6)))
   expect_false(all(incorrect_partition(p7)))

   p8 = "DU_9301"
   p9 = "error"
   p10 = "PSMV_200057867"
   p11 = "ERRR_200057867"
   p12 = "SUP_93A_A7"
   expect_true(all(incorrect_partition(p8)))
   expect_true(all(incorrect_partition(p9)))
   expect_true(all(incorrect_partition(p10)))
   expect_true(all(incorrect_partition(p11)))

   x = c("DU_93014", "DU_93014")
   expect_false(all(incorrect_partition(x)))

   x = c("DU_93014", "DU_93013454")
   expect_true(all(incorrect_partition(x)))

})

x <- st_sfc(st_point(c(5.270, 44.559)), crs = 4326)

with_mock_dir("api_gpu_x_input", {
   test_that("api_gpu_x_input", {
      skip_on_cran()
      skip_if_offline()
      skip_on_os("mac")

      # geom
      res <- get_apicarto_gpu(x, ressource = "document")
      expect_true(nrow(res) == 1)

      # partition
      res <- get_apicarto_gpu("DU_93014", ressource = "document")
      expect_true(nrow(res) == 1)

      # multiple partition
      res <- get_apicarto_gpu(c("DU_93014", "DU_93015"), ressource = "document")
      expect_true(nrow(res) == 2)

      # insee_code
      res <- get_apicarto_gpu("93015", ressource = "municipality")
      expect_true(nrow(res) == 1)

      # multiple insee_code
      res <- get_apicarto_gpu(c("93014", "93015"), ressource = "municipality")
      expect_true(nrow(res) == 2)

      # multiple poly
      x1 <- st_sfc(st_point(c(5.270, 44.559)), crs = 4326) |>
         st_as_sf()
      x2 <- st_sfc(st_point(c(5.384, 44.495)), crs = 4326) |>
         st_as_sf()
      res <- get_apicarto_gpu(rbind(x1, x2), ressource = "document", dTolerance = 10)
      expect_true(nrow(res) == 2)

   })},
simplify = FALSE)

test_that("api_gpu_error", {
   # error insee_code
   expect_error(get_apicarto_gpu("93014", ressource = "document"),
                "insee code can only be used when")


   # error when one bad partition
   expect_error(
      get_apicarto_gpu(
         x = c("DU_93014", "bad_partition"),
         ressource = "document"
      ),
      "isn't a valid format for `partition`."
   )

   # error when partition is used with municipality
   expect_error(
      get_apicarto_gpu("DU_93014", ressource = "municipality"),
      "Use insee code instead."
   )

   # error when geom is used with acte-sup
   expect_error(
      get_apicarto_gpu(x, ressource = "acte-sup"),
      "Use partition instead"
   )

})
