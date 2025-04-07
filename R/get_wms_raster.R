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
#'                filename = NULL,
#'                overwrite = FALSE,
#'                verbose = TRUE,
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
#' The default format is ".tif" but all
#' [GDAL drivers](https://gdal.org/en/latest/drivers/raster/index.html)
#' are supported.
#' When a filename is provided, the function uses it as a cache: if the
#' file already exists and `overwrite` is set to `FALSE`, the function
#' will directly load the raster from that file instead of re-downloading it.
#' @param verbose `boolean`; if TRUE, message are added.
#' @param overwrite `boolean`; if TRUE, the existing raster will be overwritten.
#' @param interactive `logical`; if TRUE, an interactive menu prompts for
#' `apikey` and `layer` argument.
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
#' In specific cases like DEMs, however, a value per pixel is essential. See
#' examples below.
#'
#' @importFrom terra rast RGB<- minmax allNA nlyr
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
                           filename = NULL,
                           overwrite = FALSE,
                           verbose = TRUE,
                           interactive = FALSE){

   # Validate inputs
   if (!inherits(x, c("sf", "sfc"))){
      stop("`x` must be of class sf or sfc.", call. = FALSE)
   }

   if (!is.character(layer)){
      stop("`layer` must be a character string.", call. = FALSE)
   }

   if (interactive) {
      choice <- interactive_mode("wms-r")  # assume interactive_mode() is defined elsewhere.
      layer <- choice$layer
   }

   sd <- get_sd(layer)
   desc_xml_path <- generate_desc_xml(sd)

   if (!rgb){
      modify_xml_for_float(desc_xml_path)
   }

   # Perform the warp safely; the warp function always writes to the dest_file.
   outfile <- safe_gdal_warp(x, desc_xml_path, res, crs, filename, overwrite, verbose)
   rast <- rast(outfile)

   if (sum(minmax(allNA(rast), compute = T)) == 2){
      message("Raster is empty, NULL is returned")
      return(NULL)
   }

   if (rgb && nlyr(rast) == 3){
      RGB(rast) <- c(1, 2, 3)
      names(rast) <- c("red", "green", "blue")
   }

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

   metadata <- gdal_utils("info", source = url, quiet = T, options = "-json")
   json <- jsonlite::fromJSON(metadata)
   raw_sds <- json$metadata$SUBDATASETS

   pattern <- sprintf("LAYERS=%s&",layer)
   sd <- unlist(raw_sds[grep(pattern, raw_sds)], use.names = FALSE)

   if (is.null(sd)){
      stop(layer, " isn't a valid layer name.", call. = F)
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

#' @title modify_xml_for_png
#' @description Switch the WMS <ImageFormat> to image/png
#'
#' @param path_to_xml `character`; path to the WMS description XML
#'
#' @importFrom xml2 read_xml xml_find_first xml_text<- write_xml
#'
#' @noRd
modify_xml_for_png <- function(path_to_xml){
   doc <- read_xml(path_to_xml)
   image_format_node <- xml_find_first(doc, "//ImageFormat")
   xml_text(image_format_node) <- 'image/png'
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
generate_desc_xml <- function(sd){

   tmp_xml <- tempfile(fileext = ".xml")
   gdal_utils("translate", sd, tmp_xml, options = c("-of", "WMS"))

   return(tmp_xml)
}

#' @title safe_warp
#' @description Safe warp wrapper: try warp_wms and if a FLOAT32/jpeg
#' warning/error occurs, retry with rgb = FALSE.
#'
#' @noRd
safe_gdal_warp <- function(x, desc_xml_path, res, crs, filename, overwrite, verbose){
   is_float32_jpeg_mismatch <- function(msg) {
      grepl("FLOAT32", msg) && grepl("image/jpeg", msg)
   }
   is_jpeg_not_supported <- function(msg){
      grepl("jpeg_color_space", msg, ignore.case = T)
   }

   # Internal warp function: writes output directly to dest.
   gdal_warp <- function(x, desc_xml_path, res, crs, filename, overwrite, verbose) {

      # If caching is enabled (filename provided) and file exists, load and return it.
      caching_is_enable <- !is.null(filename) && file.exists(filename) && !overwrite
      if (caching_is_enable){
         if (verbose) message("Using cached file: ", normalizePath(filename))
         return(filename)
      }

      outfile <- if (is.null(filename)) tempfile(fileext = ".tif") else filename

      sf::gdal_utils("warp",
                     source = desc_xml_path,
                     destination = outfile ,
                     quiet = !verbose,
                     options = c(warp_options(x, crs, res, overwrite), create_options()),
                     config_options = config_options())
      return(outfile)
   }

   tryCatch(
      withCallingHandlers({
         outfile <- gdal_warp(x, desc_xml_path, res, crs, filename, overwrite, verbose)
         caching_is_enable <- !is.null(filename) && file.exists(filename) && !overwrite
         if (verbose && !caching_is_enable) message("Warp executed successfully.")
         outfile
      },
      warning = function(w) {
         msg <- conditionMessage(w)
         # If it's the FLOAT32/jpeg warning, convert it to an error for retry recursively
         if (is_float32_jpeg_mismatch(msg) || is_jpeg_not_supported(msg)) {
            stop(msg)
         }
         # If it's the specific GDAL null count warning, muffle it.
         else {
            invokeRestart("muffleWarning")
         }
      }),
      error = function(e) {
         err_msg <- conditionMessage(e)
         if (is_jpeg_not_supported(err_msg)){
            message("\nLayer likely doesn't support 'image/jpeg'. Switching to 'image/png' and retrying...")
            modify_xml_for_png(desc_xml_path)
            return(safe_gdal_warp(x, desc_xml_path, res, crs, filename, overwrite, verbose))
         } else if (is_float32_jpeg_mismatch(err_msg)) {
            message("\nDetected FLOAT32/jpeg mismatch. Retrying with rgb = FALSE...")
            modify_xml_for_float(desc_xml_path)
            return(safe_gdal_warp(x, desc_xml_path, res, crs, filename, overwrite, verbose))
         } else {
            stop("GDAL warp failed: ", err_msg)
         }
      }
   )
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

#' @title warp_options
#' @description warp options for gdal_warp
#'
#' @importFrom sf st_bbox st_crs
#'
#' @noRd
warp_options <- function(x, crs, res, overwrite){

   bb <- st_bbox(x)

   return(
      c(
         "-of", "GTIFF",
         "-te", bb$xmin, bb$ymin, bb$xmax, bb$ymax,
         "-te_srs", st_crs(x)$srid,
         "-t_srs", st_crs(crs)$srid,
         "-tr", res, res,
         "-r", "bilinear",
         if (overwrite) "-overwrite" else NULL
      )
   )
}
