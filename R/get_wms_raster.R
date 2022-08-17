#' Download WMS raster layer
#'
#' Directly download a raster layer from the French National Institute
#' of Geographic and Forestry. To do that, it need a location giving by
#' a shapefile, an apikey and the name of layer. You can find those
#' information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @usage
#' get_wms_raster(shape,
#'                apikey = "altimetrie",
#'                layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
#'                resolution = 5,
#'                filename = NULL,
#'                crs = 2154,
#'                version = "1.3.0",
#'                format = "image/geotiff",
#'                styles = "")
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wms")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param resolution Cell size in meter. WMS are limited to 2048x2048 pixels so
#' depending of the shape and the resolution, correct number and size of tiles
#' is calculated. See detail for more information about resolution.
#' @param filename Either a character string naming a file or a connection open
#' for writing. (ex : "test" or "~/test"). The resolution is automatically
#' added to the filename. If raster with same name is already downloaded it
#' is directly imported into R. You don't have to specify the extension because
#' it is defined in the argument `format`.
#' @param crs Numeric, character, or object of class sf or sfc. Is set to EPSG:4326
#' by default. See [sf::st_crs()] for more detail.
#' @param version The version of the service used. See detail for more
#' information about `version`.
#' @param format The output format of the image file. Set
#' to geotiff by default. See detail for more information about `format`.
#' @param styles The rendering style of the layers. Set to "" by default.
#'  See detail for more information about `styles`.
#'
#' @return
#' `get_wms_raster` return an object of class `stars`. Depending on the layer,
#' this can be a simple raster (2 dimensions and 1 attribute) or an RGB
#' raster (3 dimensions and 1 attribute).
#'
#' @details
#' * Setting the `resolution` parameter higher than the base resolution
#' of the layer multiplies the number of pixels without increasing
#' the precision. For example, the download of the BD Alti layer from
#' IGN will be optimal for a resolution of 25m.
#' * `version`, `format` and `styles` parameters are detailed on
#' [IGN documentation](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc)
#'
#' @export
#'
#' @importFrom magrittr `%>%`
#' @importFrom terra vrt writeRaster rast
#' @importFrom sf st_as_sf st_as_sfc st_bbox st_filter st_length st_linestring
#' st_make_grid st_make_valid st_set_precision st_sfc st_intersects st_crs
#' st_axis_order st_is_longlat gdal_utils st_transform
#' @importFrom utils download.file
#' @importFrom checkmate assert check_class assert_character assert_numeric
#' check_character check_null
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()], [download.file()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(stars)
#' library(tmap)
#'
#' apikey <- get_apikeys()[4]
#'
#' metadata_table <- get_layers_metadata(apikey, "wms")
#' layer_name <- as.character(metadata_table[2,2])
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
#' # Downloading digital elevation model from IGN
#' mnt <- get_wms_raster(shape, apikey, layer_name, resolution = 25, filename = "raster_name")
#' file.remove("raster_name_25m.tif") # Don't want to keep raster on disk
#' mnt[mnt < 0] <- NA # remove negative values in case of singularity
#' names(mnt) <- "Elevation [m]" # Rename raster ie the title legend
#'
#' # Verif
#' qtm(mnt)+
#' qtm(shape, fill = NULL, borders.lwd = 3)
#'}
get_wms_raster <- function(shape,
                           apikey = "altimetrie",
                           layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES",
                           resolution = 5,
                           filename = NULL,
                           crs = 2154,
                           version = "1.3.0",
                           format = "image/geotiff",
                           styles = "") {

   # Check input class
   assert(check_class(shape, "sf"),
          check_class(shape, "sfc"))
   assert_character(apikey)
   assert_character(layer_name)
   assert_numeric(resolution)
   assert(check_character(filename),
          check_null(filename))
   assert_character(version)
   assert_character(format)
   assert_character(styles)

   shape <- st_make_valid(shape) %>%
      st_transform(st_crs(crs))

   grid_for_shp <- grid(shape, resolution = resolution, crs = crs)
   all_bbox <- lapply(X = grid_for_shp, FUN = format_bbox_wms, crs = crs)
   width_height <- nb_pixel_bbox(grid_for_shp[[1]], resolution = resolution, crs = crs)
   urls <- construct_urls(apikey, version, format, layer_name, styles, width_height, all_bbox, crs)
   filename <- construct_filename(format, layer_name, filename, resolution)

   basename <- basename(filename)
   dirname <- dirname(filename)

   if (basename %in% list.files(dirname)) {
      raster_final <- rast(filename)
      message(
         basename,
         " already exist at :\n",
         file.path(dirname),
         "\nPlease change filename argument if you want to download it again."
      )
   }else{
      tiles_list <- download_tiles(filename, urls, crs)
      raster_final <- combine_tiles(tiles_list, filename)
   }
   return(raster_final)
}

#' format bbox to wms url format
#' @param shape zone of interest of class sf
#' @param crs see st_crs()
#' @noRd
format_bbox_wms <- function(shape, crs) {
   # The bounding box coordinate values shall be in the units defined for the Layer CRS.
   # cf : 06-042_OpenGIS_Web_Map_Service_WMS_Implementation_Specification.pdf

   # EPSG:4326 is lat/lon but WMS take long/lat so you have to use st_axis_order  = T
   # That only if coord are long/lat, else is not working

      bbox <- st_bbox(shape)
      format_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"], sep = ",")

   return(format_bbox)
}

#' Calculate number of pixel needed from resolution ad bbox
#' @param shape zone of interest of class sf
#' @param resolution cell_size in meter
#' @param crs see st_crs()
#' @noRd
nb_pixel_bbox <- function(shape, resolution, crs){
   bbox <- st_bbox(shape)
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
   # Fix S2 invalid object
   on.exit(st_axis_order(F))

   shape <- st_make_valid(st_set_precision(shape, 1e6))

   nb_pixel_bbox <- nb_pixel_bbox(shape, resolution, crs)
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

   invisible(grid)
}

#' Create urls for download
#' @param apikey zone of interest of class sf
#' @param version cell_size in meter
#' @param format from mother function
#' @param layer_name from mother function
#' @param styles from mother function
#' @param width_height from width_height function
#' @param all_bbox from mother format_bbox_wms
#' @param crs see st_crs()
#' @noRd
construct_urls <- function(apikey, version, format, layer_name, styles, width_height, all_bbox, crs) {
  base_url <- paste0("https://wxs.ign.fr/",
                     apikey,
                     "/geoportail/r/wms?",
                     "version=", version,
                     "&request=GetMap",
                     "&format=", format,
                     "&layers=", layer_name,
                     "&styles=", styles,
                     "&width=", width_height[1],
                     "&height=", width_height[2],
                     "&crs=", st_crs(crs)$input,
                     "&bbox=")

  # construct url and filename
  urls <- paste0(base_url, all_bbox)
}

#' Create filename
#' @param format from mother function
#' @param layer_name from mother function
#' @param filename from mother function
#' @param resolution from mother function
#' @noRd
construct_filename <- function(format, layer_name, filename, resolution) {
  ext <- switch(
     format,
     "image/jpeg" = ".jpg",
     "image/png" = ".png",
     "image/tiff" = ".tif",
     "image/geotiff" = ".tif",
     stop("Bad format, please check ",
          "`?get_wms_raster()`")
  )

  clean_names <- function(text){
     paste0(gsub("[^[:alnum:]]", '_', text),
            "_",
            gsub("[^[:alnum:]]", '_',resolution),
            "m", ext)
     }

  filename <- ifelse(is.null(filename),
                     clean_names(layer_name),
                     file.path(dirname(filename), clean_names(basename(filename))))
}

#' Checks if the raster is already downloaded and downloads it if necessary.
#' Also allows to download several grids
#' @param filename name of file or connection
#' @param urls urls from construct_urls
#' @param crs see st_crs()
#' @noRd
#'
# if raster_name already exist is directly load in R, else is download
download_tiles <- function(filename, urls, crs) {
   # allow 1h of downloading before error
   default <- options("timeout")
   options("timeout" = 3600)
   on.exit(options(default))

   basename <- basename(filename)
   dirname <- dirname(filename)

   tiles_list <- list()
   for (i in seq_along(urls)) {
      message(i, "/", length(urls), " downloaded", sep = "")

      filename_tile <- paste0("tile", i, "_", basename)
      path <- normalizePath(file.path(dirname, filename_tile), mustWork = FALSE)
      path <- enc2utf8(path)

      # No need for tempfile beacaus I can download directly from url with gdal_translate
      # Will see in long run

      # tmpfile <- tempfile(tmpdir = tempdir(check = T))
      #
      # download.file(url = urls[i],
      #               method = method,
      #               mode = mode,
      #               destfile = tmpfile)

      gdal_utils(
         util = "translate",
         source = urls[i],
         destination = path,
         options = c("-a_srs", st_crs(crs)$input))

      tiles_list[[i]] <- path
   }
   return(tiles_list)
}

#' Combine tiles
#' @param tiles_list list of tiles from download_tiles
#' @param filename name of file or connection
#' @noRd
#'
combine_tiles <- function(tiles_list, filename) {

   writeRaster(vrt(unlist(tiles_list), filename = "tile", overwrite=TRUE),
               normalizePath(filename), overwrite=TRUE)
   rast <- rast(normalizePath(filename))

   file.remove(
      normalizePath(
         enc2utf8(
            list.files(dirname(filename), pattern = "tile", full.names = T)
            )
         )
      )

   return(rast)

}

