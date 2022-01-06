library(xml2)

test_that("constructor", {
  expect_error(constructor(1, "wfs"), "character")
  expect_error(constructor("administratif", 1), "character")
  expect_error(constructor("administratif", "pouet"), "data_type")
  expect_error(constructor("pouet", "wfs"), "one of")
})

test_that("xml_to_df", {
   example_data <- xml_children(read_xml(xml2_example("cd_catalog.xml")))
   expect_equal(dim(xml_to_df(example_data)), c(26, 7))
   expect_equal(names(xml_to_df(example_data)), c("itemindex",
                                                  "TITLE",
                                                  "ARTIST",
                                                  "COUNTRY",
                                                  "COMPANY",
                                                  "PRICE",
                                                  "YEAR"))
})

vcr::use_cassette("get_layers_metada_wfs", {
   test_that("get_layers_metada_wfs", {
      apikey <- "altimetrie"
      data_type <- "wfs"

      res <- get_layers_metadata(apikey, data_type)
      expect_equal(dim(res), c(1, 4))
      expect_equal(names(res),
                   c("keywords", "name", "abstract", "defaultcrs"))
   })
})
