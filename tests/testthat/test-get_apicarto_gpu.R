test_that("is_valide_gpu_partition work", {
   good_partition <- c(
      "DU_93014", "DU_200057867", "PSMV_78646", "130007123_SUP_93_A7",
      "130007123_SUP_934_A7", "130007123_SUP_93014_A7", "SUP_93_A7"
   )

  good <- lapply(good_partition, \(x) is_valid_gpu_partition(x)$valid) |> unlist()
  expect_true(all(good))

  bad_partition <- c("DU_9301", "error", "PSMV_200057867","ERRR_200057867", "SUP_93A_A7")
  not_good <- lapply(bad_partition, \(x) is_valid_gpu_partition(x)$valid) |> unlist()
  expect_false(all(not_good))

})


with_mock_dir("apicarto-gpu", {
   skip_on_cran()
   skip_if_offline()

   test_that("apicarto GPU works geom", {
      # geom
      x <- st_sfc(st_point(c(5.270, 44.559)), crs = 4326)
      expect_true(nrow(get_apicarto_gpu(x, "document")) == 1)

      # partition
      res <- get_apicarto_gpu("DU_29158", "document")
      expect_true(nrow(res) == 1)

      # multiple partition
      res <- get_apicarto_gpu(c("DU_29158", "DU_29072"), "document")
      expect_true(nrow(res) == 2)

      # insee_code
      res <- get_apicarto_gpu("29158", "municipality")
      expect_true(nrow(res) == 1)

      # multiple insee_code
      res <- get_apicarto_gpu(c("29158", "29072"), "municipality")
      expect_true(nrow(res) == 2)

      #apicarto return NULL when no data"
      expect_warning(
         null <- get_apicarto_gpu("DU_29158", "generateur-sup-l", "AC1"),
         "No data found, NUll is returned"
      )

      expect_null(null)

   })},

simplify = FALSE)

test_that("api_gpu_error", {
   # error insee_code
   expect_error(
      get_apicarto_gpu("93014", "document"),
      "Unknown partition code"
   )


   # error when one bad partition
   expect_error(
      get_apicarto_gpu(c("DU_93014", "bad_partition"), "document"),
      "Unknown partition code"
   )

   # error when partition is used with municipality
   expect_error(
      get_apicarto_gpu("DU_93014", "municipality"),
      "Unknown INSEE code"
   )

   # error when geom is used with acte-sup
   x <- st_sfc(st_point(c(5.270, 44.559)), crs = 4326)
   expect_error(
      get_apicarto_gpu(x, "acte-sup"),
      "Use partition instead"
   )

   # error when multiple geom
   expect_error(
      get_apicarto_gpu(c(happign:::poly, happign:::poly), "acte-sup"),
      "GPU API only accepts one geometry per request"
   )

   # error when multiple layer
   expect_error(
      get_apicarto_gpu("DU_93014", c("acte-sup", "document")),
      "can't have multiple argument"
   )

})
