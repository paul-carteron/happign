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
#' * Code insee : must be a `character` of length 5
#' * Code departement : must be a `character` of length  2 or 3 (DOM-TOM)
#' @param type A `character` from `"parcelle"`, `"commune"`, `"feuille"`,
#'  `"division"`, `"localisant"`
#' @param source Can be "BDP" for BD Parcellaire or "PCI" for Parcellaire express.
#' See detail for more info.
#' @param section A `character` of length 2
#' @param numero A `character` of length 4
#' @param code_arr A `character` corresponding to district code for Paris,
#' Lyon, Marseille
#' @param code_abs A `character` corresponding to the code of absorbed commune.
#' This prefix is useful to differentiate between communes that have merged
#' @param code_com A `character` of length 5 corresponding to the commune code. Only use with
#' `type = "division"` or `type = "feuille"`

#' @details
#' `x`, `section`, `numero`, `code_arr`, `code_abs`, `code_com` can take vector of character.
#' In this case vector recycling is done. See the example section below.
#'
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
#'
#' # shape from the town of penmarch
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # get commune borders
#' ## from shape
#' penmarch_borders <- get_apicarto_cadastre(penmarch, type = "commune")
#'
#' ## from insee_code
#' border <- get_apicarto_cadastre("29158", type = "commune")
#' borders <- get_apicarto_cadastre(c("29158", "29165"), type = "commune")
#'
#' # get cadastral parcels
#' ## from shape
#' parcels <- get_apicarto_cadastre(penmarch, section = "AX")
#'
#' ## from insee code
#' parcels <- get_apicarto_cadastre("29158")
#'
#' # Use parameter recycling
#' ## get sections "AX" parcels from multiple insee_code
#' parcels <- get_apicarto_cadastre(c("29158", "29165"), section = "AX")
#'
#' ## get parcels numbered "0001", "0010" of section "AX" and "BR"
#' section <- c("AX", "BR")
#' numero <- rep(c("0001", "0010"), each = 2)
#' parcels <- get_apicarto_cadastre("29158", section = section, numero = numero)
#'
#' ## generalization with expand.grid
#' params <- expand.grid(code_insee = c("29158", "29165"),
#'                       section = c("AX", "BR"),
#'                       numero = c("0001", "0010"),
#'                       stringsAsFactors = FALSE)
#' parcels <- get_apicarto_cadastre(params$code_insee,
#'                                  section = params$section,
#'                                  numero = params$numero)
#'
#'}
#'
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

   # initialisation
   geom <- code_insee <- code_dep <- list(NULL)

   # check x input
   if (!inherits(x, c("character", "sf", "sfc"))) { # x can have 3 class
      stop("x must be of class character, sf or sfc.")
   }

   # check type and source input
   match.arg(type, c("parcelle", "commune", "feuille", "division", "localisant"))
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
             "3" = {code_dep <- x},
             "2" = {code_dep <- x},
             stop("x must be length 5; not ", nchar(x)))
   }

   # hit api and loop if there more than 1000 features
   resp <- Map(
      loop_api,
      path = paste0("api/cadastre/", type),
      limit = 1000,
      "code_insee" = code_insee,
      "code_dep" = code_dep,
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

   return(resp)
}
