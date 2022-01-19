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
#'
#' apikey <- get_apikeys()[4]
#' metadata_table <- get_layers_metadata(apikey, "wms")
#' all_layer_name <- metadata_table$name
#' abstract_of_MNT <- metadata_table[1,3]
#' crs_of_MNT <- unlist(metadata_table[1,4])
#'
#' # list with every wfs metadata
#' list_metadata = lapply(X = get_apikeys(),
#'                        FUN = get_layers_metadata,
#'                        data_type = "wfs")
#'
#' # Convert list to one single data.frame
#' all_metadata = dplyr::bind_rows(list_metadata)
#' }
#'
#' @name get_layers_metadata
#' @return data.frame with name of layer, abstract and crs
#' @export
#'
#' @importFrom dplyr mutate select rename_all
#' @importFrom tidyr pivot_wider unnest
#' @importFrom xml2 read_xml xml_child xml_children xml_find_all
#' xml_name xml_text
#' @importFrom stringr str_remove
#'
get_layers_metadata <- function(apikey, data_type) {
   UseMethod("get_layers_metadata")
}

#' @name get_layers_metadata
#' @export
get_layers_metadata.character <- function(apikey, data_type) {
   get_layers_metadata(constructor(apikey, data_type))
   }

#' @name get_layers_metadata
#' @export
get_layers_metadata.wfs <- function(apikey, data_type) {
   url <- paste0("https://wxs.ign.fr/",
                apikey,
                "/geoportail/wfs?SERVICE=WFS&REQUEST=GetCapabilities")

   resp <- GET(url)

   items <- read_xml(resp) %>%
      xml_child("d1:FeatureTypeList") %>%
      xml_children()

   abstract <- defaultcrs <- NULL

   res <- xml_to_df(items) %>%
      select("Keywords", "Name", "Abstract", "DefaultCRS") %>%
      rename_all(tolower) %>%
      mutate(abstract = gsub("<.*?>", "", abstract),
             defaultcrs = str_remove(defaultcrs, "urn:ogc:def:crs:"))

   res

}

#' @name get_layers_metadata
#' @export
get_layers_metadata.wms <- function(apikey, data_type) {

   url <- paste0("https://wxs.ign.fr/",
                apikey,
                "/geoportail/r/wms?SERVICE=WMS&REQUEST=GetCapabilities")

   resp <- GET(url)

   items <- read_xml(resp) %>%
      xml_child("d1:Capability") %>%
      xml_child("d1:Layer") %>%
      xml_find_all("d1:Layer")

   res <- suppressWarnings(xml_to_df(items, values_fn = list)) %>%
      select("KeywordList", "Name", "Abstract", "CRS") %>%
      rename_all(tolower) %>%
      unnest(1:3)
   res

}
#' Constructor for class data_type
#' @param apikey API key from IGN web service
#' @param data_type "wfs" or "wms"
#' @noRd
#'
constructor <- function(apikey, data_type) {
   if (!is.character(apikey)) stop("apikey must be character")
   if (!is.character(data_type)) stop("data_type must be character")
   if (!(apikey %in% get_apikeys())) stop("apikey must be one of :\n",
                                         paste(get_apikeys(), collapse = ", "))
   if (!(data_type == "wfs" | data_type == "wms")) {
      stop("data_type must be \"wms\" or \"wfs\"")
   }
   structure(list(apikey), class = data_type)
}
#' Convert xml to data.frame
#' @param xml_nodeset Response from httr::GET request
#' @noRd
#'
xml_to_df <- function(xml_nodeset, ...) {

   nodenames <- xml_name(xml_children(xml_nodeset))
   contents <- trimws(xml_text(xml_children(xml_nodeset)))

   #Need to create an index to associate the nodes/contents with each item
   itemindex <- rep(seq_len(length(xml_nodeset)),
                    times = sapply(xml_nodeset,
                                 function(x) {
                                    length(xml_children(x))
                                    }))

   #store all information in data frame.
   df <- data.frame(itemindex, nodenames, contents)

   res <-  pivot_wider(df, id_cols = itemindex, names_from = nodenames,
                       values_from = contents)
}
