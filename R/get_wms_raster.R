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
#'                layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
#'                resolution = 25,
#'                filename = NULL,
#'                version = "1.3.0",
#'                format = "image/geotiff",
#'                styles = "",
#'                method = "auto",
#'                mode = "wb")
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
#' @param filename Name of raster download to disk. The resolution is automatically
#'  added to the filename. If raster with same name already exist in the current
#'  directory, it is directly imported into R
#' @param version The version of the service used. Set to latest version
#' by default. See detail for more information about `version`.
#' @param format The output format - type-mime - of the image file. Set
#' to geotiff by default. See detail for more information about `format`.
#' @param styles The rendering style of the layers. Set to "" by default.
#'  See detail for more information about `styles`.
#' @param method Method to be used for downloading files. See [download.file()]
#' for more detail.
#' @param mode The mode with which to write the file. See [download.file()]
#' for more detail.
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
#' @importFrom httr modify_url
#' @importFrom magrittr `%>%`
#' @importFrom stars read_stars write_stars st_mosaic st_warp
#' @importFrom sf st_as_sf st_as_sfc st_bbox st_filter st_length st_linestring
#' st_make_grid st_make_valid st_set_precision st_sfc st_intersects
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
#' layer_name <- metadata_table[2,2][[1]]
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
#' mnt[mnt < 0] <- NA # remove negative values in case of singularity
#' names(mnt) <- "Elevation [m]" # Rename raster ie the title legend
#'
#' # Verif
#' qtm(mnt)+
#' qtm(shape, fill = NULL, borders.lwd = 3)
#'}
get_wms_raster <- function(shape,
                           apikey = "altimetrie",
                           layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
                           resolution = 25,
                           filename = NULL,
                           version = "1.3.0",
                           format = "image/geotiff",
                           styles = "",
                           method = "auto",
                           mode = "wb") {

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
   assert_character(method)
   assert_character(mode)

   shape <- st_make_valid(shape) %>%
      st_transform(4326)

   grid <- grid(shape, resolution = resolution)
   all_bbox <- lapply(grid, format_bbox_wms)
   width_height <- nb_pixel_bbox(grid[[1]], resolution = resolution)

   base_url <- modify_url("https://wxs.ign.fr",
                          path = paste0(apikey, "/geoportail/r/wms"),
                          query = list(version = version,
                                       request = "GetMap",
                                       format = format,
                                       layers = layer_name,
                                       styles = styles,
                                       width = width_height[1],
                                       height = width_height[2],
                                       crs = "EPSG:4326",
                                       bbox = ""))

   # construct url and filename
   urls <- paste0(base_url, all_bbox)

   ext <- switch(
      format,
      "image/jpeg" = ".jpg",
      "image/png" = ".png",
      "image/tiff" = ".tif",
      "image/geotiff" = ".tif",
      stop("Bad format, please check ",
           "`?get_wms_raster()`")
   )

   clean_names <- paste0(gsub("[^[:alnum:]]", '_', c(layer_name, filename)),
                         "_",
                         gsub("[^[:alnum:]]", '_',resolution),
                         "m", ext)

   filename <- ifelse(is.null(filename), clean_names[1], clean_names[2])

   # if raster_name already exist is directly load in R, else is download
   if (filename %in% list.files()){
      raster_final <- read_stars(filename)
      message(filename, " already exist at :\n", getwd(), "\nPlease change filename argument if you want to download it again.")
   }else{
      raster_list <- list()
      for (i in seq_along(urls)){

         cat(i,"/",length(urls), " downloaded\n", sep = "")

         filename_tile <- paste0("tile", i, "_", filename)

         download.file(url = urls[i],
                       method = method,
                       mode = mode,
                       destfile  = filename_tile)
         raster_list[[i]] <- read_stars(filename_tile)
      }

      # cf ?st_transform, detail. st_transform convert lossless by into curvilinear grid with is
      # not handle by terra
      raster_final <- lapply(X = raster_list,
                     FUN = st_warp,
                     crs =  st_crs(4326))

      raster_final <- do.call("st_mosaic", raster_final)
      file.remove(paste0("tile", seq_along(urls), "_", filename))

      write_stars(raster_final, filename)

   }

   return(raster_final)
}
#'
#' format bbox to wms url format
#' @param shape zone of interest of class sf
#' @noRd
#'
format_bbox_wms <- function(shape = NULL) {
   bbox <- st_bbox(shape)
   paste(bbox["ymin"], bbox["xmin"], bbox["ymax"], bbox["xmax"], sep = ",")
}
#'
#' Calculate number of pixel needed from resolution ad bbox
#' @param shape zone of interest of class sf
#' @param resolution cell_size in meter
#' @noRd
#'
nb_pixel_bbox <- function(shape, resolution){
   bbox <- st_bbox(shape)
   height <- st_linestring(rbind(c(bbox[1], bbox[2]),
                                 c(bbox[1], bbox[4])))
   width <- st_linestring(rbind(c(bbox[1], bbox[2]),
                                c(bbox[3], bbox[2])))
   width_height <- st_length(st_sfc(list(width, height), crs = 4326))
   nb_pixel <- as.numeric(ceiling(width_height/resolution))
   return(nb_pixel)
}
#' Create optimize grid according max width and height pixel of 2048 from bbox
#' @param shape zone of interest of class sf
#' @param resolution cell_size in meter
#' @noRd
#'
grid <- function(shape, resolution) {
   # Fix S2 invalid object
   shape <- st_make_valid(st_set_precision(shape, 1e6))

   nb_pixel_bbox <- nb_pixel_bbox(shape, resolution)
   n_tiles <- as.numeric(ceiling(nb_pixel_bbox/2048))
   grid <- st_make_grid(shape, n = n_tiles) %>%
      st_as_sf() %>%
      st_filter(shape, .predicate = st_intersects) %>%
      st_as_sfc()

   invisible(grid)
}
