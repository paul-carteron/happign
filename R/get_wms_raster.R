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
#'                layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
#'                resolution = 5,
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
#' @param resolution Cell size in meter. See detail for more information about resolution.
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
#' and the resolution, correct number of tiles to download is calculated.
#' This mean that setting the `resolution` argument higher than the base resolution
#' of the layer multiplies the number of pixels without increasing
#' the precision. For example, the download of the BD Alti layer from
#' IGN will be optimal for a resolution of 25m.
#' * `version` and `styles` arguments are detailed on
#' [IGN documentation](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc)
#' * Using the `crs` argument avoids post-reprojection which can be time consuming
#' * All GDAL supported drivers can be found [here](https://gdal.org/drivers/raster/index.html)
#' @export
#'
#' @importFrom terra rast vrt writeRaster
#' @importFrom sf gdal_utils st_as_sf st_as_sfc st_axis_order st_bbox st_crs
#' st_filter st_is_longlat st_length st_linestring st_make_grid
#' st_make_valid st_set_precision st_sfc st_intersects st_transform
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
#' shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
#'                                  -4.375615, 47.79738,
#'                                  -4.375147, 47.79683,
#'                                  -4.373898, 47.79790,
#'                                  -4.373937, 47.79859),
#'                                  ncol = 2, byrow = TRUE)))
#' shape <- st_sfc(shape, crs = st_crs(4326))
#'
#' # For quick testing, use interactive = TRUE
#' raster <- get_wms_raster(shape = shape, interactive = TRUE, filename = tempfile())
#'
#' # For specific use, choose apikey with get_apikey() and layer_name with get_layers_metadata()
#' apikey <- get_apikeys()[4]  # altimetrie
#' metadata_table <- get_layers_metadata(apikey, "wms") # all layers for altimetrie wms
#' layer_name <- as.character(metadata_table[2,1]) # ELEVATION.ELEVATIONGRIDCOVERAGE
#'
#' # Downloading digital elevation model from IGN
#' mnt <- get_wms_raster(shape, apikey, layer_name, resolution = 25, filename = tempfile())
#'
#' # Preparing raster for plotting
#' mnt[mnt < 0] <- NA # remove negative values in case of singularity
#' names(mnt) <- "Elevation [m]" # Rename raster ie the title legend
#'
#' qtm(mnt)+
#' qtm(shape, fill = NULL, borders.lwd = 3)
#'}
get_wms_raster <- function(shape,
                           apikey = "altimetrie",
                           layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
                           resolution = 5,
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
   check_get_wms_raster_input(shape, apikey, layer_name, resolution, filename, crs,
                              overwrite, version, styles, interactive)

   # ensure consistency between the shape's coordinates and those requested
   shape <- st_make_valid(shape) %>%
      st_transform(st_crs(crs))

   # create needed grid because of 2048 pixel restriction
   grid_for_shp <- grid(shape,
                        resolution,
                        crs)

   # create urls
   urls <- construct_urls(grid_for_shp,
                         apikey,
                         version,
                         layer_name,
                         styles,
                         crs,
                         resolution)

   # if no filename is provide, layername is used by replacing non alphanum character
   if (is.null(filename)){
      filename <- gsub("[^[:alnum:]]", "_", layer_name)
      filename <- paste0(filename, ".tif") # Save as geotiff by default
   }

   # if filename exist and overwrite is set to FALSE, raster is imported
   if (file.exists(filename) && !overwrite) {
      raster_final <- rast(filename)
      message("File exists at ", filename," and overwrite is set to FALSE.")
   # if it's not the case download is done
   }else{
      tiles_list <- download_tiles(urls, crs)
      raster_final <- combine_tiles(tiles_list, filename, apikey)
   }
   return(raster_final)
}

#' Calculate number of pixel from bbox considering length and resolution
#' @param bbox bbox of interest of class sf
#' @param resolution cell_size in meter
#' @param crs see st_crs()
#' @noRd
nb_pixel_bbox <- function(bbox, resolution, crs){
   bbox <- st_bbox(bbox)
   height <- st_linestring(rbind(c(bbox[1], bbox[2]),
                                 c(bbox[1], bbox[4])))
   width <- st_linestring(rbind(c(bbox[1], bbox[2]),
                                c(bbox[3], bbox[2])))
   width_height <- st_length(st_sfc(list(width, height), crs = st_crs(crs)))
   nb_pixel <- as.numeric(ceiling(width_height/resolution))
   return(nb_pixel)
}

