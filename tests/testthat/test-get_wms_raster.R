x <- happign:::poly
layer <- "ORTHOIMAGERY.ORTHOPHOTOS"
res <- 25
crs <- 2154

test_that("generate_desc_xml_work", {
   skip_on_cran()
   skip_if_offline()

   sd <- get_sd(layer)

   tmp_xml <- generate_desc_xml(sd)
   xml <- paste0(readLines(tmp_xml), collapse = "")
   xml <- gsub(" ", "", xml)

   expect_false(grepl("<DataType>Float32</DataType>", xml))
   expect_false(grepl("<ImageFormat>image/geotiff</ImageFormat>", xml))

   expect_true(grepl("<ImageFormat>image/jpeg</ImageFormat>", xml))
   expect_true(grepl("<Version>.*<ServerUrl>.*<Layers>.*<CRS>", xml))

   # also test modify_xml_for_float
   modified_xml <- modify_xml_for_float(tmp_xml)
   xml <- readLines(tmp_xml)

   expect_true(grepl("<DataType>Float32</DataType>", xml))
   expect_true(grepl("<ImageFormat>image/geotiff</ImageFormat>", xml))

   expect_false(grepl("<ImageFormat>image/jpeg</ImageFormat>", xml))
   expect_true(grepl("<Version>.*<ServerUrl>.*<Layers>.*<CRS>", xml))

   # also test modify_xml_for_png
   modified_xml <- modify_xml_for_png(tmp_xml)
   xml <- readLines(tmp_xml)

   expect_true(grepl("<ImageFormat>image/png</ImageFormat>", xml))

})

test_that("create_options_work", {
   expect_equal(
      create_options(),
      c(
         "-co", "COMPRESS=DEFLATE",
         "-co", "PREDICTOR=2",
         "-co", "NUM_THREADS=ALL_CPUS",
         "-co", "BIGTIFF=IF_NEEDED"
      )
   )
})

test_that("config_options_work", {
   expect_equal(
      config_options(),
      c(
         GDAL_SKIP = "DODS",
         GDAL_HTTP_UNSAFESSL = "YES",
         VSI_CACHE = "TRUE",
         GDAL_CACHEMAX = "30%",
         VSI_CACHE_SIZE = "10000000",
         GDAL_HTTP_MULTIPLEX = "YES",
         GDAL_INGESTED_BYTES_AT_OPEN = "32000",
         GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
         GDAL_HTTP_VERSION = "2",
         GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
         GDAL_HTTP_USERAGENT = "happign (https://github.com/paul-carteron/happign)"
      )
   )
})

test_that("warp_options_work", {
   warp_opts_overwrite <- warp_options(x, crs, res, overwrite = T)
   warp_opts <- warp_options(x, crs, res, overwrite = F)

   expect_equal(
      warp_opts_overwrite,
      c(
         "-of", "GTIFF",
         "-te", xmin = "-4.347", ymin = "47.811", xmax = "-4.344", ymax = "47.815",
         "-te_srs", "EPSG:4326",
         "-t_srs", "EPSG:2154",
         "-tr", "25", "25",
         "-r", "bilinear",
         "-overwrite"
      )
   )

   expect_equal(
      warp_opts,
      c(
         "-of", "GTIFF",
         "-te", xmin = "-4.347", ymin = "47.811", xmax = "-4.344", ymax = "47.815",
         "-te_srs", "EPSG:4326",
         "-t_srs", "EPSG:2154",
         "-tr", "25", "25",
         "-r", "bilinear"
      )
   )
})

