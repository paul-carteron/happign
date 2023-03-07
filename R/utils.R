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

#' @description loop over api when limit exist
#' @param path path of the api
#' @param limit max number of feature api can returned
#' @param ... request parameters
#' @return sf object
#' @noRd
#'
loop_api <- function(path, limit, ...){

   # function factories
   build_req <- function(path, ...) {
      params <- list(...)
      req <- request("https://apicarto.ign.fr") |>
         req_url_path(path) |>
         req_url_query(!!!params)

   }
   hit_api <- function(req){
      resp <- req_perform(req) |>
         resp_body_string() |>
         read_sf(quiet = TRUE)
   }

   # init
   message("Features downloaded : ", appendLF = F)
   req <- build_req(path = path, "_start" = 0, ...)
   resp <- hit_api(req)
   message(nrow(resp), appendLF = F)

   # if more features than the limit are matched, it loop until everything is downloaded
   i <- limit
   temp <- resp
   while(nrow(temp) == limit){
      message("...", appendLF = F)
      req <- build_req(path = path, "_start" = i, ...)
      temp <- hit_api(req)
      resp <- rbind(resp, temp)
      message(nrow(resp), appendLF = F)
      i <- i + limit
   }

   cat("\n")

   return(resp)

}
