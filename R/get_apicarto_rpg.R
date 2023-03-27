#' Apicarto RPG (Registre Parcellaire Graphique)
#'
#' Implementation of the "RPG" module from the
#' [IGN's apicarto](https://apicarto.ign.fr/api/doc/rpg). This function
#' is a wrapper around version 1 and 2 of the API.
#'
#' @usage
#' get_apicarto_rpg(x,
#'                  annee,
#'                  code_cultu = list(NULL),
#'                  dTolerance = 0)
#'
#' @param x Object of class `sf`. Needs to be located in France.
#' @param annee numeric between 2010 and 2021
#' @param code_cultu character corresponding to code culture, see detail.
#' @param dTolerance numeric; tolerance parameter. The value of `dTolerance`
#' must be specified in meters, see detail.
#'
#' @details
#' Since 2014 the culture code has changed its format. Before it should be
#' a value ranging from "01" to "28", after it should be a trigram (ex : "MIE").
#' More info can be found at the
#' [documentation page](https://apicarto.ign.fr/api/doc/pdf/docUser_moduleRPG.pdf)
#'
#' `dTolerance` is needed when geometry are too complex. Its the same parameter
#'  found in `sf::st_simlplify`.
#'
#' @return `list` or object of class `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' penmarch <- get_apicarto_cadastre("29158", type = "commune")
#'
#' # failure with too complex geom
#' rpg <- get_apicarto_rpg(penmarch, 2020)
#'
#' # parcel from 2020
#' rpg <- get_apicarto_rpg(penmarch, 2020, dTolerance = 5)
#'
#' # multiple years after 2014
#' rpg <- get_apicarto_rpg(x, 2020:2021, dTolerance = 5)
#'
#' # years before and after 2014
#' # list is returned because attribut are different
#' rpg <- get_apicarto_rpg(x, c(2010, 2021), dTolerance = 10)
#'
#' # filter by code_cultu
#' rpg <- get_apicarto_rpg(x, 2021, code_cultu = "MIE", dTolerance = 10)
#'
#' # all "MIE" from 2020 and all "PPH" from 2021
#' res <- get_apicarto_rpg(x, 2020:2021, code_cultu = c("MIE", "PPH"), dTolerance = 10)
#'
#' # vectorization : all "MIE" from 2020 and 2021
#' res <- get_apicarto_rpg(x, 2020:2021, code_cultu = "MIE", dTolerance = 10)
#'}
#'
#' @name get_apicarto_rpg
#' @export
#'

get_apicarto_rpg <- function(x, annee, code_cultu = list(NULL), dTolerance = 0){

   # check parameter : x
   if (!inherits(x, c("sf", "sfc"))) { # x can have 3 class
      stop("x must be of class sf or sfc.")
   }

   # check parameter : annee
   if (!all(annee %in% 2010:2021)){
      stop("annee must be between 2010 and 2021.")
   }

   # deal with changement of api path before and after 2014
   version <- ifelse(annee <= 2014, "v1", "v2")

   # hit api and loop if there more than 1000 features
   resp <- Map(
      loop_api,
      path = paste0("api/rpg/", version),
      limit = 1000,
      "annee" = annee,
      "geom" = shp_to_geojson(x, crs = 4326, dTolerance = dTolerance),
      "code_cultu" = code_cultu)

   if (all(is_empty(unlist(resp)))){
      warning("No data found, NULL is returned.", .call = FALSE)
      return(NULL)
   }

   # add years to each polygon
   names(resp) <- annee
   resp <- mapply(cbind, resp, "annee" = annee, SIMPLIFY = F)

   tryCatch({
      # bind rows of each Map call
      resp <- do.call(rbind, resp)
      # Cleaning list column from features
      resp <- resp[ , !sapply(resp, is.list)]
   }, error = function(cnd){
      warning("Data before and after 2014 are different, a list is returned.", call. = FALSE)}
   )

   return(resp)
}

