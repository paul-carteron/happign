#' Metadata for one couple of apikey and data_type
#'
#' Metadata are retrieved using the IGN APIs. The execution time can
#' be long depending on the size of the metadata associated with
#' the API key and the overload of the IGN servers.
#'
#' @param apikey API key from `get_apikeys()` or directly
#' from the [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param data_type Should be `"wfs"` or `"wms"`. See details for more
#' information about these two Webservice formats.
#'
#' @details
#' * WFS is a standard protocol defined by the OGC (Open Geospatial Consortium)
#' and recognized by an ISO standard. The reference document is available
#' on the [OGC website](https://www.ogc.org/standards/wfs). The Geoportail
#' WFS service implements version 2.0 of this protocol. The WFS service
#' of Geoportail gives access to objects from different IGN databases:
#' BD TOPO®, BD CARTO®, BD ADRESSE®, BD FORET® or PARCELLAIRE EXPRESS (PCI).
#'
#' * WMS is a standard protocol defined by the OGC
#' (Open Geospatial Consortium) and recognized by an ISO standard.
#' The reference document is available on the
#' [OGC website](https://www.ogc.org/standards/wms).
#'
#' * For further more detail, check [IGN documentation page](https://geoservices.ign.fr/documentation/services/api-et-services-ogc)
#'
#' @seealso
#' [get_apikeys()]
#'
#' @examples
#' \dontrun{
#' apikey <- get_apikeys()[4]
#' metadata_table <- get_layers_metadata(apikey, "wms")
#' all_layer_name <- metadata_table$name
#' abstract_of_MNT <- metadata_table[1,"abstract"]
#'
#' # list with every wfs metadata (warning : it's quite long)
#' list_metadata <- lapply(X = get_apikeys(),
#'                        FUN = get_layers_metadata,
#'                        data_type = "wfs")
#'
#' # Convert list to one single data.frame
#' all_metadata <- dplyr::bind_rows(list_metadata)
#' }
#'
#' @name get_layers_metadata
#' @return data.frame
#' @export
#'
#' @importFrom httr2 req_perform req_url_path req_url_query request resp_body_xml
#' @importFrom xml2 as_list xml_child xml_children xml_find_all
#'
get_layers_metadata <- function(apikey,
                                data_type) {

   match.arg(data_type, c("wms", "wfs"))
   match.arg(apikey, get_apikeys())

   version <- switch(data_type,
                     "wms" = "1.3.0",
                     "wfs" = "2.0.0")

   path <- switch(data_type,
                  "wms" = "r",
                  "wfs" = "")

   req <- request("https://wxs.ign.fr/") %>%
      req_url_path(apikey,"geoportail", path, data_type) %>%
      req_url_query(service = data_type,
                    version = version,
                    request = "GetCapabilities") %>%
      req_perform() %>%
      resp_body_xml()

   raw_metadata <- switch(data_type,
                          "wms" = xml_child(req, "d1:Capability") %>% xml_child("d1:Layer") %>%
                             xml_find_all("d1:Layer"),
                          "wfs" = xml_child(req, "d1:FeatureTypeList") %>% xml_children())

   tryCatch({
      clean_metadata <- suppressWarnings(
      as.data.frame(do.call(rbind, as_list(raw_metadata)))[, 1:3])
      clean_metadata <-
      as.data.frame(apply(clean_metadata, c(1, 2), unlist))
   },
   error = function(cond){
      message("There's no ", data_type, " resources for apikey ", apikey)
   })
}

