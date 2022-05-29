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
#'         layer_name,
#'         filename = NULL)
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wfs")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param filename Either a character string naming a file or a connection open
#' for writing.
#'
#' @return
#' `get_wfs`return an object of class `sf`
#'
#' @export
#'
#' @importFrom sf read_sf st_bbox st_make_valid st_transform st_write
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent
#' request resp_body_json resp_body_string
#' @importFrom dplyr bind_rows select
#' @importFrom magrittr `%>%`
#' @importFrom checkmate assert check_class check_character check_null check_double
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
#' borders <- get_wfs(shape, apikey, layer_name, filename = file.path(tempdir(), "borders"))
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
                    layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route",
                    filename = NULL){

   assert(check_class(shape, "sf"),
          check_class(shape, "sfc"))
   check_character(apikey, max.len = 1)
   check_character(layer_name, max.len = 1)
   assert(check_character(filename, max.len = 1),
          check_null(filename))

   bbox <- NULL
   shape <- st_make_valid(shape)

   req <- req_function(apikey, shape, layer_name)
   features <- read_sf(resp_body_string(req))
   request_need <- resp_body_json(req)$totalFeatures %/% 1000
   message("1/",request_need + 1," downloaded")

   if (request_need != 0) {
      list_features <- lapply(seq_len(request_need),
                              \(x) {
                                 features <- req_function(
                                              apikey,
                                              shape,
                                              layer_name,
                                              x * 1000) %>%
                                    resp_body_string() %>%
                                    read_sf()
                                 message(x + 1, "/", request_need + 1, " downloaded")
                                 return(features)
                              })
      features <- bind_rows(features, list_features)
   }

   if ("bbox" %in% names(features)){
      features <- select(features, -"bbox")
   }

   if (!is.null(filename)) {
      st_write(features, file.path(paste0(filename, ".shp")))
      message("The shape is saved at : ", file.path(getwd(),
                                                    paste0(filename, ".shp")))
      }

  return(features)
}

#' format url and request it
#' @param apikey API key from `get_apikeys()`
#' @param shape Object of class `sf`. Needs to be located in France.
#' @param layer_name Name of the layer
#' @param startindex startindex for features returned limit
#' @noRd
#'
req_function <- function(apikey, shape, layer_name, startindex = 0) {

   check_character(apikey, max.len = 1)
   assert(check_class(shape, "sf"),
          check_class(shape, "sfc"))
   check_character(layer_name, max.len = 1)
   check_double(startindex)

   bbox <- st_bbox(st_transform(shape, 4326))
   formated_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          "epsg:4326",
                          sep = ",")

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      srsName = "EPSG:4326",
      typeName = layer_name,
      bbox = formated_bbox,
      startindex = startindex,
      count = 1000
   )

   request <- request("https://wxs.ign.fr") %>%
      req_url_path_append(apikey) %>%
      req_url_path_append("geoportail/wfs") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_query(!!!params) %>%
      req_perform()
}
