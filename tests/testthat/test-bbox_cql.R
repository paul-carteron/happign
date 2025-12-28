test_that("bbox_cql() builds BBOX with EPSG when CRS has epsg", {

   x <- sf::st_sfc(
      sf::st_polygon(list(
         matrix(c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE)
      )),
      crs = 4326
   )

   res <- bbox_cql(x, geom_name = "the_geom", crs = st_crs(4326))

   expect_match(res, "^BBOX\\(the_geom,")
   expect_match(res, "EPSG:4326'\\)$")
})

test_that("bbox_cql() omits EPSG when CRS has no epsg", {

   x <- sf::st_sfc(
      sf::st_point(c(0, 0)),
      crs = sf::st_crs("+proj=longlat +datum=WGS84")
   )

   crs_no_epsg <- sf::st_crs("+proj=longlat +datum=WGS84")

   res <- bbox_cql(x, geom_name = "geom", crs = crs_no_epsg)

   expect_match(res, "^BBOX\\(geom,")
   expect_false(grepl("EPSG", res))
})

test_that("bbox_cql() transforms geometry to target CRS", {

   x <- sf::st_sfc(
      sf::st_point(c(0, 0)),
      crs = 4326
   )

   # Transform to Web Mercator
   res <- bbox_cql(x, geom_name = "geom", crs = 3857)

   expect_match(res, "EPSG:3857")
})

test_that("bbox_cql() uses xmin, ymin, xmax, ymax order", {

   x <- sf::st_sfc(
      sf::st_polygon(list(
         matrix(c(1, 2, 5, 2, 5, 6, 1, 6, 1, 2), ncol = 2, byrow = TRUE)
      )),
      crs = 4326
   )

   res <- bbox_cql(x, geom_name = "geom", crs = 4326)

   nums <- regmatches(res, gregexpr("[0-9]+\\.[0-9]+", res))[[1]]
   nums <- as.numeric(nums)

   expect_equal(length(nums), 4)
   expect_true(nums[1] <= nums[3]) # xmin <= xmax
   expect_true(nums[2] <= nums[4]) # ymin <= ymax
})

test_that("bbox_cql() accepts CRS as epsg integer or crs object", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   res1 <- bbox_cql(x, "geom", 4326)
   res2 <- bbox_cql(x, "geom", sf::st_crs(4326))

   expect_equal(res1, res2)
})
