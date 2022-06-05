with_mock_dir("get_apicarto_cadastre sfc",{
   test_that("download_cadastre", {
      skip_on_cran()
      skip_if_offline()

      shape <- st_polygon(list(matrix(c(-4.373937, 47.79859, -4.375615, 47.79738, -4.375147, 47.79683,
                                        -4.373898, 47.79790, -4.373937, 47.79859), ncol = 2, byrow = TRUE)))
      shape <- st_sfc(shape, crs = st_crs(4326))

      res <- get_apicarto_cadastre(shape)

      expect_s3_class(res, "sf")
   })
}, simplify = FALSE)
with_mock_dir("get_apicarto_cadastre sf",{
   test_that("download_cadastre", {
      skip_on_cran()
      skip_if_offline()

      shape <- st_polygon(list(matrix(c(-4.373937, 47.79859, -4.375615, 47.79738, -4.375147, 47.79683,
                                        -4.373898, 47.79790, -4.373937, 47.79859), ncol = 2, byrow = TRUE)))
      shape <- st_sfc(shape, crs = st_crs(4326))
      shape_sf <- st_as_sf(shape)

      res <- get_apicarto_cadastre(shape_sf)

      expect_s3_class(res, "sf")
   })
}, simplify = FALSE)
with_mock_dir("get_apicarto_cadastre character",{
   test_that("download_cadastre", {
      skip_on_cran()
      skip_if_offline()

      res <- get_apicarto_cadastre("26274", numero = "0001")

      expect_s3_class(res, "sf")
   })
}, simplify = FALSE)
test_that("get_apicarto_cadastre error",{
   expect_error(get_apicarto_cadastre(x = "29158",
                                      source_ign = "notaninput"),
                "should be one of")

   expect_error(get_apicarto_cadastre(x = "1231213231"),
                "is not a valid INSEE code")
})
