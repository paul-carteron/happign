penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
point <- suppressWarnings(st_centroid(penmarch$geometry))

test_that("st_as_text_happign", {

   # Point
   expect_match(st_as_text_happign(point, 4326),
                "POINT (47.79967 -4.369559)", fixed = TRUE)
   expect_match(st_as_text_happign(point, 2154),
                "POINT (149104.3 6770090)", fixed = TRUE)
   # Polygon
   expect_match(st_as_text_happign(penmarch, 4326),
                "POLYGON ((47.79591 -4.366168", fixed = TRUE)
   expect_match(st_as_text_happign(penmarch, 2154),
                "POLYGON ((149318.2 6769650", fixed = TRUE)

})
with_mock_dir("spatial_filter",{
   test_that("spatial_filter", {
      skip_on_cran()
      skip_if_offline()

      expect_error(construct_spatial_filter(point, c("dwithin", 50, "bad_units"), "apikey"),
                   "When using \"dwithin\" units should be one of")

      # point
      expect_match(construct_spatial_filter(point, c("dwithin", 50, "meters"), "altimetrie",
                                            "ELEVATION.CONTOUR.LINE:courbe"),
                   "DWITHIN(the_geom, POINT (47.79967 -4.369559), 50, meters)", fixed = T)

      # polygon
      expect_match(construct_spatial_filter(penmarch, "intersects", "altimetrie",
                                            "ELEVATION.CONTOUR.LINE:courbe"),
                   "47.79589 -4.36608, 47.79591 -4.366168)))", fixed = T)

      # lines
      ## To do

      # bbox
      expect_match(construct_spatial_filter(penmarch, "bbox", "altimetrie",
                                            "ELEVATION.CONTOUR.LINE:courbe"),
                   "BBOX(the_geom, -4.37490785, 47.7958932774251, -4.36480757910826, 47.8030338007718, 'EPSG:4326')",
                   fixed = T)

   })
})
