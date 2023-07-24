#' Apicarto Appellations viticoles
#'
#' Implementation of the "Appellations viticoles" module from the
#' [IGN's apicarto](https://apicarto.ign.fr/api/doc/codes-postaux). The module
#' uses a database maintained by FranceAgriMer. This database includes :
#' appellation d'origine contrôlée (AOC) areas, protected geographical indication areas (IGP)
#' and wine growing areas without geographical indications (VSIG)
#'
#' @usage
#' get_apicarto_viticole(x,
#'                       dTolerance = 0)
#'
#' @param x Object of class `sf`. Needs to be located in France.
#' @param dTolerance numeric; tolerance parameter. The value of `dTolerance`
#' must be specified in meters, see `?sf::st_simplify` for more info.
#'
#' @importFrom sf st_as_sfc st_make_valid st_transform read_sf
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

get_apicarto_viticole <- function(x, dTolerance = 0){

   if (!inherits(x, c("sf", "sfc"))) { # x can have 3 class
      stop("x must be of class sf or sfc.")
   }

   req <- build_req(path = "api/aoc/appellation-viticole",
                     "geom" = shp_to_geojson(x,
                                             crs = 4326,
                                             dTolerance = dTolerance)) |>
      req_method("POST")

   resp <- hit_api(req)

   return(resp)
}
