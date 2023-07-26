#' Download WMS raster layer
#'
#' Download a raster layer from IGN Web Mapping Services (WMS).
#' To do that, it need a location giving by a shape, an apikey
#' and the name of layer. You can find those information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' or with `get_apikeys()` and `get_layers_metadata()`.
#'
#' @usage
#' get_wms_raster(shape,
#'                apikey = "altimetrie",
#'                layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
#'                res = 25,
#'                filename = tempfile(fileext = ".tif"),
#'                crs = 2154,
#'                overwrite = FALSE,
#'                version = "1.3.0",
#'                styles = "",
#'                interactive = FALSE)
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wms")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param res Cell size in meter. See detail for more information about res.
#' @param crs Numeric, character, or object of class sf or sfc. It is set to EPSG:2154
#' by default. See [sf::st_crs()] for more detail.
#' @param filename Either a character string naming a file or a connection open
#' for writing. (ex : "test.tif" or "~/test.tif"). If `NULL`, layer_name is used.
#' Default drivers is ".tif" but all gdal drivers are supported, see details
#' for more info. To avoid re-downloads, `get_wms raster` checks that there is
#' not already a raster with that name. If it does, it is imported into R without
#' further downloading if `overwrite` is set to FALSE.
#' @param overwrite If TRUE, output raster is overwrite.
#' @param version The version of the service used. See detail for more
#' information about `version`.
#' @param styles The rendering style of the layers. Set to "" by default.
#'  See detail for more information about `styles`.
#' @param interactive If set to TRUE, no need to specify `apikey` and `layer_name`,
#' you'll be ask.
#'
#' @return
#' `get_wms_raster` return an object of class `SpatRaster` from `terra` package.
#'
#' @details
#' * Raster tile are limited to 2048x2048 pixels so depending of the shape
#' and the res, correct number of tiles to download is calculated.
#' This mean that setting the `res` argument higher than the base resolution
#' of the layer multiplies the number of pixels without increasing
#' the precision. For example, the download of the BD Alti layer from
#' IGN will be optimal for a resolution of 25m.
#' * `version` and `styles` arguments are detailed on
#' [IGN documentation](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc)
#' * Using the `crs` argument avoids post-reprojection which can be time consuming
#' * All GDAL supported drivers can be found [here](https://gdal.org/drivers/raster/index.html)
#' @export
#'
#' @importFrom terra rast
#' @importFrom sf st_crs st_make_valid st_transform
#' @importFrom utils menu
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # shape from the best town in France
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # For quick testing, use interactive = TRUE
#' raster <- get_wms_raster(shape = penmarch, interactive = TRUE)
#'
#' # For specific use, choose apikey with get_apikey() and layer_name with get_layers_metadata()
#' apikey <- get_apikeys()[4]  # altimetrie
#' metadata_table <- get_layers_metadata(apikey, "wms") # all layers for altimetrie wms
#' layer_name <- as.character(metadata_table[2,1]) # ELEVATION.ELEVATIONGRIDCOVERAGE
#'
#' # Downloading digital elevation model from IGN
#' mnt <- get_wms_raster(penmarch, apikey, layer_name, res = 25)
#'
#' # Preparing raster for plotting
#' mnt[mnt < 0] <- NA # remove negative values in case of singularity
#' names(mnt) <- "Elevation [m]" # Rename raster ie the title legend
#'
#' # Plotting result
#' tm_shape(mnt)+
#'    tm_raster(legend.show = FALSE)+
#' tm_shape(penmarch)+
#'    tm_borders(col = "blue", lwd  = 3)
#'}
get_wms_raster <- function(shape,
                           apikey = "altimetrie",
                           layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
                           res = 25,
                           filename = tempfile(fileext = ".tif"),
                           crs = 2154,
                           overwrite = FALSE,
                           version = "1.3.0",
                           styles = "",
                           interactive = FALSE) {

   # if TRUE rewrite apikey and layer_name with interactive session
   if (interactive){
      apikeys <- get_apikeys()
      apikey <- apikeys[menu(apikeys)]

      layers <- get_layers_metadata(apikey, data_type = "wms")$Name
      layer_name <- layers[menu(layers)]
   }

   # check input in another function for readability
   check_get_wms_raster_input(shape, apikey, layer_name, res, filename, crs,
                              overwrite, version, styles, interactive)

   # ensure consistency between the shape's coordinates and those requested
   shape <- st_make_valid(shape) |>
      st_transform(st_crs(crs))

   # if no filename provided layer_name is used by removing non alphanum character
   if (is.null(filename)){
      filename <- gsub("[^[:alnum:]]", "_", layer_name)
      filename <- paste0(filename, ".tif") # Save as geotiff by default
   }

   # if filename exist and overwrite is set to FALSE, raster is loaded
   if (file.exists(filename) && !overwrite) {
      rast <- rast(filename)
      message("File already exists at ", filename," therefore is loaded.\n",
          "Set overwrite to TRUE to download it again.")
   # else raster is downoaded
   }else{
      url <- build_url(apikey, layer_name)
      rast <- download_wms(shape, url, filename, res, crs, apikey)
   }

   rast <- rm_equal_layers(rast)

   return(rast)
}

