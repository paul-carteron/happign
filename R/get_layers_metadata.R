#' @title Metadata for one couple of apikey and data_type
#'
#' @description
#' Metadata are retrieved using the IGN APIs. The execution time can
#' be long depending on the size of the metadata associated with
#' the API key and the overload of the IGN servers.
#'
#' @param apikey API key from `get_apikeys()` or directly
#' from the [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param data_type Should be `"wfs"` or `"wms"`. See details for more
#' information about these two Webservice formats.
#'
#' @importFrom httr2 req_perform req_url_path req_url_query request resp_body_xml
#' @importFrom xml2 xml_find_all xml_name xml_text
#'
#' @seealso
#' [get_apikeys()]
#'
#' @examples
#' \dontrun{
#' apikey <- get_apikeys()[4]
#' metadata_table <- get_layers_metadata(apikey, "wms")
#' layers <- metadata_table$Name
#' one_abstract <- metadata_table[1, "Abstract"]
#'
#' # List every wfs layers (warning : it's quite long)
#' all_layers <- lapply(get_apikeys(),
#'                      get_layers_metadata,
#'                      data_type = "wfs")
#'
#' # Convert list to data.frame
#' all_layers <- do.call(rbind, list_metadata)
#' }
#'
#' @name get_layers_metadata
#' @return data.frame
#' @export
#'
get_layers_metadata <- function(apikey,
                                data_type) {

   match.arg(data_type, c("wms", "wfs", "wmts"))

   # check input ----
   # check parameter : apikey
   if (length(apikey) > 1){
      stop("Only one `apikey` must be provided instead of ", length(apikey), call. = F)
   }
   if (!inherits(apikey, "character")) {
      stop("`apikey` must be of class character not ", class(apikey), call. = F)
   }
   if (!(apikey %in% get_apikeys())) {
      stop("`apikey` must be one of : ", paste(get_apikeys(), collapse = ", "), call. = F)
   }

   version <- switch(data_type,
                     "wms" = "1.3.0",
                     "wfs" = "2.0.0",
                     "wmts" = "1.0.0")

   path <- switch(data_type,
                  "wms" = "r",
                  "wfs" = NULL,
                  "wmts" = NULL)

   xpath <- switch(data_type,
                   # /*[position() <= 3] select first three node of each selected node
                   "wfs" = "//d1:FeatureType/*[position() <= 3]",
                   # first element is always "Cache IGN" so I remove it with position()>1
                   # parenthesis are needed for creating a node set but
                   "wms" =  "(//d1:Layer)[position() > 1]/*[position() <= 3]",
                   "wmts" = "//d1:Layer/*[position() <= 2 or self::ows:Identifier]")

   req <- request("https://wxs.ign.fr/") |>
      req_url_path(apikey,"geoportail", path) |>
      req_url_path_append(data_type) |>
      req_url_query(service = data_type,
                    version = version,
                    request = "GetCapabilities",
                    sections = "FeatureTypeList") |>
      req_perform() |>
      resp_body_xml() |>
      xml_find_all(xpath)

   if (is_empty(req)){
      warning("There's no ", data_type, " resources for apikey '", apikey,
              "', NULL is returned.", call. = F)
      return(NULL)
   }

   metadata <- as.data.frame(matrix(xml_text(req), ncol = 3, byrow = T)) |>
      setNames(xml_name(req)[1:3])

   return(metadata)
}
