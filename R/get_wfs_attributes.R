#' @title get_wfs_attributes
#'
#' @description
#' Helper to write ecql filter. Retrieve all attributes from a layer.
#'
#' @inheritParams get_wfs
#'
#' @importFrom xml2 xml_attr xml_find_all
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request resp_body_xml
#' @importFrom utils menu
#'
#' @return `character`vector with layer attributes
#' @export
#'
#' @examples
#' \dontrun{
#'
#' get_wfs_attributes("administratif", "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")
#'
#' # Interactive session
#' get_wfs_attributes(interactive = TRUE)
#'
#' }
get_wfs_attributes <- function(layer = NULL,
                               interactive = FALSE){

   if (interactive){
      choice <- interactive_mode("wfs")
      layer <- choice$layer
   }

   resp <- build_wfs_attributes(layer) |>
      req_perform() |>
      resp_body_xml()

   attr_names <- resp |>
      xml_find_all(".//xsd:element") |>
      xml_attr("name")

   return(attr_names[1:(length(attr_names)-2)])
}

build_wfs_attributes<- function(layer){

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "DescribeFeatureType",
      typeName = layer
      )

   request <- request("https://data.geopf.fr/") |>
      req_url_path_append("wfs/ows") |>
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      req_url_query(!!!params)

   return(request)
}
