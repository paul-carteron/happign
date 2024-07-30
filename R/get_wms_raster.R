#' @title Download WMS raster layer
#'
#' @description
#' Download a raster layer from the IGN Web Mapping Services (WMS).
#' Specify a location using a shape and provide the layer name.
#'
#' @usage
#' get_wms_raster(x,
#'                layer = "ORTHOIMAGERY.ORTHOPHOTOS",
#'                res = 10,
#'                crs = 2154,
#'                rgb = TRUE,
#'                filename = tempfile(fileext = ".tif"),
#'                verbose = TRUE,
#'                overwrite = FALSE,
#'                interactive = FALSE)
#'
#' @param x Object of class `sf` or `sfc`, located in France.
#' @param layer `character`; layer name obtained from
#' `get_layers_metadata("wms-r")` or the
#' [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param rgb `boolean`; if set to `TRUE`, downloads an RGB image. If set
#' to `FALSE`, downloads a single band with floating point values.
#' See details for more information.
#' @param res `numeric`; resolution specified in the units of
#' the coordinate system (e.g., meters for EPSG:2154, degrees for EPSG:4326).
#' See details for more information.
#' @param crs `numeric`, `character`, or object of class `sf` or `sfc`;
#' defaults to EPSG:2154. See [sf::st_crs()] for more details.
#' @param filename `character` or `NULL`; specifies the filename or an
#' open connection for writing (e.g., "test.tif" or "~/test.tif").
#' If `NULL`, uses `layer` as the filename. The default format is ".tif",
#' but all [GDAL drivers](https://gdal.org/drivers/raster/index.html)
#' are supported.
#' @param verbose `boolean`; if TRUE, message are added.
#' @param overwrite `boolean`; if TRUE, the existing raster will be overwritten.
#' @param interactive `logical`; if TRUE, an interactive menu prompts for
#' `apikey` and `layer`.
#'
#' @return
#' `SpatRaster` object from `terra` package.
#'
#' @details
#' * `res`: Note that setting `res` higher than the default resolution
#' of the layer will increase the number of pixels but not the precision
#' of the image. For instance, downloading the BD Alti layer from IGN
#' is optimal at a resolution of 25m.
#' * `rgb`: Rasters are commonly used to download images such as orthophotos.
#' In specific cases like DEMs, however, a value per pixel is essential.
#' * `overwrite`: The function `get_wms_raster` first checks if
#' `filename` already exists. If it does, the file is imported into
#' R without downloading again, unless `overwrite` is set to `TRUE`.
#'
#' @importFrom terra rast RGB<- minmax allNA
#' @importFrom sf gdal_utils st_bbox st_crs
#' @importFrom utils menu
#'
#' @seealso
#' [get_layers_metadata()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # Shape from the best town in France
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # For quick testing use interactive = TRUE
#' raster <- get_wms_raster(x = penmarch, res = 25, interactive = TRUE)
#'
#' # For specific data, choose apikey with get_apikey() and layer with get_layers_metadata()
#' apikey <- get_apikeys()[4]  # altimetrie
#' metadata_table <- get_layers_metadata("wms-r", apikey) # all layers for altimetrie wms
#' layer <- metadata_table[2,1] # ELEVATION.ELEVATIONGRIDCOVERAGE
#'
#' # Downloading digital elevation model values not image
#' mnt_2154 <- get_wms_raster(penmarch, layer, res = 1, crs = 2154, rgb = FALSE)
#'
#' # If crs is set to 4326, res is in degrees
#' mnt_4326 <- get_wms_raster(penmarch, layer, res = 0.0001, crs = 4326, rgb = FALSE)
#'
#' # Plotting result
#' tm_shape(mnt_4326)+
#'    tm_raster()+
#' tm_shape(penmarch)+
#'    tm_borders(col = "blue", lwd  = 3)
#'}
#'
get_wms_raster <- function(x,
                           layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                           res = 10,
                           crs = 2154,
                           rgb = TRUE,
                           filename = tempfile(fileext = ".tif"),
                           verbose = TRUE,
                           overwrite = FALSE,
                           interactive = FALSE){

   # check x ----
   if (!inherits(x, c("sf", "sfc"))) {
      stop("`x` must be of class sf or sfc.", call. = F)
   }

   # interactive mode ----
   # if TRUE menu ask for apikey and layer name
   if (interactive){
      choice <- interactive_mode("wms-r")
      layer <- choice$layer
   }

   # check layer ----
   if (!inherits(layer, "character")) {
      stop("`layer` must be of class character.", call. = F)
   }

   # if no filename provided, layer is used by removing non alphanum character
   if (is.null(filename)){
      filename <- gsub("[^[:alnum:]]", "_", layer)
      filename <- paste0(filename, ".tif") # Save as geotiff by default
   }

   # if filename exist and overwrite is set to FALSE, raster is loaded
   if (file.exists(filename) && !overwrite) {
      rast <- rast(filename)
      message("File already exists at ", filename," therefore is loaded.\n",
              "Set overwrite to TRUE to download it again.")
      return(rast)
   }

   sd <- get_sd(layer)
   desc_xml <- generate_desc_xml(sd, rgb)
   bb <- st_bbox(x)

   warp_options <- c(
      "-of", "GTIFF",
      "-te", bb$xmin, bb$ymin, bb$xmax, bb$ymax,
      "-te_srs", st_crs(x)$srid,
      "-t_srs", st_crs(crs)$srid,
      "-tr", res, res,
      "-r", "bilinear",
      if (overwrite) "-overwrite" else NULL
   )

   rast <- gdal_utils("warp",
                      source = desc_xml,
                      destination = filename,
                      quiet=!verbose,
                      options = c(warp_options, create_options()),
                      config_options = config_options()) |>
      suppressWarnings()

   rast <- rast(filename)


   if (sum(minmax(allNA(rast))) == 2){
      message("Raster is empty, NULL is returned")
      return(NULL)
   }

   if (rgb){
      RGB(rast) <- c(1, 2, 3)
      names(rast) <- c("red", "green", "blue")
   }

   if (verbose)
      message("Raster is saved at : ", suppressWarnings(normalizePath(filename)))

   return(rast)

}

