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
apicarto_get_cadastre <- function(x, section = NULL, numero = NULL){

   # Avoid object different than sf, sfc, xharacter
   if(!grepl("sf", class(x)[1]) & class(x)[1] != "character"){
      stop("x should be an sf, sfc or a character object")
   }

   # Initialise API argument
   code_insee = NULL
   geom = NULL
   section = section
   numero = numero

   # When x is sf or sfc, convert to geojson string
   if (grepl("sf", class(x)[1])){
      x = st_transform(x, 4326)
      geom = sfc_geojson(st_as_sfc(x))
   }

   # When x is character check with existing code

   if (is.character(x) & x %in% happign::code_insee){
      code_insee <- x
   }else{
      stop("Your code does not exist in the insee database. See <https://www.insee.fr/fr/information/2560452> to download the database")
   }


   url <- modify_url(
      "https://apicarto.ign.fr",
      path = "api/cadastre/parcelle",
      query = list(code_insee = code_insee,
                   geom = geom,
                   section = section,
                   numero = numero))

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

}
