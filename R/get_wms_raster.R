#' Download WMS raster layer
#'
#' Directly download a raster layer from the French National Institute
#' of Geographic and Forestry. To do that, it need a location giving by
#' a shapefile, an apikey thanks to get_apikeys() and the name of layer
#' thanks to get_layer_metadata().
#'
#' @param shape Object of class sf. Needs to be located in France.
#' @param apikey API key from get_apikey() (or directly from the website
#' https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from get_layers_metadata(apikey, "wms")
#' (or directly from the website :
#' https://geoservices.ign.fr/services-web-experts-addAPIkey)
#' @param width_height dim of the raster in pixel
#'
#' @return Spat
#' @export
#'
#' @importFrom sf st_make_valid st_transform
#' @importFrom httr modify_url
#' @importFrom magrittr `%>%`
#' @importFrom terra rast crs `crs<-`
#' @importFrom utils download.file
#'
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
   url_rgdal_option = paste0("/vsicurl_streaming/",url)
   res = rast(url_rgdal_option)
   crs(res) <- "epsg:4326"
   return(res)
}

format_bbox_wms <- function(shape = NULL) {
   bbox <- st_bbox(shape)
   paste(bbox["ymin"], bbox["xmin"], bbox["ymax"], bbox["xmax"], sep = ",")
}
