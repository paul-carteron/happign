library(vcr)
invisible(vcr::vcr_configure(
   dir = vcr::vcr_test_path("fixtures")
))
vcr::check_cassette_names()
