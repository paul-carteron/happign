with_mock_dir("get_layers_metada_wfs", {
   test_that("get_layers_metada_wfs", {

      res <- get_layers_metadata("wfs")

      expect_equal(dim(res), c(658, 3))
      expect_equal(names(res),
                   c("Name", "Title", "Abstract"))
      })
})

with_mock_dir("get_layers_metada_wms", {
   # /!\ you have to manually change encoding to "ISO-8859-1" inside .xml or .R file from mocking
   test_that("get_layers_metada_wms", {

      res <- get_layers_metadata("wms-r")

      expect_equal(dim(res), c(302, 3))
      expect_equal(names(res),
                   c("Name", "Title", "Abstract"))
      })
})

with_mock_dir("get_layers_metada_wmts", {
   # /!\ you have to manually change encoding to "ISO-8859-1" inside .xml or .R file from mocking
   test_that("get_layers_metada_wmts", {

      res <- get_layers_metadata("wmts")

      expect_equal(dim(res), c(539, 3))
      expect_equal(names(res),
                   c("Title", "Abstract", "Identifier"))
   })
})


test_that("get_layers_metada_error", {

   expect_error(get_layers_metadata("wms"), "'data_type' should be one")
   expect_error(get_layers_metadata(NA), "'data_type' should be one")
   #expect_error(get_layers_metadata(NULL), "`apikey` must be of class")
})
