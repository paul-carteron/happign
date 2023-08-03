with_mock_dir("are_queryable works", {
   test_that("are_queryable works",{
      skip_on_cran()
      skip_if_offline()

      queryable_layers <- are_queryable("administratif")
      expect_type(queryable_layers, "character")
   })
}, simplify = FALSE)

with_mock_dir("get_loc_info error", {
   test_that("get_loc_info error", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_location_info(happign:::point,
                                     apikey = "ortho",
                                     layer = "ORTHOIMAGERY.ORTHOPHOTOS.IRC"),
                   "doesn't have additional information.")
   })
}, simplify = FALSE)

with_mock_dir("get_loc_info", {
   test_that("get_loc_info", {
      skip_on_cran()
      skip_if_offline()

      location_info <- get_location_info(happign:::point,
                                         "agriculture",
                                         "LANDUSE.AGRICULTURE2021")

      expect_s3_class(location_info, "data.frame")
      expect_equal(dim(location_info), c(1,5))
   })
}, simplify = FALSE)

with_mock_dir("get_loc_info sf", {
   test_that("get_loc_info sf", {
      skip_on_cran()
      skip_if_offline()

      location_info <- get_location_info(happign:::point,
                                         "agriculture",
                                         "LANDUSE.AGRICULTURE2021",
                                         read_sf = T)

      expect_s3_class(location_info, "sf")
      expect_equal(dim(location_info), c(1,5))
   })
}, simplify = FALSE)

with_mock_dir("get_loc_info no layer", {
   test_that("get_loc_info no layer", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_location_info(happign:::point,
                                     "adresse", "no_layer"),
                   "No layers from apikey adresse have additional information")

   })
}, simplify = FALSE)

with_mock_dir("get_loc_info no data", {
   test_that("get_loc_info no data", {
      skip_on_cran()
      skip_if_offline()

      expect_error(get_location_info(happign:::point,
                                     "environnement", "FORETS.PUBLIQUES"),
                   "No additional information found.")

   })
}, simplify = FALSE)

