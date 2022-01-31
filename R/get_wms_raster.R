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
#' @importFrom sf st_make_valid st_transform st_linestring st_length st_sfc
#' @importFrom httr modify_url
#' @importFrom magrittr `%>%`
#' @importFrom stars read_stars
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

   width_height <- width_height(shape, resolution)

   url <- modify_url("https://wxs.ign.fr",
                     path = paste0(apikey, "/geoportail/r/wms"),
                     query = list(version = version,
                                  request = "GetMap",
                                  format = format,
                                  layers = layer_name,
                                  styles = styles,
                                  width = width_height[1],
                                  height = width_height[2],
                                  crs = "EPSG:4326",
                                  bbox = format_bbox_wms(shape)))

   if (is.null(filename)) {
      url_rgdal_option <- paste0("/vsicurl/", url)
      res <- try(read_stars(url_rgdal_option, normalize_path = FALSE),
                 silent = TRUE)

      if (grepl("Error", as.character(res), fixed = TRUE)) {
         stop("\n   1. Please check that ", layer_name,
              " exists at shape location\n",
              "   2. If yes, rgal does not support this resource. ",
              "To overcome this, you must save the resource ,",
              "by using the filename argument.: \n")
      }
   }else{

      filename <- paste0(filename,
                           switch(
                              format,
                              "image/jpeg" = ".jpg",
                              "image/png" = ".png",
                              "image/tiff" = ".tif",
                              "image/geotiff" = ".tif",
                              stop("Bad format, please check ",
                                   "`?get_wms_raster()`")
                           ))

      download.file(url = url,
                    method = "auto",
                    mode = "wb",
                    destfile = filename)
   message("The layer is saved at : ", file.path(getwd(), filename))
      res <- read_stars(filename)
   }
   return(res)
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
#' Do all calculation to find optimal - or not - cell_size from bbox
#' @param shape zone of interest of class sf
#' @param resolution cell_size in meter
#' @noRd
#'
width_height <- function(shape, resolution = NULL) {

   bbox <- st_bbox(shape)
   width <- st_linestring(rbind(c(bbox[1], bbox[2]),
                               c(bbox[1], bbox[4])))
   height <- st_linestring(rbind(c(bbox[1], bbox[2]),
                                c(bbox[3], bbox[2])))

   width_height <- st_length(st_sfc(list(width, height), crs = 4326))
   names(width_height) <- c("width", "height")
   nb_pixel <-  c(2048, 2048)

   if (!is.null(resolution)) {
      nb_pixel <- as.numeric(ceiling(width_height / resolution))
      nb_pixel <- ifelse(nb_pixel > 2048, 2048, nb_pixel)
   }

   resolution <- width_height / nb_pixel

   if (sum(nb_pixel == 2048) >= 1) {
      message("The resolution is too high (or set to NULL) so the ",
              "maximum resolution is used. Reducing the resolution ",
              "allows to speed up calculations on raster.")
   }

   message(paste(c("x", "\ny"), "cell_size :", round(resolution, 3), "[m]"))

   invisible(nb_pixel)
}
