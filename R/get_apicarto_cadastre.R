#' Apicarto Cadastre
#'
#' Implementation of the cadastre module of the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre)
#'
#' #' @usage
#' get_apicarto_cadastre(x,
#'                       section = NULL,
#'                       numero = NULL,
#'                       code_abs = NULL,
#'                       source_ign = "PCI")
#'
#' @param x It can be a shape or multiple insee code :
#' * Shape : all the cadastral parcels contained in it are downloaded. It should be an
#' object of class `sf` or `sfc`.
#' * Code insee : filter the response on the INSEE code entered (must be a `character` or a vector
#' of `character`)
#' @param section A `character` or a vector of `character` to filter the response on the
#' cadastral section code entered (on 2 characters)
#' @param numero A `character` or a vector of `character` to filter the answers on the entered parcel
#' number (on 4 characters)
#' @param code_abs  A `character` or a vector of `character` to filter the answers on the code of
#' absorbed commune. This prefix is useful to differentiate between communes that have merged
#' @param source_ign Can be "BDP" for BD Parcellaire or "PCI" for Parcellaire express.
#'  The BD Parcellaire is a discontinued product. Its use is no longer
#'  recommended because it is no longer updated. The use of PCI Express is
#'  strongly recommended and will become mandatory. More information on the comparison
#'  of this two products can be found
#'  [here](https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf)
#'
#' @return `get_apicarto_cadastre`return an object of class `sf`
#' @export
#'
#' @importFrom sf st_as_sfc st_transform read_sf
#' @importFrom httr content GET modify_url
#' @importFrom dplyr bind_rows mutate rowwise
#' @importFrom utils globalVariables
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
#' PCI_shape <- get_apicarto_cadastre(shape, section = c("AX", "BR"))
#' BDP_Code <- get_apicarto_cadastre("29158", section = c("AX", "BR"), source_ign = "BDP")
#'
#' tm_shape(PCI_shape)+
#'    tm_borders()+
#' tm_shape(shape)+
#'    tm_borders(col = "red")
#'
#' tm_shape(BDP_Code)+
#'    tm_polygons(col = "section", border.col = "black")
#'
#' }
#' @name get_apicarto_cadastre
#' @export
#'
globalVariables(c("code_insee", "section", "numero", "geom", "code_abs", "source_ign"))
#'
get_apicarto_cadastre <- function(x,
                                  section = NULL,
                                  numero = NULL,
                                  code_abs = NULL,
                                  source_ign = "PCI") {
   UseMethod("get_apicarto_cadastre")
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.sf <- function(x,
                                     section = NULL,
                                     numero = NULL,
                                     code_abs = NULL,
                                     source_ign = "PCI") {
   match.arg(source_ign, c("BDP", "PCI"))
   x <- st_transform(x, 4326)
   geojson_geom <- shp_to_geojson(x)

   query_parameter = list(geom = geojson_geom,
                          code_insee = NULL,
                          section = section,
                          numero = numero,
                          code_abs = code_abs,
                          source_ign = source_ign)

   download_cadastre(query_parameter)
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.sfc <- function(x,
                                      section = NULL,
                                      numero = NULL,
                                      code_abs = NULL,
                                      source_ign = "PCI") {
   match.arg(source_ign, c("BDP", "PCI"))
   x <- st_transform(x, 4326)
   geojson_geom <- shp_to_geojson(x)

   query_parameter = list(geom = geojson_geom,
                          code_insee = NULL,
                          section = section,
                          numero = numero,
                          code_abs = code_abs,
                          source_ign = source_ign)

   download_cadastre(query_parameter)
}
#' @name get_apicarto_cadastre
#' @export
get_apicarto_cadastre.character <- function(x,
                                            section = NULL,
                                            numero = NULL,
                                            code_abs = NULL,
                                            source_ign = "PCI") {

   match.arg(source_ign, c("BDP", "PCI"))
   stopifnot("x is not a valid INSEE code (check insee database here : <https://www.insee.fr/fr/information/2560452>)" = x %in% happign::code_insee)

   query_parameter = list(geom = NULL,
                          code_insee = x,
                          section = section,
                          numero = numero,
                          code_abs = code_abs,
                          source_ign = source_ign)

   download_cadastre(query_parameter)

}
#' Download cadastre event if there more than 1000 features
#' @param query_parameter List with parameters for apicarto API
#' @noRd
download_cadastre = function(query_parameter){

   vectorized_query = lapply(query_parameter,
                             function(x){if(is.null(x)){list(NULL)}else{x}})

   urls <- expand.grid(vectorized_query) %>%
      rowwise() %>%
      mutate(url =  modify_url("https://apicarto.ign.fr",
                               path = "api/cadastre/parcelle",
                               query = list(code_insee = code_insee,
                                            section = section,
                                            numero = numero,
                                            geom = geom,
                                            code_abs = code_abs,
                                            source_ign = source_ign)))

   nb_loop <- lapply(urls$url, function(x){content(GET(x))$totalFeatures %/% 1000 + 1})

   urls <- paste0(rep(urls$url, nb_loop),
                  "&_start=",
                  unlist(lapply(nb_loop, function(x) seq(0, x-1) * 1000)))

   bind_resp <- function(x, urls){
      cat("Request ", x, "/", length(urls),
          " downloading...\n", sep = "")
      resp <- GET(urls[x])
      read_sf(resp,  quiet = TRUE)
   }

   parcelles <- lapply(seq_along(urls), bind_resp, urls) %>%
      bind_rows()

   return(parcelles)

}
