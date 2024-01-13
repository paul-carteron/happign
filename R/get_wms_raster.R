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
#' @importFrom sf st_crs st_make_valid st_transform st_is_longlat
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
#' # Shape from the best town in France
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # For quick testing use interactive = TRUE
#' raster <- get_wms_raster(x = penmarch, interactive = TRUE)
#'
#' # For specific data, choose apikey with get_apikey() and layer with get_layers_metadata()
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

   # interactive mode ----
   # if TRUE menu ask for apikey and layer name
   if (interactive){
      choice <- interactive_mode()
      apikey <- choice$apikey
      layer <- choice$layer
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

   # else raster is downloaded
   }else{
      grid <- create_grid(x, res)

      base_url <- paste0("https://wxs.ign.fr/", apikey, "/geoportail/r/wms?",
                         "version=", "1.3.0",
                         "&request=GetMap",
                         "&layers=", layer,
                         "&styles=", "",
                         "&format=image/geotiff",
                         "&crs=", st_crs(grid)$srid)
      urls <- create_urls(grid, base_url, res)

      rast <- download_wms(urls, crs, filename, overwrite)
   }

   return(rast)
}

#' @title bbox_dim
#' @description calculate bbox length of a shape in meter
#'
#' @param x Object of class `sf` or `sfc`. Needs to be located in
#' France.
#'
#' @importFrom sf st_bbox st_linestring st_length st_sfc st_crs
#'
#' @noRd
bbox_dim <- function(x){

   if (!inherits(x, c("sf", "sfc"))) {
      stop("`x` must be of class sf or sfc.", call. = F)
   }

   bb <- st_bbox(x)

   width <- st_linestring(rbind(c(bb$xmin, bb$ymin), c(bb$xmax, bb$ymin)))
   height <- st_linestring(rbind(c(bb$xmin, bb$ymin), c(bb$xmin, bb$ymax)))

   width_height <- st_length(st_sfc(list(width, height), crs = st_crs(x))) |>
      as.numeric() |>
      setNames(c("width", "height"))


   return(width_height)
}

#' @title create_grid
#' @description create grid from shape and res to avoid 2048 pixel limitation
#'
#' @param x Object of class `sf` or `sfc`. Needs to be located in
#' France.
#' @param res `numeric`; resolution of final raster in meter
#' @param pixels_limit `numeric`; pixel limitation of WIGN Web service
#'
#' @importFrom sf st_make_grid st_as_sf st_filter
#'
#' @noRd
create_grid <- function(x, res, pixels_limit = 2048){

   # shape <- st_make_valid(st_set_precision(shape, 1e6))

   nb_cells <- ceiling(bbox_dim(x)/res/pixels_limit)

   grid <- st_make_grid(x, n = nb_cells) |>
      st_as_sf() |>
      st_filter(x, .predicate = st_intersects)

   return(grid)

}

#' @title create_urls
#' @description creates urls for downloading tile.
#'
#' @param x Object of class `sf` or `sfc`.
#' @param base_url `character`; base url for https wms request
#' @param res `numeric`; resolution of final raster in meter.
#'
#' @importFrom sf st_geometry st_as_sfc st_bbox
#' @importFrom stats setNames
#'
#' @noRd
create_urls <- function(x, base_url, res){

   if (!inherits(x, c("sf", "sfc"))) {
      stop("`x` must be of class sf or sfc.", call. = F)
   }

   if (!inherits(res, c("numeric"))) {
      stop("`res` must be of class numeric.", call. = F)
   }

   is_longlat <- st_is_longlat(x)
   dims <- bbox_dim(st_geometry(x)[1])/res

   bboxs <- lapply(st_as_sfc(x), st_bbox) |>
      # If longlat is TRUE bbox order is different, I don't understand...
      lapply(\(x) ifelse(is_longlat,
                         paste(x$ymin, x$xmin, x$ymax, x$xmax, sep=","),
                         paste(x$xmin, x$ymin, x$xmax, x$ymax, sep=",")))

   urls <- paste0(base_url,
                  "&bbox=", bboxs,
                  "&width=", dims["width"],
                  "&height=", dims["height"])
   return(urls)
}


#' @title download_wms
#' @description Download of raster with gdalwarp.
#'
#' @param urls `character`; urls from create_url
#' @param crs see st_crs()
#' @param filename `character` or `NULL`; filename or a open connection for
#' writing
#' @param overwrite If TRUE, output raster is overwrite.
#'
#' @importFrom sf gdal_utils
#' @importFrom terra rast
#'
#' @noRd
download_wms <- function(urls, crs, filename, overwrite) {

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

   tryCatch({
      tmp_vrt <- tempfile(fileext = ".vrt")
      gdal_utils("buildvrt",
                 source = paste0(urls),
                 destination = tmp_vrt,
                 quiet = FALSE,
                 options = c(if (overwrite) "-overwrite" else ""))

      gdal_utils("warp",
                 source = tmp_vrt,
                 destination = filename,
                 quiet = FALSE,
                 options = c("-t_srs", st_crs(crs)$input,
                             if (overwrite) "-overwrite" else ""))
   },warning = function(w) {
      warn <- conditionMessage(w)

      # bad resolution
      if (startsWith(warn, "GDAL Error 1")) {
         stop(" Check that `layer` is valid",  call. = F)
      }
   })

   rast <- rast(filename)
   cat("Raster is saved at :", normalizePath(filename), sep = "\n")

   return(rast)

}
