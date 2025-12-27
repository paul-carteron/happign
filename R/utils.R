# Documentation choice :
#    - All internal function use @noRd tag wich mean no params can be inherit
# from package function ;
#    - param class is specified as `*`; before description ;
#    - each param description ends with a dot ;
#    - Description start with an upper case and end with a dot


#' @title get_wfs_default_crs
#' @description Get the default coordinate system for a layer.
#'
#' @param apikey `character`; API key from `get_apikeys()`.
#' @param layer `character`; name of the layer from `get_layers_metadata(apikey, "wfs")`.
#'
#' @importFrom sf st_crs
#' @importFrom xml2 xml_find_all xml_text
#' @importFrom httr2 req_perform req_url_path req_url_query request resp_body_xml
#'
#' @return An epsg code as class `integer` (e.g `4326`)
#' @noRd
#'
get_wfs_default_crs <- function(layer){

   param <- list(service = "wfs",
                 version = "2.0.0",
                 request = "GetCapabilities",
                 sections = "FeatureTypeList")

   req <- request("https://data.geopf.fr/") |>
      req_url_path("wfs/ows") |>
      req_url_query(!!!param) |>
      req_perform() |>
      resp_body_xml()

   name <- xml_find_all(req, ".//*[local-name() = 'Name']") |> xml_text()
   default_crs <- xml_find_all(req, ".//*[local-name() = 'DefaultCRS']") |> xml_text()

   crs <- default_crs[match(layer, name)]
   if (is.na(crs)) {
      stop("No CRS found: layer does not exist: ", layer, call. = FALSE)
   }

   return(crs)
}

#' @title get_wfs_default_geometry_name
#' @description Get the default geometry name for a layer.
#'
#' @param layer `character`; name of the layer from `get_layers_metadata(apikey, "wfs")`.
#'
#' @importFrom xml2 xml_find_first xml_attr
#' @importFrom httr2 request req_url_path_append req_user_agent req_url_query req_perform resp_body_xml
#'
#' @return A character representing geometry column name
#' @noRd
#'
get_wfs_default_geometry_name <- function(layer){

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "DescribeFeatureType",
      typeNames = layer
   )

   req <- request("https://data.geopf.fr") |>
      req_url_path_append("wfs/ows") |>
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      req_url_query(!!!params)

   xml_doc <- tryCatch(
      req |> req_perform() |> resp_body_xml(),
      httr2_http = function(cnd) {
         stop("DescribeFeatureType returned 404 for layer '", layer, "'.", call. = FALSE)
      }
   )

   geometry_name <- xml_find_first(xml_doc, ".//xsd:element[contains(@type,'gml')]") |>
      xml_attr("name")

   return(geometry_name)
}

#' @title is_empty
#' @description Check if an object is empty ie when no data is found from API.
#'
#' @param x `sf`, `sfc` or `list` object.
#'
#' @return TRUE if there is no data
#' @noRd
#'
is_empty <- function(x){
   # length(x) is used for checking empty xml response from `get_layers_metadata`
   identical(nrow(x), 0L) | identical(length(x), 0L)
}

#' @name as_geojson
#' @importFrom jsonlite toJSON
#' @importFrom sf st_make_valid st_transform st_geometry
#' @noRd
#' @description Function to convert sf object to geojson
as_geojson <- function(x, crs = 4326) {
   geom <- x |>
      st_make_valid() |>
      st_transform(crs) |>
      st_geometry() |>
      toJSON(collapse = FALSE, digits = 4)

   return(geom)
}

#' @title interactive_mode
#' @description menu for selectlecting apikey and layer
#'
#' @return list of character with apikey and layer
#' @noRd
interactive_mode <- function(data_type){

   apikeys <- get_apikeys()
   apikey <- apikeys[menu(apikeys)]

   layers <- get_layers_metadata(data_type, apikey)$Name
   layer <- layers[menu(layers)]

   return(list("layer" = layer))
}


#' @title pad0
#'
#' @return `character`
#' @noRd
pad0 <- \(x, n) if (is.null(x)) NULL else gsub(" ", "0", sprintf(paste0("%", n, "s"), x))