#' @title get_sd
#' @description get full subdataset name of a layer
#'
#' @inheritParams get_wms_raster
#'
#' @importFrom sf gdal_utils
#' @importFrom jsonlite fromJSON
#'
#' @noRd
get_sd <- function(layer){
   url <- paste0("https://data.geopf.fr/wms-r?",
                 "SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities")

   metadata <- gdal_utils("info", source = url, quiet = T, options = c("-json", "listmdd"))
   json <- jsonlite::fromJSON(metadata)
   raw_sds <- json$metadata$SUBDATASETS

   pattern <- sprintf("LAYERS=%s&",layer)
   sd <- unlist(raw_sds[grep(pattern, raw_sds)], use.names = FALSE)

   if (is.null(sd)){
      stop(layer, " isn't a valid layer.", call. = F)
   }
   return(sd)
}

#' @title modify_xml_for_float
#' @description get full subdataset name of a layer
#'
#' @param path_to_xml `character`; path where WMS description xml
#' is store
#'
#' @importFrom xml2 read_xml xml_find_first xml_text<- xml_add_sibling write_xml
#'
#' @noRd
modify_xml_for_float <- function(path_to_xml){
   doc <- read_xml(path_to_xml)

   image_format_node <- xml_find_first(doc, "//ImageFormat")
   xml_text(image_format_node) <- 'image/geotiff'

   bands_count_node <- xml_find_first(doc, "//BandsCount")
   xml_text(bands_count_node) <- "1"

   data_type_node <- read_xml("<DataType>Float32</DataType>")
   xml_add_sibling(bands_count_node, data_type_node)

   write_xml(doc, path_to_xml, options = "no_declaration")

   return(NULL)
}

#' @title generate_desc_xml
#' @description generate WMS description xml
#'
#' @param sd `character`; full name of subdataset from `get_sd()`
#' @inheritParams get_wms_raster
#'
#' @importFrom sf gdal_utils
#'
#' @noRd
generate_desc_xml <- function(sd, rgb = TRUE){

   tmp_xml <- tempfile(fileext = ".xml")

   gdal_utils("translate", sd, tmp_xml,
              options = c("-of", "WMS"))

   if (!rgb){
      modify_xml_for_float(tmp_xml)
   }

   return(tmp_xml)

}

#' @title create_options
#' @description storage of create options for gdal_warp
#'
#' @noRd
create_options <- function(){
   c(
      "-co", "COMPRESS=DEFLATE",
      "-co", "PREDICTOR=2",
      "-co", "NUM_THREADS=ALL_CPUS",
      "-co", "BIGTIFF=IF_NEEDED"
   )
}

#' @title config_options
#' @description storage of config options for gdal_warp
#'
#' @noRd
config_options <- function(){

   # GDAL_HTTP_UNSAFESSL is used to avoid safe SSL host / certificate verification
   # which can be problematic when using professional computer
   # GDAL_SKIP is needed for GDAL < 3.5,
   # See https://github.com/rspatial/terra/issues/828 for more

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
}
