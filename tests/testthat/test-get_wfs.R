penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

test_that("hit_api_wfs format bbox from sf object", {

   expect_s3_class(penmarch, "sf")
   expect_equal(dim(penmarch), c(1, 4))

   bbox <- st_bbox(st_transform(penmarch, 4326))
   expect_s3_class(bbox, "bbox")
   expect_length(bbox, 4)

   formated_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          "epsg:4326",
                          sep = ",")
   expect_type(formated_bbox, "character")
   expect_length(formated_bbox, 1)
   expect_equal(length(gregexpr(",",formated_bbox, fixed = TRUE)[[1]]), 4)
})

test_that("hit_api_wfs format bbox from sfc object", {

   penmarch <- st_as_sfc(penmarch)
   expect_s3_class(penmarch, "sfc")
   expect_equal(length(penmarch), 1)

   bbox <- st_bbox(st_transform(penmarch, 4326))
   expect_s3_class(bbox, "bbox")
   expect_length(bbox, 4)

   formated_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          "epsg:4326",
                          sep = ",")
   expect_type(formated_bbox, "character")
   expect_length(formated_bbox, 1)
   expect_equal(length(gregexpr(",",formated_bbox, fixed = TRUE)[[1]]), 4)

})
test_that("hit_api_wfs build request properly", {

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      srsName = "EPSG:4326",
      typeName = "layer_name",
      bbox = "formated_bbox",
      startindex = "startindex",
      count = 1000
   )

   apikey <- "VERIF"

   request <- request("https://wxs.ign.fr") %>%
      req_url_path_append(apikey) %>%
      req_url_path_append("geoportail/wfs") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_query(!!!params)

   expect_s3_class(request, "httr2_request")
   expect_equal(nchar(request$url), 194)
   expect_match(request$url, "VERIF")

})
test_that("hit_api_wfs error", {
   layer_name <- "no_need"

   expect_error(hit_api_wfs("a"))
   expect_error(hit_api_wfs())
   expect_error(hit_api_wfs(shape, layer_name,  1000)) # Don't forget the apikey !
   expect_error(hit_api_wfs("parcellaire", shape, layer_name,  1000)) # Forbidden
})

with_mock_dir("hit_api_wfs perform request", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("hit_api_wfs perform request", {

      apikey <- "parcellaire"
      layer_name <- "CADASTRALPARCELS.PARCELLAIRE_EXPRESS:parcelle"

      resp <- hit_api_wfs(penmarch, apikey, layer_name, startindex = 0)
      expect_s3_class(resp, "sf")
   })
}, simplify = FALSE)

with_mock_dir("get_wfs simple request", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("get_wfs", {
      skip_on_cran()
      skip_if_offline()

      apikey <- "administratif"
      layer_name <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:canton"

      filename <- file.path(tempdir(), "test_name.shp")

      layer <- get_wfs(shape = penmarch,
                       apikey = apikey,
                       layer_name = layer_name,
                       overwrite = TRUE,
                       filename = filename)

      expect_s3_class(layer, "sf")

   })
}, simplify = FALSE)
