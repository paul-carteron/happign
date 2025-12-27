
with_mock_dir(file.path("mock_utils", "get_wfs_default_crs"), {
   test_that("get_wfs_default_crs() works", {

      crs <- get_wfs_default_crs("GoodLayer1")
      expect_equal(crs, "good_crs")

      expect_error(
         get_wfs_default_crs("BadLayer"),
         "No CRS found: layer does not exist.*BadLayer"
      )
   })
})

with_mock_dir(file.path("mock_utils", "get_wfs_default_geometry_name"), {
   test_that("get_wfs_default_geometry_name", {

      geometry_name <- get_wfs_default_geometry_name("GoodLayer1")
      expect_equal(geometry_name, "fake_geom")

   })
})
