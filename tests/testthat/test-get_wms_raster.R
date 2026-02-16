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
      create_options(rgb = TRUE),
      c(
         "-co", "BLOCKSIZE=512",
         "-co", "NUM_THREADS=ALL_CPUS",
         "-co", "BIGTIFF=IF_NEEDED",
         "-co", "TILED=YES",
         "-co", "COMPRESS=JPEG",
         "-co", "JPEG_QUALITY=95",
         "-co", "PHOTOMETRIC=RGB"
      )
   )

   expect_equal(
      create_options(rgb = FALSE),
      c(
         "-co", "BLOCKSIZE=512",
         "-co", "NUM_THREADS=ALL_CPUS",
         "-co", "BIGTIFF=IF_NEEDED",
         "-co", "TILED=YES",
         "-co", "COMPRESS=DEFLATE",
         "-co", "PREDICTOR=3"
      )
   )
})

test_that("config_options_work", {
   expect_equal(
      config_options(),
      c(
         GDAL_SKIP = "DODS",
         GDAL_HTTP_UNSAFESSL = "YES",
         GDAL_HTTP_VERSION = "2",
         GDAL_HTTP_MAX_RETRY = "5",
         GDAL_HTTP_RETRY_DELAY = "2",
         GDAL_HTTP_TIMEOUT = "120",
         GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
         GDAL_CACHEMAX = "512",
         GDAL_HTTP_USERAGENT = "happign (https://github.com/paul-carteron/happign)",
         GDAL_HTTP_MULTIPLEX = "NO"
       )
   )
})

test_that("warp_options_work", {

   opts_rgb_overwrite <- warp_options(x, crs, res, rgb = TRUE, overwrite = TRUE)
   opts_rgb <- warp_options(x, crs, res, rgb = TRUE, overwrite = FALSE)
   opts_dem <- warp_options(x, crs, res, rgb = FALSE, overwrite = FALSE)

   # Core GDAL flags
   expect_true("-of" %in% opts_rgb)
   expect_true("GTIFF" %in% opts_rgb)

   expect_true("-te" %in% opts_rgb)
   expect_true("-te_srs" %in% opts_rgb)
   expect_true("-t_srs" %in% opts_rgb)

   # CRS correctness (SRID expected)
   expect_true("EPSG:4326" %in% opts_rgb)
   expect_true("EPSG:2154" %in% opts_rgb)

   # Resolution
   idx_tr <- which(opts_rgb == "-tr")
   expect_true(opts_rgb[idx_tr + 1] == as.character(res))
   expect_true(opts_rgb[idx_tr + 2] == as.character(res))

   # Warp memory
   expect_true("-wm" %in% opts_rgb)
   expect_true("512" %in% opts_rgb)

   # Warp options
   expect_true("-wo" %in% opts_rgb)
   expect_true("SOURCE_EXTRA=50" %in% opts_rgb)

   # Resampling logic
   expect_true("cubic" %in% opts_rgb)
   expect_true("bilinear" %in% opts_dem)

   # overwrite logic
   expect_true("-overwrite" %in% opts_rgb_overwrite)
   expect_false("-overwrite" %in% opts_rgb)

})
