#' Download WMS raster layer
#'
#' Directly download a raster layer from the French National Institute
#' of Geographic and Forestry. To do that, it need a location giving by
#' a shapefile, an apikey and the name of layer. You can find those
#' information from
#' [IGN website](https://geoservices.ign.fr/services-web-expert)
#'
#' @usage
#' get_wms_raster(shape,
#'                apikey,
#'                layer_name,
#'                width_height = 500)
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wms")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param width_height Dim of the raster in pixel
#'
#' @export
#'
#' @importFrom sf st_make_valid st_transform
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
#' library(terra)
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
#' MNT <- get_wms_raster(shape, apikey, layer_name)
#'
#' # Verif
#' plot(MNT)
#' plot(shape, col = NA, add = TRUE)
#' }
get_wms_raster <- function(shape,
                         apikey = "altimetrie",
                         layer_name = "ELEVATION.ELEVATIONGRIDCOVERAGE",
                         width_height = 500) {

   shape <- st_make_valid(shape) %>%
      st_transform(4326)

   url <- modify_url("https://wxs.ign.fr",
                     path = paste0(apikey, "/geoportail/r/wms"),
                     query = list(VERSION = "1.3.0",
                                  REQUEST = "GetMap",
                                  FORMAT = "image/geotiff",
                                  LAYERS = layer_name,
                                  STYLES = "",
                                  WIDTH = width_height,
                                  HEIGHT = width_height,
                                  CRS = "EPSG:4326",
                                  BBOX = format_bbox_wms(shape)))

   # Two options :
   # - terra::rast(url_rgdal_option) :
   #         -> faster but you can't convert itto stars after
   # - read_stars(url_rgdal_option, normalize_path = FALSE) :
   #         -> 2.46 times slower but you can cuse tmap

   url_rgdal_option <- paste0("/vsicurl_streaming/", url)

   res <- read_stars(url_rgdal_option, normalize_path = FALSE)
   return(res)
}

format_bbox_wms <- function(shape = NULL) {
   bbox <- st_bbox(shape)
   paste(bbox["ymin"], bbox["xmin"], bbox["ymax"], bbox["xmax"], sep = ",")
}
