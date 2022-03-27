#' Apicarto Cadastre
#'
#' @param x It can be a shape or a code :
#' * Shape Then, all the cadastral parcels contained in it are downloaded. It should be an
#' object of class `sf` or `sfc`
#' * Code insee : filter the response on the INSEE code entered (must be a `character`)
#' @param section A `character` to filter the response on the cadastral section code entered (on 2 characters)
#' @param numero A `character` to filter the answers on the entered parcel number (on 4 characters)
#'
#' @return `apicarto_get_cadastre`return an object of class `sf`
#' @export
#'
#' @importFrom geojsonsf sfc_geojson
#' @importFrom purrr map_df
#' @importFrom sf st_as_sfc st_transform read_sf
#' @importFrom httr content GET modify_url
#'
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' #' # shape from the best town in France
#' shape <- st_polygon(list(matrix(c(-4.373937, 47.79859,
#'                                  -4.375615, 47.79738,
#'                                  -4.375147, 47.79683,
#'                                  -4.373898, 47.79790,
#'                                  -4.373937, 47.79859),
#'                                  ncol = 2, byrow = TRUE)))
#' shape <- st_sfc(shape, crs = st_crs(4326))
#'
#' res <- apicarto_get_cadastre(shape)
#' res2 <- apicarto_get_cadatre("29158")
#'
#' tm_shape(res)+
#'    tm_borders()
#' tm_shape(shape)+
#'    tm_borders(col = "red")
#'
#' tm_shape(res2)+
#'    tm_borders()
#'
#' }
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre <- function(x, section = NULL, numero = NULL) {
   UseMethod("get_apicarto_cadastre")
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.sf <- function(x, section = NULL, numero = NULL) {
   x <- st_transform(x, 4326)
   geojson_geom <- sfc_geojson(st_as_sfc(x))

   query_parameter = list(geom = geojson_geom,
                          code_insee = NULL,
                          section = section,
                          numero = numero)

   download_cadastre(query_parameter)
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.sfc <- function(x, section = NULL, numero = NULL) {
   x <- st_transform(x, 4326)
   geojson_geom <- sfc_geojson(x)

   query_parameter = list(geom = geojson_geom,
                          code_insee = NULL,
                          section = section,
                          numero = numero)

   download_cadastre(query_parameter)
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.character <- function(x, section = NULL, numero = NULL) {

   stopifnot("x is not a valid INSEE code (check insee database here : <https://www.insee.fr/fr/information/2560452>)" = x %in% happign::code_insee)

   query_parameter = list(geom = NULL,
                          code_insee = x,
                          section = section,
                          numero = numero)

   download_cadastre(query_parameter)

}
#' Download cadastre event if there more than 1000 features
#' @param query_parameter List with parameters for apicarto API
#' @noRd
download_cadastre <- function(query_parameter){
   url <- modify_url(
      "https://apicarto.ign.fr",
      path = "api/cadastre/parcelle",
      query = query_parameter)

   resp <- GET(url)
   nb_features <- content(resp)$totalFeatures
   nb_loop <- nb_features %/% 1000 + 1

   bind_resp <- function(x){
      cat("Request ", x, "/", nb_loop,
          " downloading...\n", sep = "")
      read_sf(paste0(url, "&_start=", 1000 * (x - 1)),  quiet = TRUE)
   }

   if (nb_loop > 1){
      res <- map_df(.x = seq_len(nb_loop),
                    .f = ~ bind_resp(.x))
   } else {
      res <- read_sf(resp)
   }

   return(res)
}

