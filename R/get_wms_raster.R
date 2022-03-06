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
#'                apikey,
#'                layer_name,
#'                resolution = 10,
#'                filename = NULL,
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
#' @param resolution Cell size in meter. WMS are limited to 2048x2048 pixels.
#' See detail for more information about resolution.
#' @param filename File name to create on disk. If `filename` is NULL, the layer
#'  is not downloaded but a virtual connection is established. This allows to
#'  work with large areas without overloading the memory
#' @param version The version of the service used. Set to latest version
#' by default. See detail for more information about `version`.
#' @param format The output format - type-mime - of the image file. Set
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
#' * If the resolution is too high, the maximum is automatically set by
#' dividing height and width of the shape's bbox by 2048
#' (the maximum number of pixel)
#' * Setting the `resolution` parameter higher than the base resolution
#' of the layer multiplies the number of pixels without increasing
#' the precision. For example, the download of the BD Alti layer from
#' IGN will be optimal for a resolution of 25m.
#' * `version`, `format` and `styles` parameters are detailed on
#' [IGN documentation](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/images-wms-ogc)
#'
#' @export
#'
#' @importFrom sf st_make_valid st_transform st_bbox st_length st_linestring st_sfc st_make_grid
#' @importFrom httr modify_url
#' @importFrom magrittr `%>%`
#' @importFrom stars read_stars write_stars
#' @importFrom utils download.file
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
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
#' layer_name <- metadata_table[2,2]
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
#' mnt <- get_wms_raster(shape, apikey, layer_name, resolution = 1)
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
                           resolution = 10,
                           filename = NULL,
                           version = "1.3.0",
                           format = "image/geotiff",
                           styles = "") {


   shape <- st_make_valid(shape) %>%
      st_transform(4326)

   grid <- grid(shape, resolution = resolution)
   all_bbox <- lapply(grid, format_bbox_wms)
   width <- nb_pixel_bbox(grid[[1]], resolution = resolution)[1]
   height <- nb_pixel_bbox(grid[[1]], resolution = resolution)[2]

   qtm(grid) + qtm(shape)

   base_url <- modify_url("https://wxs.ign.fr",
                          path = paste0(apikey, "/geoportail/r/wms"),
                          query = list(version = version,
                                       request = "GetMap",
                                       format = format,
                                       layers = layer_name,
                                       styles = styles,
                                       width = width,
                                       height = height,
                                       crs = "EPSG:4326",
                                       bbox = ""))

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

   clean_layer_name <- sub("[^[:alnum:]]", '_' , layer_name)

   if (is.null(filename)){
      filename <- paste0(clean_layer_name,ext)
   }else{
      filename <- paste0(filename,ext)
   }

   if (filename %in% list.files()){
      raster_final <- read_stars(filename)
   }else{
      raster_list <- list()
      for (i in seq_along(urls)){

         filename_tile <- paste0("tile", i, "_", filename)

         download.file(url = urls[i],
                       method = "auto",
                       mode = "wb",
                       destfile  = filename_tile)
         raster_list[[i]] <- read_stars(filename_tile)
      }

      raster_final <- do.call("st_mosaic", raster_list)
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
nb_pixel_bbox <- function(shape, resolution = 10){
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
grid <- function(shape, resolution = 10) {

   nb_pixel_bbox <- nb_pixel_bbox(shape, resolution)
   n_tiles <- as.numeric(ceiling(nb_pixel_bbox/2048))
   grid <- st_make_grid(shape, n = n_tiles)

   invisible(grid)
}
