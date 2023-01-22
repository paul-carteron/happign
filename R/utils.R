#' @description flip X and Y coord for ECQL filter
#' @param apikey character from `get_apikeys()`
#' @param layer_name character from `get_layers_metadata()$Name`
#' @importFrom sf st_crs
#' @importFrom xml2 xml_find_all xml_text
#' @importFrom httr2 request req_url_path req_url_query req_perform resp_body_xml
#' @return ecql string
#' @noRd
#'
get_wfs_default_crs = function(apikey, layer_name){
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

#' @description construct ecql spatial filter string
#' @param shape object of class sf or sfc
#' @param spatial_filter list containing spatial operation and other argument
#' @param crs epsg character from `get_wfs_default_crs`
#' @param apikey character from `get_apikeys()`
#' @importFrom sf st_bbox
#' @return ecql string
#' @noRd
#'
construct_spatial_filter <- function(shape = NULL,
                                     spatial_filter = NULL,
                                     crs = NULL,
                                     apikey = NULL){

   # Test for units
   units <- c("feet", "meters", "statute miles", "nautical miles", "kilometers")
   units_exist <- !is.na(spatial_filter[3])
   is_good_units <- spatial_filter[3] %in% units
   if (units_exist & !is_good_units){
      stop("When using \"", spatial_filter[1],
           "\" units should be one of \"", paste0(units, collapse = "\", \""),
           "\".",call. = F)
   }

   # particular case for bbox
   is_bbox <- (spatial_filter[1] == "bbox")
   if (is_bbox){
      bbox <- st_bbox(shape)
      spatial_filter <- c(spatial_filter,
                          bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          sprintf("'EPSG:%s'", st_crs(shape)$epsg))
   }

   # if is "bbox", geom is null
   geom <- switch(is_bbox + 1, st_as_text_happign(shape, crs), NULL)

   # Build final spatial filter
   spatial_filter <- sprintf("%s(%s, %s)",
                             toupper(spatial_filter[1]),
                             ifelse(apikey == "topographie", "geometrie", "the_geom"),
                             paste(c(geom, spatial_filter[-1]), collapse = ", "))

   return(spatial_filter)
}