#' build url for downloading
#' @param apikey zone of interest of class sf
#' @param layer_name from mother function
#' @noRd
build_url <- function(apikey, layer_name) {

   # set bbox to world by default because extent is set in warp as -te
   url <- paste0("WMS:https://wxs.ign.fr/",apikey,"/geoportail/r/wms?",
                "VERSION=1.3.0",
                "&REQUEST=GetMap",
                "&LAYERS=",layer_name,
                "&CRS=EPSG:4326",
                "&BBOX=-90,-180,90,180")
}

#' Checks if the raster is already downloaded and downloads it if necessary.
#' Also allows to download several grids
#' @param filename name of file or connection
#' @param urls urls from construct_urls
#' @param crs see st_crs()
#' @importFrom sf st_bbox gdal_utils
#' @noRd
#'
download_wms <- function(shape, url, filename, res, crs, apikey) {

   # GDAL_HTTP_UNSAFESSL is used to avoid safe SSL host / certificate verification
   # which can be problematic when using professional computer
   # GDAL_SKIP is needed for GDAL < 3.5,
   # See https://github.com/rspatial/terra/issues/828 for more
   default_gdal_skip <- Sys.getenv("GDAL_SKIP")
   default_gdal_http_unsafessl <- Sys.getenv("GDAL_HTTP_UNSAFESSL")
   Sys.setenv(GDAL_SKIP = "DODS")
   Sys.setenv(GDAL_HTTP_UNSAFESSL = "YES")
   on.exit(Sys.setenv(GDAL_SKIP = default_gdal_skip))
   on.exit(Sys.setenv(GDAL_HTTP_UNSAFESSL = default_gdal_http_unsafessl))

   bbox <- st_bbox(shape)

   tryCatch({
      gdal_utils("warp",
                 source = url,
                 destination = filename,
                 quiet = FALSE,
                 options = c("-tr", res, res, # -tr must be in the unit of the target SRS (-t_srs)
                             "-t_srs", st_crs(crs)$input, #target crs
                             "-te", bbox$xmin, bbox$ymin, bbox$xmax, bbox$ymax,
                             "-te_srs", st_crs(crs)$input,
                             "-overwrite"))
   },warning = function(w) {
      warn <- conditionMessage(w)

      # bad resolution
      if (startsWith(warn, "GDAL Error 1: Attempt")) {
         stop(warn, " Check that `res` is given in the same coordinate system as `crs`.", call. = F)
         # bad layer name
      } else if (startsWith(warn, "GDAL Error 1: GDALWMS: Unable")) {
         stop(" Check that `layer_name` is valid",  call. = F)
      }
   })

   rast <- rast(filename)
   cat("Raster is saved at :", normalizePath(filename), sep = "\n")

   return(rast)

}
