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

   # point
   expect_match(construct_spatial_filter(x = point,
                                         spatial_filter = c("dwithin", 50, "meters"),
                                         crs = 4326,
                                         apikey = "altimetrie"),
                "DWITHIN(the_geom, POINT (47.813 -4.344), 50, meters)", fixed = T)

   # polygon
   expect_match(construct_spatial_filter(x = poly,
                                         spatial_filter = c("dwithin", 50, "meters"),
                                         crs = 4326,
                                         apikey = "altimetrie"),
                "47.815 -4.347, 47.813 -4.344)), 50, meters)", fixed = T)


   # bbox
   expect_match(construct_spatial_filter(x = poly,
                                         spatial_filter = "bbox",
                                         crs = 4326,
                                         apikey = "altimetrie"),
                "BBOX(the_geom, -4.347, 47.811, -4.344, 47.815, 'EPSG:4326')", fixed = T)

})
test_that("shp_to_geojson", {
   expect_s3_class(shp_to_geojson(point), "json")
   expect_equal(as.character(shp_to_geojson(point)),
                '{"type":"Point","coordinates":[-4.344,47.813]}')

   expect_s3_class(shp_to_geojson(multipoint), "json")
   expect_equal(as.character(shp_to_geojson(multipoint)),
                '{"type":"MultiPoint","coordinates":[[-4.347,47.815],[-4.344,47.813],[-4.346,47.811]]}')

   expect_s3_class(shp_to_geojson(line), "json")
   expect_equal(as.character(shp_to_geojson(line)),
                '{"type":"LineString","coordinates":[[-4.344,47.813],[-4.346,47.811],[-4.347,47.815]]}')


   expect_s3_class(shp_to_geojson(multiline), "json")
   expect_match(as.character(shp_to_geojson(multiline)),
                '{"type":"MultiLineString","coordinates":[[[-4.344,47.813],[-4.346,47.811]', fixed = T)

   expect_s3_class(shp_to_geojson(poly), "json")
   expect_match(as.character(shp_to_geojson(poly)),
                '{"type":"Polygon","coordinates":[[[-4.347,47.815],[-4.346,47.811]', fixed = T)

   expect_s3_class(shp_to_geojson(multipoly), "json")
   expect_match(as.character(shp_to_geojson(multipoly)),
                '{"type":"MultiPolygon","coordinates":[[[[-4.347,47.815],[-4.346,47.811]', fixed = T)



})
test_that("shp_to_geojson crs", {

   expect_s3_class(shp_to_geojson(point, 2154), "json")
   expect_equal(as.character(shp_to_geojson(point, 2154)),
                '{"type":"Point","coordinates":[151147.032,6771386.8213]}')

})
test_that("shp_to_geojson dTolerance", {

   x <- st_buffer(poly, 1)
   geojson <- shp_to_geojson(x)
   simplified_geojson <- shp_to_geojson(x, 4326, 10)
   expect_true(nchar(geojson) > nchar(simplified_geojson))
})
with_mock_dir("get_wfs_default_crs", {
   test_that("get_wfs_default_crs", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_wfs_default_crs("administratif", "badname"),
                   "No crs found")

      crs <- get_wfs_default_crs("altimetrie", "ELEVATION.CONTOUR.LINE:courbe")
      expect_equal(crs, 4326)

   })
}, simplify = FALSE)
