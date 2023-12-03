test_that("x_to_iso works", {

   expect_error(x_to_iso(happign:::line), "LINESTRING")
   expect_error(x_to_iso(happign:::multiline), "MULTILINESTRING")
   expect_error(x_to_iso(happign:::multipoint), "MULTIPOINT")
   expect_error(x_to_iso(happign:::poly), "POLYGON")
   expect_error(x_to_iso(happign:::multipoly), "MULTIPOLYGON")

   expect_error(x_to_iso(NULL), "NULL")
   expect_error(x_to_iso(NA), "logical")
   expect_error(x_to_iso(NaN), "numeric")

   one_point <- x_to_iso(happign:::point)
   expect_equal(class(one_point), "list")
   expect_length(one_point, 1)
   expect_equal(one_point, list("-4.344,47.813"))

   multiple_point <- x_to_iso(c(happign:::point, happign:::point))
   expect_equal(class(multiple_point), "list")
   expect_length(multiple_point, 2)
   expect_equal(multiple_point, list("-4.344,47.813", "-4.344,47.813"))

})

test_that("build_iso_query works", {

   req <- build_iso_query(
      point = "point",
      source = "source",
      value = "value",
      type = "type",
      profile = "profile",
      direction = "direction",
      constraints = "constraints",
      distance_unit = "distance_unit",
      time_unit = "time_unit"
   )

   expect_s3_class(req, "httr2_request")
   expect_length(req, 7)
   expect_match(req$url,
                "https://wxs.ign.fr/calcul/geoportail/isochrone/rest/1.0.0/isochrone")
   expect_equal(req$options$ssl_verifypeer, 0)
})

with_mock_dir("get_iso_works", {
   test_that("get_iso_works", {
      skip_on_cran()
      skip_if_offline()

      time_minute <- get_iso(happign:::point, 5, "time")
      expect_s3_class(time_minute, "sf")
      expect_true(st_is(time_minute, "POLYGON"))
      expect_named(time_minute, "geometry")

      time_second <- get_iso(happign:::point, 5, "time",
                             time_unit = "second")
      expect_false(time_minute == time_second)

      dist <- get_iso(happign:::point, 500, "distance")
      expect_s3_class(dist, "sf")
      expect_true(st_is(dist, "POLYGON"))
      expect_named(dist, "geometry")

      expect_false(time_minute == dist)

   })
},
simplify = FALSE)

with_mock_dir("get_isodistance_works", {
   test_that("get_isodistance_works", {
      skip_on_cran()
      skip_if_offline()


      dist <- get_isodistance(happign:::point, 500)
      expect_s3_class(dist, "sf")
      expect_true(st_is(dist, "POLYGON"))
      expect_named(dist, "geometry")


   })
},
simplify = FALSE)

with_mock_dir("get_isochrone_works", {
   test_that("get_isochrone_works", {
      skip_on_cran()
      skip_if_offline()

      time <- get_isochrone(happign:::point, 2)
      expect_s3_class(time, "sf")
      expect_true(st_is(time, "POLYGON"))
      expect_named(time, "geometry")

   })
},
simplify = FALSE)
