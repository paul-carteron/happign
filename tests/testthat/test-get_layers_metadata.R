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

      expect_equal(dim(res), c(13, 3))
      expect_equal(names(res),
                   c("Name", "Title", "Abstract"))
      })
})
