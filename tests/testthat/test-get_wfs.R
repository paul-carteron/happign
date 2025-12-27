test_that("get_wfs() errors on invalid x", {
   expect_error(
      get_wfs(x = 1, layer = "dummy"),
      "`x` should have class"
   )
})

test_that("get_wfs() errors when neither x nor query is provided", {
   expect_error(
      get_wfs(x = NULL, layer = "dummy", query = NULL),
      "At least one of `x` or `query` must be provided"
   )
})

test_that("get_wfs() errors on unknown predicate type", {

   predicate <- "bad_predicate"
   x <- sf::st_sfc(sf::st_point(c(1, 0)), crs = 4326)
   expect_error(
      get_wfs(x, layer = "dummy", predicate = predicate),
      paste0("must be a list with at least .* ", predicate)
   )

})

test_that("get_wfs() works", {
   with_mock_dir(file.path("mock_get_wfs", "single_page"), {
      x <- sf::st_sfc(sf::st_point(c(-4.5, 48.4)), crs = 4326)

      res <- get_wfs(
         x = x,
         layer = "FakeLayer1",
         verbose = FALSE
      )

      expect_s3_class(res, "sf")
      expect_equal("Brest", res$nom_officiel)
      expect_shape(res, dim = c(1, 4)) #~Two row because NumberMatched > offset (500)
   })
})

test_that("get_wfs() iterate when features > offset", {
   with_mock_dir(file.path("mock_get_wfs", "multi_page"), {
      x <- sf::st_sfc(sf::st_point(c(-4.5, 48.4)), crs = 4326)

      res <- get_wfs(
         x = x,
         layer = "FakeLayer1",
         verbose = FALSE
      )

      expect_s3_class(res, "sf")
      expect_all_true(c("Brest", "Penmarch") %in% res$nom_officiel)
      expect_shape(res, dim = c(2, 4)) #~Two row because NumberMatched > offset (500)

   })
})

test_that("get_wfs() return empty sf when no features found", {
   with_mock_dir(file.path("mock_get_wfs", "no_features"), {
      x <- sf::st_sfc(sf::st_point(c(-4.5, 48.4)), crs = 4326)

      expect_message(
         res <- get_wfs(x = x, layer = "FakeLayer1", verbose = TRUE),
         "WFS query returned no features"
      )

      expect_s3_class(res, "sf")
      expect_equal(nrow(res), 0L)
   })
})

test_that("get_wfs() adapt cql_filter to predicate", {
   without_internet({
      #test that correct cql_filter adapat to correct predicate
      x <- sf::st_sfc(sf::st_point(c(1, 0)), crs = 4326)

      local_mocked_bindings(
         get_wfs_default_geometry_name = function(...) "geometrie",
         get_wfs_default_crs = function(...) 4326,
         .package = "happign"
      )

      expect_POST(
         get_wfs(x = x, layer = "layer", predicate = bbox(), verbose = FALSE),
         ".*BBOX.*geometrie.*4326",
         fixed = FALSE
      )

      expect_POST(
         get_wfs(x = x, layer = "layer", predicate = intersects(), verbose = FALSE),
         ".*INTERSECTS.*geometrie.*4326",
         fixed = FALSE
      )

      expect_POST(
         get_wfs(x = x, layer = "layer", predicate = dwithin(999, "meters"), verbose = FALSE),
         ".*DWITHIN.*geometrie.*4326.*999.*meters",
         fixed = FALSE
      )

   })
})

test_that("get_wfs() works with query only", {

   local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "geometrie",
      get_wfs_default_crs = function(...) 4326,
      get_wfs_attributes = function(...) "code_insee",
      .package = "happign"
   )

   without_internet({

      expect_POST(
         get_wfs(
            x = NULL,
            layer = "layer",
            query = "code_insee = '29019'",
            verbose = FALSE
         ),
         ".*code_insee.*29019",
         fixed = FALSE
      )
   })
})

test_that("get_wfs() works with query and x", {

   x <- sf::st_sfc(sf::st_point(c(1, 0)), crs = 4326)

   local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "geometrie",
      get_wfs_default_crs = function(...) 4326,
      get_wfs_attributes = function(...) "code_insee",
      .package = "happign"
   )

   without_internet({

      expect_POST(
         get_wfs(
            x = x,
            layer = "layer",
            query = "code_insee = '29019'",
            verbose = FALSE
         ),
         ".*BBOX.*AND.*code_insee.*29019",
         fixed = FALSE
      )
   })
})

test_that("get_wfs() accepts x with different CRS", {
   with_mock_dir(file.path("mock_get_wfs", "single_page"), {
      x <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 3857)

      local_mocked_bindings(
         get_wfs_default_geometry_name = function(...) "geometrie",
         get_wfs_default_crs = function(...) 4326,
         .package = "happign"
      )

      without_internet({
         expect_POST(
            get_wfs(x = x, layer = "layer", verbose = FALSE),
            ".*4326.*",
            fixed = FALSE
         )
      })
   })
})

test_that("get_wfs() abort when query is wrong", {

   x <- sf::st_sfc(sf::st_point(c(1, 0)), crs = 4326)

   local_mocked_bindings(
      get_wfs_default_geometry_name = function(...) "geometrie",
      get_wfs_default_crs = function(...) 4326,
      get_wfs_attributes = function(...) "not_this_attrs",
      .package = "happign"
   )

   expect_error(
      get_wfs(x, layer = "layer", query = "attrs LIKE '%yo'"),
      "Unknown attribute.*not_this_attrs"
      )

})
