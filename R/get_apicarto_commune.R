#' Apicarto Commune
#'
#' Implementation of the cadastre module of the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre) for commune borders
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
#' # Using shape
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
#' # Using code_insee
#' commune <- get_apicarto_commune("29158")
#'
#' tm_shape(commune)+
#'    tm_borders()+
#'    tm_text("nom_com")
#'
#' # Get multiple communes borders
#'
#' input <- list(line, "29171")
#' borders <- lapply(input, get_apicarto_commune, source = "PCI")
#' borders <- do.call(rbind, borders)
#'
#' tm_shape(borders)+
#'    tm_borders()+
#'    tm_text("nom_com")
#' }
#'
#' @name get_apicarto_commune
#' @export
#'
get_apicarto_commune <- function(x, source = "PCI"){

   # initialisation
   geom <- code_insee <- code_dep <- NULL

   # check x input
   if (!inherits(x, c("character", "sf", "sfc"))) { # x can have 3 class
      stop("x must be of class character, sf or sfc.")
   }

   # check source input
   match.arg(source, c("BDP", "PCI"))

   # Deal with sf object
   if(inherits(x, "sf")){
      x <- st_as_sfc(x)
   }

   # Deal with sfc object
   if(inherits(x, "sfc")){
      geom <- x |>
         st_make_valid() |>
         st_transform(4326) |>
         sfc_geojson()
   }

   # Deal with character
   if(inherits(x, "character")){
      switch(as.character(nchar(x)),
             "2" = {code_dep <- x},
             "3" = {code_dep <- x},  #DOM-TOM
             "5" = {code_insee <- x},
             stop("x must be length 2, 3 or 5; not ", nchar(x)))
   }

   # Request
   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/cadastre/commune") |>
      req_url_query(
         code_insee = code_insee,
         code_dep = code_dep,
         geom = geom,
         source = source)

   resp <- req_perform(req) |>
      resp_body_string() |>
      read_sf(quiet = TRUE)

   if (is_empty(resp)){
      warning("No data found, NULL is returned. This could be due to :\n",
              "- shape outside of France\n",
              "- non-existent insee or department code\n",
              "- existing code but not recognized by apicarto.\n",
              "Running data(cog_2022) can help find all insee code.", .call = FALSE)
      return(NULL)
   }

   return(resp)
}
