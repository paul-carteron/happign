test_that("incorrect_partition", {
   good_partition <- c(
      "DU_93014", "DU_200057867", "PSMV_78646", "130007123_SUP_93_A7",
      "130007123_SUP_934_A7", "130007123_SUP_93014_A7", "SUP_93_A7"
   )

   lapply(good_partition, \(x) expect_false(all(incorrect_partition(x)))) |>
      invisible()

   bad_partition <- c(
      "DU_9301", "error", "PSMV_200057867",
      "ERRR_200057867", "SUP_93A_A7"
      )
   lapply(bad_partition, \(x) expect_true(all(incorrect_partition(x)))) |>
      invisible()


   x = c("DU_93014", "DU_93014")
   expect_false(all(incorrect_partition(x)))

   x = c("DU_93014", "DU_93013454")
   expect_true(all(incorrect_partition(x)))

})

x <- st_sfc(st_point(c(5.270, 44.559)), crs = 4326)

with_mock_dir("apicarto-gpu", {
   skip_on_cran()
   skip_if_offline()

   test_that("apicarto GPU works geom", {
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
