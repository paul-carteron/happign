#' @title Download WMS raster layer
#'
#' @description
#' Download a raster layer from IGN Web Mapping Services (WMS).
#' To do that, it need a location giving by a shape, an apikey
#' and the name of layer. You can find those information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' or with `get_apikeys()` and `get_layers_metadata()`.
#'
#' @usage
#' get_wms_raster(x,
#'                apikey = "altimetrie",
#'                layer = "ELEVATION.ELEVATIONGRIDCOVERAGE",
#'                res = 25,
#'                filename = tempfile(fileext = ".tif"),
#'                crs = 2154,
#'                overwrite = FALSE,
#'                version = "1.3.0",
#'                styles = "",
#'                interactive = FALSE)
#'
#' @param x Object of class `sf` or `sfc`. Needs to be located in
#' France.
#' @param apikey `character`; API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param layer `character`; layer name from
#' `get_layers_metadata(apikey, "wms")` or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param res `numeric`; resolution in the unit of the coordinate system
#' (e.g. meter for 2154). See detail for more information about `res`.
#' @param crs `numeric`, `character`, or object of class `sf` or `sfc`.
#' It is set to EPSG:2154 by default. See [sf::st_crs()] for more detail.
#' @param filename `character` or `NULL`; filename or a open connection for
#' writing. (ex : "test.tif" or "~/test.tif"). If `NULL`, `layer` is used as
#' filename. Default drivers is ".tif" but all gdal drivers are supported,
#' see details for more info.
#' @param overwrite If TRUE, output raster is overwrite.
#' @param version `character`; version of the service used. See details
#' for more info.
#' @param styles `character`; rendering style of the layer. Set to ""
#' by default. See details for more info.
#' @param interactive `logical`; If TRUE, interactive menu ask for
#' `apikey` and `layer`.
#'
#' @return
#' `SpatRaster` object from `terra` package.
#'
#' @details
#' * `res` : Warning, setting `res` higher than default layer resolution
#' multiplies the number of pixels without increasing
#' the precision. For example, the download of the BD Alti layer from
#' IGN will be optimal for a resolution of 25m.
#' * `version` and `styles` arguments are detailed on
#' [IGN documentation](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc)
#' * `filename` : All GDAL supported drivers can be found
#' [here](https://gdal.org/drivers/raster/index.html)
#' * `overwrite` : `get_wms raster` always checks that `filename` does not
#' already exist. If it does, it is imported into R without further downloading
#' unless `overwrite` is set to `TRUE`.
#'
#' @importFrom terra rast
#' @importFrom sf st_crs st_make_valid st_transform
#' @importFrom utils menu
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
#'
#' @export
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
#' raster <- get_wms_raster(x = penmarch, interactive = TRUE)
#'
#' # For specific use, choose apikey with get_apikey() and layer name with get_layers_metadata()
#' apikey <- get_apikeys()[4]  # altimetrie
#' metadata_table <- get_layers_metadata(apikey, "wms") # all layers for altimetrie wms
#' layer <- metadata_table[2,1] # ELEVATION.ELEVATIONGRIDCOVERAGE
#'
#' # Downloading digital elevation model from IGN
#' mnt_2154 <- get_wms_raster(penmarch, apikey, layer, res = 25)
#'
#' # If crs is set to 4326, res is in degrees
#' mnt_4326 <- get_wms_raster(penmarch, apikey, layer, res = 0.0005, crs = 4326)
#'
#' # Plotting result
#' tm_shape(mnt_4326)+
#'    tm_raster()+
#' tm_shape(penmarch)+
#'    tm_borders(col = "blue", lwd  = 3)
#'}
get_wms_raster <- function(x,
                           apikey = "altimetrie",
                           layer = "ELEVATION.ELEVATIONGRIDCOVERAGE",
                           res = 25,
                           filename = tempfile(fileext = ".tif"),
                           crs = 2154,
                           overwrite = FALSE,
                           version = "1.3.0",
                           styles = "",
                           interactive = FALSE) {

   # if TRUE menu ask for apikey and layer name
   if (interactive){
      apikeys <- get_apikeys()
      apikey <- apikeys[menu(apikeys)]

      layers <- get_layers_metadata(apikey, data_type = "wms")$Name
      layer <- layers[menu(layers)]
   }

   # check input in another function for readability
   check_get_wms_raster_input(x, apikey, layer, res, filename, crs,
                              overwrite, version, styles, interactive)

   # ensure consistency between the shape's coordinates and those requested
   x <- st_make_valid(x) |>
      st_transform(st_crs(crs))

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
   # else raster is downoaded
   }else{
      url <- build_url(apikey, layer)
      rast <- download_wms(x, url, filename, res, crs, apikey)
   }

   rast <- rm_equal_layers(rast)

   return(rast)
}

#' @title build_url
#' @description Build url for downloading.
#'
#' @param apikey `character`; from `get_apikey()`
#' @param layer `character`; from `get_layers_metadata()`
#'
#' @noRd
build_url <- function(apikey, layer) {

   # set bbox to world by default because extent is set in warp as -te
   url <- paste0("WMS:https://wxs.ign.fr/",apikey,"/geoportail/r/wms?",
                "VERSION=1.3.0",
                "&REQUEST=GetMap",
                "&LAYERS=",layer,
                "&CRS=EPSG:4326",
                "&BBOX=-90,-180,90,180")
}

#' @title download_wms
#' @description Download of raster with gdalwarp.
#'
#' @param filename name of file or connection
#' @param url `character`; url from build_url
#' @param crs see st_crs()
#'
#' @importFrom sf st_bbox gdal_utils
#'
#' @noRd
#'
download_wms <- function(x, url, filename, res, crs, apikey) {

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

   bbox <- st_bbox(x)

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
         stop(" Check that `layer` is valid",  call. = F)
      }
   })

   rast <- rast(filename)
   cat("Raster is saved at :", normalizePath(filename), sep = "\n")

   return(rast)

}
