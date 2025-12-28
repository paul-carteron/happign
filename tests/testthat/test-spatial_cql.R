test_that("spatial_cql() errors on invalid predicate", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   expect_error(
      spatial_cql(x, "layer", predicate = "not_a_list"),
      "`predicate` must be a list"
   )

   expect_error(
      spatial_cql(x, "layer",  predicate = list()),
      "`predicate` must be a list"
   )
})

test_that("spatial_cql() works with bbox() helper", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   testthat::local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "the_geom",
      get_wfs_default_crs = function(...) 4326,
      bbox_cql = function(x, geom_name, crs) sprintf("BBOX(%s, %s)", geom_name, crs$epsg),
      .package = "happign"
   )

   res <- spatial_cql(x, "layer", bbox())

   expect_equal(res, "BBOX(the_geom, 4326)")
})

test_that("spatial_cql() builds simple spatial predicates", {

   x <- sf::st_sfc(sf::st_point(c(1, 2)), crs = 4326)

   testthat::local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "the_geom",
      get_wfs_default_crs = function(...) 4326,
      .package = "happign"
   )

   # Simple predicates
   simple_cases <- list(
      intersects = intersects(),
      within     = within(),
      contains   = contains(),
      touches    = touches(),
      crosses    = crosses(),
      overlaps   = overlaps(),
      equals     = equals()
   )

   for (type in names(simple_cases)) {
      res <- spatial_cql(x, "layer", simple_cases[[type]])

      expect_match(res, paste0("^", toupper(type), "\\(the_geom,"))
      expect_match(res, "SRID=4326;")
   }
})

test_that("spatial_cql() works with dwithin() and beyond() helpers", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   testthat::local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "the_geom",
      get_wfs_default_crs = function(...) 4326,
      .package = "happign"
   )

   res1 <- spatial_cql(x, "layer", dwithin(10, "meters"))
   res2 <- spatial_cql(x, "layer", beyond(5, "kilometers"))

   expect_match(res1, "^DWITHIN\\(the_geom,")
   expect_match(res1, "10, meters\\)$")

   expect_match(res2, "^BEYOND\\(the_geom,")
   expect_match(res2, "5, kilometers\\)$")
})

test_that("spatial_cql() works with relate() helper", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   testthat::local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "the_geom",
      get_wfs_default_crs = function(...) 4326,
      .package = "happign"
   )

   res <- spatial_cql(x, "layer", relate("T*F**F***"))

   expect_match(res, "^RELATE\\(the_geom,")
   expect_match(res, "'T\\*F\\*\\*F\\*\\*\\*'\\)$")
})

test_that("spatial_cql() errors on unknown predicate type", {

   x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)

   local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "the_geom",
      get_wfs_default_crs = function(...) 4326,
      .package = "happign"
   )

   expect_error(
      spatial_cql(x, "layer", list(type = "foo")),
      "Unknown predicate type"
   )
})
