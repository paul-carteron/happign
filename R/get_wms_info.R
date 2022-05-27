#' Retrieve additional information for wms layer
#'
#' #' @usage
#' get_wms_info(shape,
#'              apikey = "ortho",
#'              layer_name = "ORTHOIMAGERY.ORTHOPHOTOS.BDORTHO",
#'              version = "1.3.0"
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wms")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param version The version of the service used. Set to latest version
#' by default.
#'
#' @return data.frame containing additional information from the layer
#'
#' @export
#'
#' @importFrom httr2 request req_perform resp_body_xml req_url_path_append
#' req_user_agent req_url_query
#' @importFrom sf st_bbox
#' @importFrom dplyr bind_rows
#' @importFrom xml2 xml_child xml_find_all xml_has_attr as_list
#'
#' @examples
#' \dontrun{
#'
#' }
#'
get_wms_info <- function(shape,
                         apikey = "ortho",
                         layer_name = "ORTHOIMAGERY.ORTHOPHOTOS.BDORTHO",
                         version = "1.3.0"){

   # test if layer is queryable
   queryable_layers <- are_queryable(apikey)
   if(!(layer_name %in% queryable_layers)){
      stop("The layer ", layer_name, " doesn't have additional information. You can try with ",
           paste(queryable_layers, collapse = ", "),
           " layers.")
   }

   bbox <- st_bbox(shape)
   bbox <- paste(bbox["ymin"], bbox["xmin"], bbox["ymax"], bbox["xmax"], sep = ",")

   request <- request("https://wxs.ign.fr") %>%
      req_url_path_append(apikey) %>%
      req_url_path_append("geoportail/r/wms") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_query(service = "WMS",
                    version = version,
                    request = "GetFeatureInfo",
                    format = "image/geotiff",
                    query_layers = layer_name,
                    layers = layer_name,
                    styles = "",
                    width = 2064,
                    height = 2064,
                    crs = "EPSG:4326",
                    bbox = bbox,
                    I = 1,
                    J = 1,
                    info_format = "text/xml") %>%
      req_perform() %>%
      resp_body_xml() %>%
      xml_child(2) %>%
      xml_child(1) %>%
      as_list()

   res <- request[!grepl("geom", names(request))] %>%
      unlist() %>%
      bind_rows()

}
#' Check if a wms layer is queryable with GetFeatureInfo
#'
#' @param apikey API key from `get_apikeys()` or directly
#' from the [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @seealso
#' [get_wms_info()]
#'
#' @examples
#' \dontrun{
#' }
#'
#' @name are_queryable
#' @return character containing the name of the queryable layers
#' @export
#'
#' @importFrom httr2 request req_perform resp_body_xml req_url_path_append
#' req_user_agent req_url_query
#' @importFrom xml2 xml_child xml_find_all xml_has_attr as_list
#'
are_queryable <- function(apikey){

   request <- request("https://wxs.ign.fr") %>%
      req_url_path_append(apikey) %>%
      req_url_path_append("geoportail/r/wms") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_query(service = "wms",
                    request = "GetCapabilities") %>%
      req_perform() %>%
      resp_body_xml() %>%
      xml_child("d1:Capability") %>%
      xml_child("d1:Layer") %>%
      xml_find_all("d1:Layer")

   queryable_layers <- request[xml_has_attr(request, "queryable")==1] %>%
      as_list() %>%
      unlist(recursive = FALSE)

   queryable_layers_names <- queryable_layers[grep("Name", names(queryable_layers))] %>%
      unlist()
}


