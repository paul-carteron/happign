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

   name <- xml_find_all(req, "//d1:Name") |> xml_text()
   default_crs <- xml_find_all(req, "//d1:DefaultCRS") |> xml_text()

   crs <- default_crs[match(layer, name)]
   no_crs <- is.na(crs)
   if (no_crs){
      stop("No crs found, `layer` does not exist.", call. = F)
   }

   epsg <- st_crs(crs)$epsg
   return(epsg)
}

#' @title st_as_text_happign
#' @description Flip X and Y coord for ECQL filter.
#'
#' @param x `sf` or `sfc`; needs to be located in France.
#' @param crs `integer`; an epsg code (e.g. `4326`).
#'
#' @importFrom sf st_axis_order st_geometry st_transform st_as_text st_as_sf
#' @importFrom dplyr summarize
#'
#' @return An ecql filter as class `character`
#' @noRd
#'
st_as_text_happign <- function(x, crs){

   if(crs == 4326 & st_crs(x)$epsg == 4326){
      on.exit(st_axis_order(F))
      st_axis_order(T)
      x <- st_transform(x, "CRS:84")
   }else if (crs == 4326 & st_crs(x)$epsg != 4326){
      on.exit(st_axis_order(F))
      st_axis_order(T)
      x <- st_transform(x, 4326)
   }else{
      x <- st_transform(x, crs)
   }

   if (methods::is(x, "sfc")){
      x <- st_as_sf(x)
   }

   geom <- suppressMessages(st_as_text(st_geometry(summarize(x))))

   return(geom)
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

#' @title shp_to_geojson
#' @description Convert sf or sfc object to geojson.
#'
#' @param x `sf` or `sfc` object.
#' @param crs target coordinate reference system: object of class 'crs',
#' or input string for `st_crs`
#' @param dTolerance `numeric`; tolerance parameter. The value of `dTolerance`
#' must be specified in meters.
#'
#' @importFrom jsonlite toJSON
#' @importFrom sf st_make_valid st_transform st_geometry st_simplify sf_use_s2
#'
#' @return A json string of class `character`
#' @noRd
#'
shp_to_geojson <- function(x, crs = 4326, dTolerance = 0){

   default_s2 <- suppressMessages(sf_use_s2())
   suppressMessages(sf_use_s2(TRUE))
   on.exit(suppressMessages(sf_use_s2(default_s2)))

   x <- x |>
      st_make_valid() |>
      st_simplify(dTolerance = dTolerance) |>
      st_transform(crs) |>
      st_geometry() |>
      toJSON()

   # remove first and last bracket unless apicarto doesn't work
   x <- gsub('^.|.$', '', x)

   return(x)

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
