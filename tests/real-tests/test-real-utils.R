
test_that("get_wfs_default_crs() returns expected CRS for valid layer", {

   skip_on_cran()
   skip_if_offline()

   layer <- "BDCARTO_V5:commune"
   crs <- get_wfs_default_crs(layer)

   expect_type(crs, "character")
   expect_length(crs, 1)
   expect_equal(crs, "urn:ogc:def:crs:EPSG::4326")
})

test_that("get_wfs_default_crs() errors for non-existing layer", {

   skip_on_cran()
   skip_if_offline()

   expect_error(
      get_wfs_default_crs("BDCARTO_V5:this_layer_does_not_exist"),
      "No CRS found: layer does not exist",
      fixed = TRUE
   )
})

test_that("get_wfs_default_crs() errors on invalid input type", {

   skip_on_cran()
   skip_if_offline()

   expect_error(get_wfs_default_crs(NULL))
   expect_error(get_wfs_default_crs(123))
   expect_error(get_wfs_default_crs(c("a", "b")))
})

test_that("get_wfs_default_crs() returns a CRS URN", {

   skip_on_cran()
   skip_if_offline()

   crs <- get_wfs_default_crs("BDCARTO_V5:commune")

   expect_match(crs, "^urn:ogc:def:crs:")
})

test_that("get_wfs_default_crs() works for multiple known layers", {

   skip_on_cran()
   skip_if_offline()

   all_layers <- get_layers_metadata("wfs")$Name
   layers <- all_layers[seq(1, length(all_layers), by = 70)]
   crs <- vapply(layers, get_wfs_default_crs, character(1))

   expect_all_true(grepl("urn:ogc:def:crs:", crs))
})
