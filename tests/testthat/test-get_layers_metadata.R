test_that("constructor", {
  expect_error(constructor(1, "wfs"), "character")
  expect_error(constructor("administratif", 1), "character")
  expect_error(constructor("administratif", "pouet"), "data_type")
  expect_error(constructor("pouet", "wfs"), "one of")
})


test_that("xml_to_df", {
   example_data <-
      xml2::xml_children(xml2::read_xml(xml2::xml2_example("cd_catalog.xml")))
   expect_equal(dim(xml_to_df(example_data)), c(26, 7))
   expect_equal(
      names(xml_to_df(example_data)),
      c(
         "itemindex",
         "TITLE",
         "ARTIST",
         "COUNTRY",
         "COMPANY",
         "PRICE",
         "YEAR"
      )
   )
})

test_that("get_layers_metada_wfs", {

   vcr::use_cassette("get_layers_metada_wfs", {
      res <- get_layers_metadata("altimetrie", "wfs")
   })

   expect_equal(dim(res), c(1, 7))
   expect_equal(names(res),
                c("itemindex", "name", "title", "abstract",
                  "keywords", "defaultcrs", "wgs84boundingbox"))
})


test_that("get_layers_metada_wms", {

   vcr::use_cassette("get_layers_metada_wms", {
      res <- get_layers_metadata("ortho", "wms")
   })

   expect_equal(dim(res), c(12, 12))
   expect_equal(names(res),
                c("itemindex", "name", "title", "abstract", "keywordlist", "crs",
                  "ex_geographicboundingbox", "boundingbox", "metadataurl", "style",
                  "minscaledenominator", "maxscaledenominator"))
})
