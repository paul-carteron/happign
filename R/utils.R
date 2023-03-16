#' @description flip X and Y coord for ECQL filter
#' @param apikey character from `get_apikeys()`
#' @param layer_name character from `get_layers_metadata()$Name`
#' @importFrom sf st_crs
#' @importFrom xml2 xml_find_all xml_text
#' @importFrom httr2 request req_url_path req_url_query req_perform resp_body_xml
#' @return ecql string
#' @noRd
#'
get_wfs_default_crs <- function(apikey, layer_name){
   match.arg(apikey, get_apikeys())

   param <- list(service = "wfs",
                 version = "2.0.0",
                 request = "GetCapabilities",
                 sections = "FeatureTypeList")

   req <- request("https://wxs.ign.fr/") |>
      req_url_path(apikey,"geoportail", "wfs") |>
      req_url_query(!!!param) |>
      req_perform() |>
      resp_body_xml()

   name <- xml_find_all(req, "//d1:Name") |> xml_text()
   default_crs <- xml_find_all(req, "//d1:DefaultCRS") |> xml_text()

   crs <- default_crs[match(layer_name, name)]
   epsg <- st_crs(crs)$epsg
   return(epsg)
}

#' @description flip X and Y coord for ECQL filter
#' @param shape object of class sf or sfc
#' @importFrom sf st_axis_order st_geometry st_transform st_as_text
#' @importFrom dplyr summarize
#' @return ecql string
#' @noRd
#'
st_as_text_happign <- function(shape, crs){

   if(crs == 4326 & st_crs(shape)$epsg == 4326){
      on.exit(st_axis_order(F))
      st_axis_order(T)
      shape <- st_transform(shape, "CRS:84")
   }else if (crs == 4326 & st_crs(shape)$epsg != 4326){
      on.exit(st_axis_order(F))
      st_axis_order(T)
      shape <- st_transform(shape, 4326)
   }else{
      shape <- st_transform(shape, crs)
   }

   if (methods::is(shape, "sfc")){
      shape <- st_as_sf(shape)
   }

   geom <- suppressMessages(st_as_text(st_geometry(summarize(shape))))

   return(geom)
}

#' @description check if an object is empty ie when no data is found from API
#' @param x sf, sfc or list
#' @return TRUE if there is no data
#' @noRd
#'
is_empty <- function(x){
   # length(x) is used for checking empty xml response from `get_layers_metadata`
   identical(nrow(x), 0L) | identical(length(x), 0L)
}

#' @description trhow error if class is wrong
#' @param x object to test for class
#' @return error if FALSE, nothing if TRUE
#' @noRd
#'
class_check <- function(x, class){

   if (!inherits(x, class)) {
      stop(sprintf("Must inherit from class '%s', but has class '%s'",
                     class, class(x)))
   }
}

