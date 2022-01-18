#' List of all API keys from IGN
#'
#' All API keys are manually extract from this
#' [table](https://geoservices.ign.fr/documentation/services/tableau_ressources)
#' provided by IGN.
#'
#' @name get_apikeys
#' @return character
#' @export
#'
#' @examples
#' \dontrun{
#' # One API key
#' get_apikeys()[1]
#'
#' # All API keys
#' get_apikeys()
#'
#' }
#'
get_apikeys <- function() {
   apikeys <- c(
      "administratif",
      "adresse",
      "agriculture",
      "altimetrie",
      "cartes",
      "cartovecto",
      "clc",
      "economie",
      "environnement",
      "geodesie",
      "lambert93",
      "ortho",
      "orthohisto",
      "parcellaire",
      "satellite",
      "sol",
      "topographie",
      "transports"
   )
   apikeys
}
