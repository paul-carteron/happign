test_that("are_queryable return error", {
   expect_error(are_queryable("notanapikey"), "administratif")
   expect_error(are_queryable(1), "administratif")
   expect_error(are_queryable(NULL), "administratif")
})

with_mock_dir("are_queryable works", {
   test_that("are_queryable works",{
      skip_on_cran()
      skip_if_offline()

      to_test <- are_queryable("administratif")
      expect_type(to_test, "character")
   })
}, simplify = FALSE)

with_mock_dir("get_wms_info return error", {
   test_that("get_wms_info return error if no ressources", {
      skip_on_cran()
      skip_if_offline()

      shape <- st_polygon(list(matrix(c(-4.373937, 47.79859, -4.375615, 47.79738,
                                        -4.375147, 47.79683, -4.373898, 47.79790,
                                        -4.373937, 47.79859), ncol = 2, byrow = TRUE)))
      shape <- st_sfc(shape, crs = st_crs(4326))

      expect_error(get_wms_info(shape, apikey = "ortho", layer_name = "ORTHOIMAGERY.ORTHOPHOTOS.IRC"),
                   "doesn't have additional information.")
   })
}, simplify = FALSE)

with_mock_dir("get_wms_info works", {
   test_that("get_wms_info works", {
      skip_on_cran()
      skip_if_offline()

      shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
                                       -4.375615, 47.79738,
                                       -4.375147, 47.79683,
                                       -4.373898, 47.79790,
                                       -4.373937, 47.79859),
                                       ncol = 2, byrow = TRUE)))
      shape <- st_sfc(shape, crs = st_crs(4326))

      wms_info <- get_wms_info(shape, "ortho", "ORTHOIMAGERY.ORTHOPHOTOS")

      expect_type(wms_info, "character")
      expect_length(wms_info, 7)
   })
}, simplify = FALSE)
