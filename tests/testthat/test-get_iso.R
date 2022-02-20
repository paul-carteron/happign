test_that("get_iso", {
   point <- sf::st_sfc(sf::st_point(c(2.8,49.4)), crs = 4326)

   expect_error(get_iso(point),
                regexp = "time or distance parameter must be supplied",
                fixed = TRUE)

   vcr::use_cassette("get_iso", {
      routing_dist <- get_iso(point, distance = 10)
      routing_time <- get_iso(point, time = 10)
      routing_ped <- get_iso(point, time = 10, transport = "Pieton")

   })

   expect_equal(as.numeric(sf::st_area(routing_dist)),
                           1.436284,
                           tolerance = 0.1)

   expect_equal(as.numeric(sf::st_area(routing_time)),
                4088,
                tolerance = 1)

   expect_equal(as.numeric(sf::st_area(routing_ped)),
                40,
                tolerance = 1)

   expect_equal(sf::st_crs(routing_dist), sf::st_crs(4326))

})

