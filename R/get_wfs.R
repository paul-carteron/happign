#' Download WFS layer
#'
#' Directly download a shapefile layer from the French National Institute
#' of Geographic and Forestry. To do that, it need a location giving by
#' a shapefile, an apikey and the name of layer. You can find those
#' information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @usage
#' get_wfs(shape,
#'         apikey,
#'         layer_name)
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wfs")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @return
#' `get_wfs`return an object of class `sf`
#'
#' @export
#'
#' @importFrom sf st_bbox st_transform st_make_valid st_read st_as_sf
#' @importFrom httr modify_url GET content status_code stop_for_status
#' @importFrom dplyr select
#' @importFrom magrittr `%>%`
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # Get the borders of best town in France --------------------
#'
#' apikey <- get_apikeys()[1]
#' metadata_table <- get_layers_metadata(apikey, "wfs")
#' layer_name <- metadata_table[32,2]
#'
#' # One point from the best town in France
#' shape <- st_point(c(-4.373937, 47.79859))
#' shape <- st_sfc(shape, crs = st_crs(4326))
#'
#' # Download borders
#' borders <- get_wfs(shape, apikey, layer_name)
#'
#' # Verif
#' tmap_mode("view") # easy interactive map
#' qtm(borders, fill = NULL, borders = "firebrick") # easy map
#'
#' # Get forest_area of the best town in France ----------------
#' forest_area <- get_wfs(shape = borders,
#'                        apikey = get_apikeys()[9],
#'                        layer_name = get_layers_metadata(get_apikeys()[9], "wfs")[2,2])
#'
#' # Verif
#' qtm(forest_area, fill = "essence")
#'
#' # Get roads of the best town in France ----------------------
#' roads <- get_wfs(shape = borders,
#'                  apikey = "cartovecto",
#'                  layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route")
#'
#' # Verif
#' qtm(roads)
#' }
get_wfs <- function(shape,
                    apikey = "cartovecto",
                    layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route") {
  bbox <- NULL

  lapply_function <- function(startindex, nb_request, apikey,
                              layer_name, shape) {
    cat("Request ", startindex + 1, "/", nb_request + 1,
        " downloading...\n", sep = "")
     res <- st_read(format_url(apikey, layer_name, shape,
                               startindex = 1000 * startindex),
                    quiet = TRUE)
  }

  shape <- st_make_valid(shape) %>%
    st_transform(4326)

  resp <- GET(format_url(apikey, layer_name, shape, startindex = 0))

  stop_for_status(resp,
                  task = paste0("find resource. Check layer_name ",
                                "at https://geoservices.ign.fr/",
                                "services-web-experts-",
                                apikey))

  nb_features <- content(resp)$numberMatched

  if (nb_features == 0) {
     stop("Your search returned zero results. There is no features for ",
          layer_name,
          " inside your shape")
  }

  nb_request <- nb_features %/% 1000

  result <- lapply(
    X = 0:nb_request,
    FUN = lapply_function,
    nb_request = nb_request,
    apikey = apikey,
    layer_name = layer_name,
    shape = shape
  ) %>%
    as.data.frame() %>%
    st_as_sf() %>%
    st_make_valid() %>%
    select(-bbox)
}
#'
#' format bbox to wfs url format
#' @param shape zone of interest of class sf
#' @noRd
#'
format_bbox_wfs <- function(shape = NULL) {
  bbox <- st_bbox(shape)
  paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"], "epsg:4326",
        sep = ",")
}
#'
#' format url for request
#' @param apikey API key from IGN web service
#' @param layer_name Name of the layer from get_layer_metadata
#' @param shape Zone of interest
#' @param startindex Control number of feature (1 corresopnd to 0->1000)
#' @noRd
#'
format_url <- function(apikey = NULL, layer_name = NULL,
                       shape = NULL, startindex = NULL) {
  url <- modify_url("https://wxs.ign.fr",
    path = paste0(apikey, "/geoportail/wfs"),
    query = list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      srsName = "EPSG:4326",
      typeName = layer_name,
      bbox = format_bbox_wfs(st_transform(shape, 4326)),
      startindex = startindex
    )
  )
  url
}
