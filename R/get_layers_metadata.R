#' @title Metadata for one couple of apikey and data_type
#'
#' @description
#' Metadata are retrieved using the IGN APIs. The execution time can
#' be long depending on the size of the metadata associated with
#' the API key and the overload of the IGN servers.
#'
#' @usage
#' get_layers_metadata(data_type)
#'
#' @param data_type Should be `"wfs"`, `"wms-r"` or `"wmts"`. See details for more
#' information about these Web services formats.
#'
#' @details
#' * `"wfs"` : Web Feature Service designed to return data in vector format (line, point, polygon, ...)
#' * `"wms-r"` : Web Map Service focuses on raster data
#' * `"wmts"` : Web Map Tile Service is similar to WMS, but instead of serving maps
#' as single images, WMTS serves maps by dividing the map into a pyramid of tiles at
#' multiple scales.
#'
#' @importFrom httr2 req_perform req_url_path req_url_query request resp_body_xml
#' @importFrom xml2 xml_find_all xml_name xml_text
#'
#' @seealso
#' [get_apikeys()]
#'
#' @examples
#' \dontrun{
#' metadata_table <- get_layers_metadata("wms")
#'
#' # Get all "administratif" layers by filtering ressource name
#' admin_layers <- metadata_table[grepl("admin", metadata_table$Name, ignore.case = TRUE),]
#'
#' }
#'
#' @name get_layers_metadata
#' @return data.frame
#' @export
#'
get_layers_metadata <- function(data_type) {

   # check input ----
   if (!(data_type %in% c("wms-r", "wfs", "wmts"))){
      stop("'data_type' should be one of 'wms-r', 'wfs', 'wmts' not", data_type, call.=FALSE)
   }

   capabilities <- switch(data_type,
                          "wms-r" = list(version = "1.3.0", path = "wms-r/wms", service = "wms"),
                          "wfs" = list(version = "2.0.0", path = "wfs/ows", service = "wfs"),
                          "wmts" = list(version = "1.0.0", path = "wmts", service = "wmts"))

   xpath <- switch(data_type,
                   # first element is always "Cache IGN" so I remove it with position()>1
                   # parenthesis are needed for creating a node set but
                   "wms-r" =  "(//d1:Layer)[position() > 1]/*[position() <= 3]",
                   # /*[position() <= 3] select first three node of each selected node
                   "wfs" = "//d1:FeatureType/*[position() <= 3]",
                   "wmts" = "//d1:Layer/*[position() <= 2 or self::ows:Identifier]")

   req <- request("https://data.geopf.fr/") |>
      req_url_path(capabilities$path) |>
      req_url_query(service = capabilities$service,
                    version = capabilities$version,
                    request = "GetCapabilities",
                    sections = "FeatureTypeList") |>
      req_perform() |>
      resp_body_xml() |>
      xml_find_all(xpath)

   if (is_empty(req)){
      warning("There's no ", data_type, " resources, NULL is returned.", call. = F)
      return(NULL)
   }

   metadata <- as.data.frame(matrix(xml_text(req), ncol = 3, byrow = T)) |>
      setNames(xml_name(req)[1:3])

   return(metadata)
}
