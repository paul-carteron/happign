test_that("sf_to_polygon", {

   # POLYGON
   poly <- sf::st_polygon(list(matrix(c(-4.373, -4.373,
                                        -4.372, -4.372,
                                        -4.373, 47.798,
                                        47.799, 47.799,
                                        47.798, 47.798), ncol = 2)))
   poly <- sf::st_sfc(poly, crs = 4326)

   expect_true(grepl("Polygon", shp_to_geojson(poly)))
   expect_equal(shp_to_geojson(poly),
                '{"type":"Polygon","coordinates":[[[-4.373,47.798],[-4.373,47.799],[-4.372,47.799],[-4.372,47.798],[-4.373,47.798]]]}')

   # POINT
   point <- sf::st_point(c(-4.373, -4.373))
   point <- sf::st_sfc(point, crs = 4326)

   expect_true(grepl("Point", shp_to_geojson(point)))
   expect_equal(shp_to_geojson(point),
                '{"type":"Point","coordinates":[-4.373,-4.373]}')

   # LINESTRING
   linestring <- sf::st_linestring(matrix(c(-4.373, -4.373,
                                            -4.372, -4.372), ncol = 2))
   linestring <- sf::st_sfc(linestring, crs = 4326)

   expect_true(grepl("LineString", shp_to_geojson(linestring)))
   expect_equal(shp_to_geojson(linestring),
                '{"type":"LineString","coordinates":[[-4.373,-4.372],[-4.373,-4.372]]}')

   # MULTIPLE POLYGON
   poly2 <- sf::st_polygon(list(matrix(c(-4.374, -4.374,
                                        -4.373, -4.373,
                                        -4.374, 47.799,
                                        47.710, 47.710,
                                        47.799, 47.799), ncol = 2)))
   poly2 <- sf::st_sfc(poly, crs = 4326)

   multiple_poly <- c(poly, poly2)

   expect_true(grepl("Polygon", shp_to_geojson(multiple_poly)))
   expect_equal(shp_to_geojson(multiple_poly),
                '{"type":"Polygon","coordinates":[[[-4.373,47.798],[-4.373,47.799],[-4.372,47.799],[-4.372,47.798],[-4.373,47.798]],[[-4.373,47.798],[-4.373,47.799],[-4.372,47.799],[-4.372,47.798],[-4.373,47.798]]]}')

})
