with_mock_dir("get_layers_metada_wfs", {
   test_that("get_layers_metada_wfs", {

      res <- get_layers_metadata("altimetrie", "wfs")

      expect_equal(dim(res), c(2, 3))
      expect_equal(names(res),
                   c("Name", "Title", "Abstract"))
      })
})

with_mock_dir("get_layers_metada_wms", {
   # /!\ you have to manually change encoding to "ISO-8859-1" inside .xml or .R file from mocking
   test_that("get_layers_metada_wms", {

      res <- get_layers_metadata("ortho", "wms")

      expect_equal(dim(res), c(14, 3))
      expect_equal(names(res),
                   c("Name", "Title", "Abstract"))
      })
})

with_mock_dir("get_layers_metada_null", {
   test_that("get_layers_metada_null", {

      expect_warning(get_layers_metadata("adresse", "wms"),
                     "There's no wms resources")
   })
})

test_that("get_layers_metada_error", {

   expect_error(get_layers_metadata("bad_apikey", "wms"), "`apikey` must be one of :")
   expect_error(get_layers_metadata(NA, "wms"), "`apikey` must be of class")
   expect_error(get_layers_metadata(NULL, "wms"), "`apikey` must be of class")
   expect_error(get_layers_metadata(c("altimetrie", "adresse"), "wms"), "Only one")
})
