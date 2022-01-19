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
#'                resolution = NULL)
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
#' IGN will be optimal for a resolution of 25m. Look at
#' [IGN documentation](https://geoservices.ign.fr/documentation/donnees/alti/bdalti)
#' for more precision on layer's resolution.
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
#'
#' apikey <- get_apikeys()[4]
#'
#' metadata_table <- get_layers_metadata(apikey, "wms")
#' layer_name <- metadata_table[1,2]
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
#' MNT <- get_wms_raster(shape, apikey, layer_name, resolution = 25)
#'
#' # Verif
#' plot(MNT)
#' plot(shape, col = NA, add = TRUE)
#' }
get_wms_raster <- function(shape,
                           apikey = "altimetrie",
                           layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
                           resolution = NULL) {

   shape <- st_make_valid(shape) %>%
      st_transform(4326)

   width_height <- width_height(shape, resolution)

   url <- modify_url("https://wxs.ign.fr",
                     path = paste0(apikey, "/geoportail/r/wms"),
                     query = list(VERSION = "1.3.0",
                                  REQUEST = "GetMap",
                                  FORMAT = "image/geotiff",
                                  LAYERS = layer_name,
                                  STYLES = "",
                                  WIDTH = width_height[1],
                                  HEIGHT = width_height[2],
                                  CRS = "EPSG:4326",
                                  BBOX = format_bbox_wms(shape)))

   # Two options :
   # - terra::rast(url_rgdal_option) :
   #         -> faster but you can't convert itto stars after
   # - read_stars(url_rgdal_option, normalize_path = FALSE) :
   #         -> 2.46 times slower but you can use tmap

   url_rgdal_option <- paste0("/vsicurl_streaming/", url)
   res <- read_stars(url_rgdal_option, normalize_path = FALSE)

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
