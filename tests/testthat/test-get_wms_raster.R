layer <- "ELEVATION.ELEVATIONGRIDCOVERAGE"
res <- 25

test_that("wms_base_case", {
      skip_on_cran()
      skip_if_offline()

      crs <- 2154

      mnt_rgb <- get_wms_raster(happign:::poly, layer, res, crs)
      mnt <- get_wms_raster(happign:::poly, layer, res, crs, rgb = F)

      expect_s4_class(mnt_rgb, "SpatRaster")
      expect_s4_class(mnt, "SpatRaster")

      expect_true(st_crs(mnt_rgb) == st_crs(2154))
      expect_true(st_crs(mnt) == st_crs(2154))

      expect_equal(dim(mnt_rgb), c(17, 11, 3))
      expect_equal(dim(mnt), c(17, 11, 1))

      expect_named(mnt_rgb, c("red", "green", "blue"))

      expect_true(terra::minmax(mnt, compute=T)["max",] >= 0)
})

test_that("wms_crs", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::poly,
                         layer, res,
                         crs = 27572)

   expect_s4_class(mnt, "SpatRaster")
   expect_true(st_crs(mnt) == st_crs(27572))
   expect_equal(dim(mnt), c(17, 10, 3))
   expect_true(all(terra::minmax(mnt, compute=T)["max",] >= 0))
})

test_that("wms_overwrite", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".tif")

   mnt <- get_wms_raster(happign:::poly, layer, res,
                         filename = filename)

   expect_message(get_wms_raster(happign:::poly, layer, res,
                                 filename = filename),
                  "File already exists at")
})

test_that("wms_png", {
   skip_on_cran()
   skip_if_offline()

   filename <- tempfile(fileext = ".png")

   mnt <- get_wms_raster(happign:::poly,
                         layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                         res = 25,
                         filename = filename)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(17, 11, 3))
   expect_true(terra::minmax(mnt, compute=T)["max",1] >= 0)
})

test_that("wms_multipoly", {
   skip_on_cran()
   skip_if_offline()

   mnt <- get_wms_raster(happign:::multipoly, layer, res)

   expect_s4_class(mnt, "SpatRaster")
   expect_equal(dim(mnt), c(15, 31, 3))
   expect_true(all(terra::minmax(mnt, compute=T)["max",] >= 0))

})

test_that("wms_bad_name", {
   skip_on_cran()
   skip_if_offline()

   expect_error(get_wms_raster(happign:::poly,
                               layer = "badname",
                               res = 25,
                               overwrite = TRUE),
                "isn't a valid layer.")
})

test_that("get_sd_work", {
   skip_on_cran()
   skip_if_offline()

   wms_url <- get_sd(layer)
   normal_result <- paste0(
      "WMS:https://data.geopf.fr/wms-r/wms?",
      "SERVICE=WMS",
      "&VERSION=1.3.0",
      "&REQUEST=GetMap",
      "&LAYERS=", layer,
      "&CRS=IGNF:WGS84G",
      "&BBOX=-64.000000000,-23.000000000,168.000000000,52.000000000"
   )
   expect_equal(wms_url, normal_result)
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
