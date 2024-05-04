#' @title Retrieve additional information for wms layer
#'
#' @description
#' For some wms layer more information can be found with GetFeatureInfo request.
#' This function first check if info are available. If not, available layers
#' are returned.
#'
#' @usage
#' get_location_info(x,
#'                   apikey = "ortho",
#'                   layer = "ORTHOIMAGERY.ORTHOPHOTOS",
#'                   read_sf = TRUE,
#'                   version = "1.3.0")
#'
#' @param x Object of class `sf` or `sfc`. Only single point are supported for now.
#' Needs to be located in France.
#' @param apikey `character`; API key from get_apikeys() or directly from the IGN website
#' @param layer `character`; layer name obtained from
#' `get_layers_metadata("wms-r")` or the
#' [IGN website](https://geoservices.ign.fr/services-web-experts).
#' @param read_sf `logical`; if `TRUE` an `sf` object is returned but
#' response times may be higher.
#' @param version `character`; old param
#'
#' @return `character` or `sf` containing additional information about the layer
#'
#' @export
#'
#' @importFrom httr2 request req_perform req_url_path_append req_url_query
#' req_user_agent resp_body_string
#' @importFrom sf read_sf st_bbox st_transform
#' @importFrom jsonlite toJSON parse_json
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # From single point
#' x <- st_centroid(read_sf(system.file("extdata/penmarch.shp", package = "happign")))
#' location_info <- get_location_info(x, "ortho", "ORTHOIMAGERY.ORTHOPHOTOS", read_sf = F)
#' location_info$date_vol
#'
#' # From multiple point
#' x1 <- st_sfc(st_point(c(-3.549957, 47.83396)), crs = 4326) # Carnoet forest
#' x2 <- st_sfc(st_point(c(-3.745995, 47.99296)), crs = 4326) # Coatloch forest
#'
#' forests <- lapply(list(x1, x2),
#'                   get_location_info,
#'                   apikey = "environnement",
#'                   layer = "FORETS.PUBLIQUES",
#'                   read_sf = T)
#'
#' qtm(forests[[1]]) + qtm(forests[[2]])
#'
#' # Find all queryable layers
#' queryable_layers <- lapply(get_apikeys(), are_queryable) |> unlist()
#' }
get_location_info <- function(x,
                              apikey = "ortho",
                              layer = "ORTHOIMAGERY.ORTHOPHOTOS",
                              read_sf = TRUE,
                              version = "1.3.0"){

   # check input ----
   # check parameter : x
   if (!inherits(x, c("sf", "sfc"))) {
      stop("`x` must be of class sf or sfc.", call. = F)
   }

   # check parameter : apikey
   is_apikey <- apikey %in% get_apikeys()
   if (!is_apikey) {
      stop("`apikey` must be a character from `get_apikey()`.", call. = F)
   }

   # check parameter : layer
   if (!inherits(layer, "character")) {
      stop("`layer` must be of class character.", call. = F)
   }

   # check parameter : version
   if (!inherits(version, c("character"))) {
      stop("`version` must be of class character.", call. = F)
   }
   if (!grepl("^[0-9]{1}\\.[0-9]{1}\\.[0-9]{1}$", version)) {
      stop("`version` is is badly formatted.", call. = F)
   }

   # test if layer is queryable ----
   queryable_layers <- are_queryable(apikey)

   is_queryable <- layer %in% queryable_layers
   if(!is_queryable){
      error_no_layer <- paste("No layers from apikey", apikey, "have additional information")
      error_bad_layer <- paste(layer, "layer doesn't have additional information. ",
                               "You can try with :\n",
                               paste("-", queryable_layers, collapse = "\n"))
      stop(switch(1 + is_empty(queryable_layers),
                  error_bad_layer,
                  error_no_layer), call. = F)
   }

   # build and request url ----
   # point create empty bbox so 0.001 is added to EPSG:4326 bbox
   x <- st_transform(x, 4326)

   bbox <- st_bbox(x)
   bbox <- paste(bbox["ymin"] - 0.001,
                 bbox["xmin"] - 0.001,
                 bbox["ymax"] + 0.001,
                 bbox["xmax"] + 0.001, sep = ",")

   request <- request("https://wxs.ign.fr") |>
      req_url_path_append(apikey) |>
      req_url_path_append("geoportail/r/wms") |>
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      req_url_query(service = "WMS",
                    version = version,
                    request = "GetFeatureInfo",
                    format = "image/geotiff",
                    query_layers = layer,
                    layers = layer,
                    styles = "",
                    width = 1,
                    height = 1,
                    crs = "EPSG:4326",
                    bbox = bbox,
                    I = 1,
                    J = 1,
                    info_format = "application/json") |>
      req_perform() |>
      resp_body_string()

   # 137 character mean empty response. Not pretty...
   if (nchar(request) <= 137){
      stop("No additional information found.")
   }

   if (read_sf){
      location_info <- read_sf(request)
   }else{
      location_info <- parse_json(request)$features[[1]]$properties |>
            as.data.frame()
   }

   return(location_info)

}
#' @title are_queryable
#'
#' @description
#' Check if a wms layer is queryable with GetFeatureInfo.
#'
#' @param apikey API key from `get_apikeys()` or directly
#' from the [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @seealso
#' [get_location_info()]
#'
#' @name are_queryable
#' @return `character` containing the name of the queryable layers
#' @export
#'
#' @importFrom httr2 request req_url_path_append req_user_agent req_url_query
#' req_perform resp_body_xml
#' @importFrom xml2 xml_find_all xml_text
#'
are_queryable <- function(apikey){

   request <- request("https://wxs.ign.fr") |>
      req_url_path_append(apikey) |>
      req_url_path_append("geoportail/r/wms") |>
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      req_url_query(service = "wms",
                    request = "GetCapabilities") |>
      req_perform() |>
      resp_body_xml() |>
      xml_find_all(".//d1:Layer[@queryable='1']/d1:Name") |> #xpath expression
      xml_text()

   return(request)
   # explanation of xpath
   # .// : select nodes everywhere from the current node
   # d1: : namespace of the node (use xml_ns to find them)
   # Layer : name of the node
   # [@queryable='1'] : select only node with attribut "queryable" equal to 1
   # /d1:Name : select all node under with name "Name"
}

