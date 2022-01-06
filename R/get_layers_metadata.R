#' Metadata for one couple of apikey and data_type
#'
#' Metadata are retrieved using the IGN APIs. The execution time can
#' be long depending on the size of the metadata associated with
#' the apikey and the overload of the IGN servers.
#'
#' @param apikey Apikey from get_apikeys()
#' @param data_type Should be "wfs" or "wms
#'
#' @return data.frame with all useful metadata
#' @name get_layers_metadata
#' @export
#'
#' @importFrom dplyr mutate select rename_all
#' @importFrom tidyr pivot_wider unnest
#' @importFrom xml2 read_xml xml_child xml_children xml_find_all
#' xml_name xml_text
#' @importFrom stringr str_remove
#'
#' @examples
#' \dontrun{
#' get_layers_metadata("administratif", "wms")
#' }
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
