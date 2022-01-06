#' List of all API keys from IGN
#'
#' All apikeys are manually extract from this table provided by IGN :
#' https://geoservices.ign.fr/documentation/services/tableau_ressources
#'
#' @export
#'
#' @examples
#' get_apikeys()[1]
get_apikeys <- function() {
   apikeys <- c(
      "administratif",
      "adresse",
      "agriculture",
      "altimetrie",
      "calcul",
      "cartes",
      "cartovecto",
      "clc",
      "economie",
      "environnement",
      "geodesie",
      "l93",
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
