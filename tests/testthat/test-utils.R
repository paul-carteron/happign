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
   linestring <- sf::st_linestring(matrix(c(-4.35, -4.31,
                                            47.8, 47.8), ncol = 2))
   linestring <- sf::st_sfc(linestring, crs = 4326)

   expect_true(grepl("LineString", shp_to_geojson(linestring)))
   expect_equal(shp_to_geojson(linestring),
                '{"type":"LineString","coordinates":[[-4.35,47.8],[-4.31,47.8]]}')

   # MULTIPLE POLYGON
   poly2 <- sf::st_polygon(list(matrix(c(-4.26, -4.26,
                                         -4.24, -4.24,
                                         -4.26, 47.79,
                                         47.80, 47.80,
                                         47.79, 47.79), ncol = 2)))
   poly2 <- sf::st_sfc(poly2, crs = 4326)

   multiple_poly <- c(poly, poly2)

   expect_true(grepl("MultiPolygon", shp_to_geojson(multiple_poly)))
   expect_equal(shp_to_geojson(multiple_poly),
                '{"type":"MultiPolygon","coordinates":[[[[-4.373,47.798],[-4.373,47.799],[-4.372,47.799],[-4.372,47.798],[-4.373,47.798]]],[[[-4.26,47.79],[-4.26,47.8],[-4.24,47.8],[-4.24,47.79],[-4.26,47.79]]]]}')

})
test_that("null shape", {
   expect_null(shp_to_geojson(NULL))
})
test_that("sf is convert to sfc", {
   shape_sf <- read_sf(system.file("shape/nc.shp", package = "sf"))[1,]
   shape_sf <- st_cast(shape_sf, "POLYGON", warn = FALSE)

   expect_match(shp_to_geojson(shape_sf), "\\[\\[\\[")
   expect_match(shp_to_geojson(shape_sf), "\\]]]")
})
