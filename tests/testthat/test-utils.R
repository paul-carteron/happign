test_that("st_as_text_happign", {
   skip_on_ci()
   skip_on_cran()
   # Point
   expect_match(st_as_text_happign(point, 4326),
                "POINT (47.813 -4.344)", fixed = TRUE)
   expect_match(st_as_text_happign(point, 2154),
                "POINT (151147 6771387)", fixed = TRUE)
   # Polygon
   expect_match(st_as_text_happign(poly, 4326),
                "POLYGON ((47.813 -4.344", fixed = TRUE)
   expect_match(st_as_text_happign(poly, 2154),
                "POLYGON ((151147 6771387", fixed = TRUE)

})
test_that("spatial_filter", {
   skip_on_ci()
   skip_on_cran()
   expect_error(construct_spatial_filter(point, c("dwithin", 50, "bad_units"), "apikey"),
                "When using \"dwithin\" units should be one of")

   layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"

   # point
   expect_match(construct_spatial_filter(x = point,
                                         spatial_filter = c("dwithin", 50, "meters"),
                                         crs = 4326,
                                         layer = layer),
                "DWITHIN(geometrie, POINT (47.813 -4.344), 50, meters)", fixed = T)

   # polygon
   expect_match(construct_spatial_filter(x = poly,
                                         spatial_filter = c("dwithin", 50, "meters"),
                                         crs = 4326,
                                         layer = layer),
                "47.815 -4.347, 47.813 -4.344)), 50, meters)", fixed = T)


   # bbox
   expect_match(construct_spatial_filter(x = poly,
                                         spatial_filter = "bbox",
                                         crs = 4326,
                                         layer = layer),
                "BBOX(geometrie, -4.347, 47.811, -4.344, 47.815, 'EPSG:4326')", fixed = T)

})
with_mock_dir("get_wfs_default_crs", {
   test_that("get_wfs_default_crs", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_wfs_default_crs("badname"), "No crs found")

      crs <- get_wfs_default_crs("ELEVATION.CONTOUR.LINE:courbe")
      expect_equal(crs, 4326)

   })
}, simplify = FALSE)

with_mock_dir("get_wfs_default_geometry_name", {
   test_that("get_wfs_default_geometry_name", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_wfs_default_geometry_name("badname"),
                   "DescribeFeatureType returned 404 for layer 'badname'")

      geometry_name <- get_wfs_default_geometry_name("ELEVATION.CONTOUR.LINE:courbe")
      expect_equal(geometry_name, "geom")

   })
}, simplify = FALSE)