#' Create optimize grid according max width and height pixel of 2048 from bbox
#' @param shape zone of interest of class sf
#' @param resolution cell_size in meter
#' @param crs see st_crs()
#' @noRd
grid <- function(shape, resolution, crs) {
   # Avoid S2 invalid object
   on.exit(st_axis_order(F))

   shape <- st_make_valid(st_set_precision(shape, 1e6))

   nb_pixel_bbox <- nb_pixel_bbox(st_bbox(shape), resolution, crs)
   n_tiles <- as.numeric(ceiling(nb_pixel_bbox/2048))
   grid <- st_make_grid(shape, n = n_tiles) %>%
      st_as_sf() %>%
      st_filter(shape, .predicate = st_intersects)

   if(st_is_longlat(st_crs(crs))){
      st_axis_order(T)
      grid <- st_transform(grid, "CRS:84")
   }

   grid <- grid %>%
      st_as_sfc()

}

#' Create urls for download
#' @param grid shape of interest
#' @param apikey zone of interest of class sf
#' @param version cell_size in meter
#' @param layer_name from mother function
#' @param styles from mother function
#' @param width_height from width_height function
#' @param all_bbox from mother format_bbox_wms
#' @param crs see st_crs()
#' @param resolution from mother resolution
#' @noRd
construct_urls <- function(grid, apikey, version, layer_name, styles, crs, resolution) {

   #  calculate nb of pixel by bbox
   width_height <- nb_pixel_bbox(st_bbox(grid[[1]]), resolution, crs)


   base_url <- paste0("https://wxs.ign.fr/",
                     apikey,
                     "/geoportail/r/wms?",
                     "version=", version,
                     "&request=GetMap",
                     "&format=", "image/geotiff",
                     "&layers=", layer_name,
                     "&styles=", styles,
                     "&width=", width_height[1],
                     "&height=", width_height[2],
                     "&crs=", st_crs(crs)$input,
                     "&bbox=")

  format_bbox_wms <- function(shape) {
     # The bounding box coordinate values shall be in the units defined for the Layer CRS.
     # cf : 06-042_OpenGIS_Web_Map_Service_WMS_Implementation_Specification.pdf

     bbox <- st_bbox(shape)
     format_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"], sep = ",")

     return(format_bbox)
  }

  # construct url and filename
  all_bbox <- lapply(X = grid, FUN = format_bbox_wms)
  urls <- paste0(base_url, all_bbox)
}

#' Checks if the raster is already downloaded and downloads it if necessary.
#' Also allows to download several grids
#' @param filename name of file or connection
#' @param urls urls from construct_urls
#' @param crs see st_crs()
#' @noRd
#'
download_tiles <- function(urls, crs) {

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

   tiles_list <- NULL
   for (i in seq_along(urls)) {
      message(i, "/", length(urls), " downloading...", sep = "")

      # Old way of downlading raster data
      # download.file(url = urls[i],
      #               method = method,
      #               mode = mode,
      #               destfile = tmpfile)

      tmp <- tempfile(fileext = ".tif")

      # New way which allow to set crs and it also faster
      gdal_utils(util = "translate",
                 source = urls[i],
                 destination = tmp,
                 options = c("-a_srs", st_crs(crs)$input))

      tiles_list <- c(tiles_list, tmp)
   }

   return(tiles_list)
}

#' Combine tiles
#' @param tiles_list list of tiles from download_tiles
#' @param filename name of file or connection
#' @param apikey apikey from get_apikeys() for error message
#' @noRd
#'
combine_tiles <- function(tiles_list, filename, apikey) {

   # Another way of acheving the same goal
   # tmp <- tempfile(fileext = ".vrt")
   #
   # gdal_utils(
   #    util = "buildvrt",
   #    source = unlist(tiles_list),
   #    destination = tmp)
   #
   # gdal_utils(
   #    util = "translate",
   #    source = tmp,
   #    destination = filename)

   # Another way inspire from ropensci/terrainr package
   # https://github.com/ropensci/terrainr/blob/main/R/merge_rasters.R
   # gdal_utils(
   #    util = "warp",
   #    source = normalizePath(tiles_list),
   #    destination = filename)


   tryCatch({
      tiles_list <- normalizePath(tiles_list)
      writeRaster(vrt(tiles_list, overwrite = TRUE), filename)
   },error = function(cnd){
      stop("Please check that :\n",
           "- layer_name is valid by running `get_layers_metadata(\"", apikey, "\", \"wms\")[,1]`\n",
           "- styles is valid (check function description for more info)\n",
           "- version is valid (check function description for more info)\n ", call. = FALSE)
   })

   rast <- rast(filename)
   message("Raster is saved at :\n",
           normalizePath(filename))

   return(rast)

}

