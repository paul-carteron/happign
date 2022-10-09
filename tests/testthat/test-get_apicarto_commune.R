test_that("match_arg works", {
   expect_error(get_apicarto_commune("pouet", "erreur"),
                "'arg' should be one of")
})

with_mock_dir("get_apicarto_commune_1", {
   test_that("error no returned features character", {
      skip_on_cran()
      skip_if_offline()
      expect_error(get_apicarto_commune("29760"),
                   "Check that insee or department code exists")
      })
}, simplify = FALSE)

with_mock_dir("get_apicarto_commune_2", {
   test_that("error no returned features sf", {
      skip_on_cran()
      skip_if_offline()

      x <- st_point(c(-4.798, 47.762)) |>
         st_sfc(crs = st_crs(4326)) |>
         st_sf()

      expect_error(get_apicarto_commune(x),
                   "Check that the shape is in France")
   })
}, simplify = FALSE)

with_mock_dir("get_apicarto_commune_4", {
   test_that("character object works",{
      skip_on_cran()
      skip_if_offline()
      res <- get_apicarto_commune("29158")
      expect_s3_class(res, "sf")
      expect_equal(dim(res), c(1, 6))
   })
}, simplify = FALSE)

# with_mock_dir("get_apicarto_commune_3", {
#    test_that("sf and sfc object works",{
#       skip_on_cran()
#       skip_if_offline()
#
#       x <- st_point(c(-4.362, 47.808)) |>
#          st_sfc(crs = st_crs(4326)) |>
#          st_sf()
#
#       res <- get_apicarto_commune(x)
#       expect_s3_class(res, "sf")
#       expect_equal(dim(res), c(1, 6))
#    })
# }, simplify = F)

