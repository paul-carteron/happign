x <- happign:::poly
layer <- "ORTHOIMAGERY.ORTHOPHOTOS"
res <- 25
crs <- 2154

test_that("wms_base_case", {
   skip_on_cran()
   skip_if_offline()

   base_case <- get_wms_raster(x, layer, res, crs, verbose = F)

   expect_true(st_crs(base_case) == st_crs(2154))
   expect_equal(terra::nlyr(base_case), 3)
   expect_named(base_case, c("red", "green", "blue"))

   # check rgb value are not empty
   expect_true(all(terra::minmax(base_case, compute=T)["max",] >= 0))
})

test_that("wms_rgb", {
   skip_on_cran()
   skip_if_offline()

   rgb_FALSE <- get_wms_raster(x, layer, res, crs, rgb = FALSE, verbose = F)

   expect_equal(terra::nlyr(rgb_FALSE), 1)

})

test_that("wms_crs", {
   skip_on_cran()
   skip_if_offline()

   new_crs <- 27572
   crs_CHANGED <- get_wms_raster(happign:::poly, layer, res, crs = new_crs, verbose = F)

   expect_true(st_crs(crs_CHANGED) == st_crs(new_crs))

})

test_that("wms_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")
   first_download <- get_wms_raster(x, layer, res, crs, filename = filename, verbose = F)

   expect_message(get_wms_raster(x, layer, res, filename = filename),
                  "Using cached file")
})

test_that("wms_png", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   png <- get_wms_raster(x, layer, res, filename = filename, verbose = F)

   expect_true(all(terra::minmax(png, compute=T)["max",] >= 0))
})

test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   multipoly <- get_wms_raster(x, layer, res, verbose = F)

   expect_equal(terra::nlyr(multipoly), 3)
   expect_true(all(terra::minmax(multipoly, compute=T)["max",] >= 0))

})

test_that("wms_bad_name", {
   skip_on_cran()
   skip_if_offline()

   expect_error(get_wms_raster(x, layer = "badname"), "isn't a valid layer name.")
})

test_that("get_sd_work", {
   skip_on_cran()
   skip_if_offline()

   wms_url <- get_sd(layer)
   url_clean <- sub("^WMS:", "", wms_url)

   parsed <- httr2::url_parse(url_clean)

   expect_equal(parsed$scheme, "https")
   expect_equal(parsed$hostname, "data.geopf.fr")
   expect_equal(parsed$path, "/wms-r/wms")

   query <- parsed$query

   expect_equal(query$SERVICE, "WMS")
   expect_equal(query$VERSION, "1.3.0")
   expect_equal(query$REQUEST, "GetMap")
   expect_equal(query$LAYERS, layer)
   expect_equal(query$CRS, "EPSG:3857")
   # 4 digit separate with comma
   expect_true(grepl("[-0-9.]+,[-0-9.]+,[-0-9.]+,[-0-9.]+", query$BBOX))
})

test_that("generate_desc_xml_work", {
   skip_on_cran()
   skip_if_offline()

   sd <- get_sd(layer)

   tmp_xml <- generate_desc_xml(sd, rgb = T)
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

