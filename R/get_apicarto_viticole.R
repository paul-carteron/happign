#' Apicarto Appellations viticoles
#'
#' Implementation of the "Appellations viticoles" module from the
#' [IGN's apicarto](https://apicarto.ign.fr/api/doc/codes-postaux). The module
#' uses a database maintained by FranceAgriMer. This database includes :
#' appellation d'origine contrôlée (AOC) areas, protected geographical indication areas (IGP)
#' and wine growing areas without geographical indications (VSIG)
#'
#' @usage
#' get_apicarto_viticole(x)
#'
#' @param x Object of class `sf`. Needs to be located in France.
#'
#' @importFrom sf st_as_sfc st_make_valid st_transform read_sf
#' @importFrom geojsonsf sfc_geojson
#' @importFrom httr2 req_perform req_method resp_body_string
#'
#' @details
#' **/!\ For the moment the API cannot returned more than 1000 features.**
#'
#' @return Object of class `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' VSIG <- get_apicarto_viticole(penmarch)
#'}
#'
#' @name get_apicarto_viticole
#' @export
#'

get_apicarto_viticole <- function(x){

   # deal with sf object
   if(inherits(x, "sf")){
      x <- st_as_sfc(x)
   }

   # deal with sfc object
   if(inherits(x, "sfc")){
      geom <- x |>
         st_make_valid() |>
         st_transform(4326) |>
         sfc_geojson()
   }

   resp <- build_req(path = "api/aoc/appellation-viticole",
                             "geom" = geom) |>
      req_method("POST") |>
      req_perform() |>
      resp_body_string() |>
      read_sf(quiet = TRUE)

   return(resp)
}
