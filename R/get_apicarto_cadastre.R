#' Apicarto Cadastre
#'
#' Implementation of the cadastre module from the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre)
#'
#' @usage
#' get_apicarto_cadastre(x,
#'                       type = "parcelle",
#'                       source = "PCI",
#'                       section = list(NULL),
#'                       numero = list(NULL),
#'                       code_arr = list(NULL),
#'                       code_abs = list(NULL),
#'                       code_com = list(NULL))
#'
#' @param x It can be a shape, insee codes or departement codes :
#' * Shape : must be an object of class `sf` or `sfc`.
#' * Code insee : must be a 5 letters `character`
#' * Code departement : must be a 2  or 3 letters `character`
#' @param type A `character` from "parcelle", "commune", "feuille", "division"
#' @param source Can be "BDP" for BD Parcellaire or "PCI" for Parcellaire express.
#' See detail for more info.
#' @param section A `character` corresponding to cadastral section
#' @param numero A `character` corresponding to cadastral number
#' on the entered parcel number (on 4 characters)
#' @param code_arr A `character` corresponding to district code for Paris, Lyon, Marseille
#' @param code_abs A `character` corresponding to the code of absorbed commune.
#' This prefix is useful to differentiate between communes that have merged
#' @param code_com A `character` corresponding to the commune code. Only use with
#' `type = "division"` or `type = "feuille"`

#' @details
#' `source`: BD Parcellaire is a discontinued product. Its use is no longer
#'  recommended because it is no longer updated. The use of PCI Express is
#'  strongly recommended and will become mandatory. More information on the
#'  comparison of this two products can be found
#'  [here](https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf)
#'
#' @return Object of class `sf`
#' @export
#'
#' @importFrom sf st_as_sfc st_make_valid st_transform
#' @importFrom geojsonsf sfc_geojson
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' }
#' @name get_apicarto_cadastre
#' @export
#'
get_apicarto_cadastre <- function(x,
                                  type = "parcelle",
                                  source = "PCI",
                                  section = list(NULL),
                                  numero = list(NULL),
                                  code_arr = list(NULL),
                                  code_abs = list(NULL),
                                  code_com = list(NULL)){

   # check x input
   if (!inherits(x, c("character", "sf", "sfc"))) { # x can have 3 class
      stop("x must be of class character, sf or sfc.")
   }

   # check type and source input
   match.arg(type, c("parcelle", "commune", "feuille", "division"))
   match.arg(source, c("BDP", "PCI"))

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

   # deal with character
   if(inherits(x, "character")){
      switch(as.character(nchar(x[1])),
             "5" = {code_insee <- x},
             "2" = {code_dep <- x},
             stop("x must be length 5; not ", nchar(x)))
   }

   # hit api and loop if there more than 1000 features
   resp <- Map(
      loop_api,
      path = paste0("api/cadastre/", type),
      limit = 1000,
      "code_insee" = code_insee,
      "section" = section,
      "numero" = numero,
      "geom" = geom,
      "code_abs" = code_abs,
      "code_arr" = code_arr,
      "source_ign" = source
   )

   # bind rows of each Map call
   resp <- do.call(rbind, resp)
   # Cleaning list column from features
   resp <- resp[ , !sapply(resp, is.list)]

   if (is_empty(resp)){
      warning("No data found, NULL is returned. This could be due to :\n",
              "- shape outside of France\n",
              "- non-existent insee or department code\n",
              "- existing code but not recognized by apicarto.\n",
              "Running data(cog_2022) can help find all insee code.", .call = FALSE)
      return(NULL)
   }
}
