#' Apicarto Commune
#'
#' Implementation of the cadastre module of the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre)
#'
#' @usage
#' get_apicarto_commune(x,
#'                      source = "PCI")
#'
#' @param x It can be a shape, insee code or departement code.
#' * shape : it must be an object of class `sf` or `sfc`.
#' * insee or departement code : it must be an object of class `character`. All insee code
#' from France can be retrieved by running `data(cog_2022)`
#' @param source Can be "BDP" for BD Parcellaire or "PCI" for Parcellaire
#' express. The BD Parcellaire is a discontinued product. Its use is no longer
#'  recommended because it is no longer updated. The use of PCI Express is
#'  strongly recommended and will become mandatory. More information on the
#'  comparison of this two products can be found
#'  [here](https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf)
#'
#' @return `get_apicarto_commune`return an object of class `sf`
#' @export
#'
#' @importFrom sf st_transform read_sf st_as_sfc st_make_valid
#' @importFrom httr2 req_perform req_url_path req_url_query request resp_body_string
#' resp_is_error last_response
#' @importFrom geojsonsf sfc_geojson
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # line from the best town in France
#' line <- st_linestring(matrix(c(-4.372215, -4.365177, 47.803943, 47.79772),
#'                              ncol = 2))
#' line <- st_sfc(line, crs = st_crs(4326))
#'
#' commune <- get_apicarto_commune(line)
#'
#' tm_shape(commune)+
#'    tm_borders()+
#' tm_shape(line)+
#'    tm_lines(col = "red", lwd = 2)
#'
#' # code_insee of the best town in France
#' commune <- get_apicarto_commune("29158")
#'
#' tm_shape(commune)+
#'    tm_borders()+
#'    tm_text("nom_com")
#'
#' }
#' @name get_apicarto_commune
#' @export
#'
get_apicarto_commune <- function(x, source = "PCI"){

   # Initialisation
   geom <- code_insee <- code_dep <- NULL

   # Input class verification
   match.arg(source, c("BDP", "PCI"))

   if (sum(class(x) %in% c("sf", "sfc", "character")) == 0) {
      stop("x", " must be character, sf or sfc; not ", class(x))
   }

   # Deal with sf or sfc object
   if(methods::is(x, "sf")){
      x <- st_as_sfc(x)
   }

   if(methods::is(x, "sfc")){
      geom <- x %>%
         st_make_valid() %>%
         st_transform(4326) %>%
         sfc_geojson()
   }

   # Deal with character
   if(methods::is(x, "character") && nchar(x) == 5){
      code_insee <- x
   }

   if(methods::is(x, "character") && nchar(x) == 2 && nchar(x) == 3){
      code_dep <- x
   }

   # Request
   res <- request("https://apicarto.ign.fr") %>%
      req_url_path("api/cadastre/commune") %>%
      req_url_query(
         code_insee = code_insee,
         code_dep = code_dep,
         geom = geom,
         source = source
      ) %>%
      req_perform() %>%
      resp_body_string() %>%
      read_sf(quiet = TRUE)

   if (dim(res)[1] == 0) {
      stop("No results is retrieve by API.\nCheck that",
           switch(substr(class(x), 1, 3)[1],
                  "sfc" = " the shape is in France",
                  "cha" = " insee or department code exists. Running `x %in% happign::cog_2022$COM` can help"),
           call. = FALSE)}


   return(res)
}
