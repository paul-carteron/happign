#' Apicarto Cadastre
#'
#' Implementation of the cadastre module from the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre)
#'
#' @usage
#' get_apicarto_cadastre(x,
#'                       type = "commune",
#'                       code_com = NULL,
#'                       section = NULL,
#'                       numero = NULL,
#'                       code_arr = NULL,
#'                       code_abs = NULL,
#'                       dTolerance = 0L,
#'                       source = "pci",
#'                       progress = TRUE)
#'
#' @param x It can be a shape, insee codes or departement codes :
#' * Shape : must be an object of class `sf` or `sfc`.
#' * Code insee : must be a `character` of length 5
#' * Code departement : must be a `character` of length  2 or 3 (DOM-TOM)
#' @param type A `character` from `"parcelle"`, `"commune"`, `"feuille"`,
#'  `"division"`, `"localisant"`
#' @param code_com A `character` of length 5 corresponding to the commune code. Only use with
#' `type = "division"` or `type = "feuille"`
#' @param section A `character` of length 2
#' @param numero A `character` of length 4
#' @param code_arr A `character` corresponding to district code for Paris,
#' Lyon, Marseille
#' @param code_abs A `character` corresponding to the code of absorbed commune.
#' This prefix is useful to differentiate between communes that have merged
#' @param dTolerance numeric; Complex shape cannot be handle by API; using `dTolerance`
#' allow to simplify them. See `?sf::st_simplify`
#' @param source Can be "bdp" for BD Parcellaire or "pci" for Parcellaire express.
#' See detail for more info.
#' @param progress Display a progress bar? Use TRUE to turn on a basic progress
#' bar, use a string to give it a name. See [httr2::req_perform_iterative()].
#'
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
#' @importFrom sf st_as_sfc st_make_valid st_transform st_simplify
#' @importFrom yyjsonr write_geojson_str
#' @importFrom httr2 req_perform_iterative iterate_with_offset resp_body_string
#' req_options req_url_path req_url_query resp_body_json resps_data req_url_path_append
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # shape from the town of penmarch
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # get commune borders
#' ## from shape
#' penmarch_borders <- get_apicarto_cadastre(penmarch, type = "commune")
#' qtm(penmarch_borders)+qtm(penmarch, fill = "red")
#'
#' ## from insee_code
#' border <- get_apicarto_cadastre("29158", type = "commune")
#' borders <- get_apicarto_cadastre(c("29158", "29135"), type = "commune")
#' qtm(borders, fill="nom_com")
#'
#' # get cadastral parcels
#' ## from shape
#' parcels <- get_apicarto_cadastre(penmarch, type = "parcelle")
#'
#' ## from insee code
#' parcels <- get_apicarto_cadastre("29158", type = "parcelle")
#'
#' # Use parameter recycling
#' ## get sections "AW" parcels from multiple insee_code
#' parcels <- get_apicarto_cadastre(
#'    c("29158", "29135"),
#'    section = "AW",
#'    type = "parcelle"
#' )
#' qtm(borders, fill = NA)+qtm(parcels)
#'
#' ## get parcels numbered "0001", "0010" of section "AW" and "BR"
#' section <- c("AW", "BR")
#' numero <- c("0001", "0010")
#' parcels <- get_apicarto_cadastre("29158", section = section, numero = numero, type = "parcelle")
#' qtm(penmarch_borders, fill = NA)+qtm(parcels)
#'
#'}
#'
#' @name get_apicarto_cadastre
#' @export
#'
get_apicarto_cadastre <- function(x,
                                  type = "commune",
                                  code_com = NULL,
                                  section = NULL,
                                  numero = NULL,
                                  code_arr = NULL,
                                  code_abs = NULL,
                                  dTolerance = 0L,
                                  source = "pci",
                                  progress = TRUE) {

   if (!inherits(x, c("sf", "sfc", "character"))) {
      stop("Input 'x' must be of class 'sf', 'sfc', or 'character'")
   }

   geom <- NULL
   code_insee <- NULL
   code_dep <- NULL

   if (inherits(x, c("sf", "sfc"))) {
      geom <- get_geojson(x, dTolerance)
   }

   if (inherits(x, "character")) {
      codes <- process_character_input(x)
      code_insee <- codes$code_insee
      code_dep <- codes$code_dep
   }

   params <- create_params(geom, code_insee, code_dep, code_com, section,
                           numero, code_arr, code_abs, source)
   resps <- lapply(params, fetch_data, type, progress)
   result <- lapply(resps, process_responses)

   result <- do.call(rbind, result)
   result <- result[, !sapply(result, is.list)]
   return(result)
}

#' @name get_geojson
#' @noRd
#' @description Function to convert sf object to geojson
get_geojson <- function(x, dTolerance = 0L, crs = 4326) {
   geom <- x |>
      st_make_valid() |>
      st_simplify(dTolerance = dTolerance) |>
      st_transform(crs) |>
      st_geometry() |>
      yyjsonr::write_geojson_str()
   return(geom)
}

#' @name process_character_input
#' @noRd
#' @description Detect length of x as character and add x to correct arg (dep or
#' code insee)
process_character_input <- function(x) {
   nchar_x <- nchar(x[1])

   result <- switch(as.character(nchar_x),
                    "5" = list(code_insee = x, code_dep = NULL),
                    "3" = list(code_insee = NULL, code_dep = x),
                    "2" = list(code_insee = NULL, code_dep = x),
                    stop("Character input 'x' must be of length 5, 3, or 2; not ",
                         nchar_x), call. = FALSE)

   return(result)
}

#' @name create_params
#' @noRd
#' @description Create request paramaeter and vectorized it
create_params <- function(geom, code_insee, code_dep, code_com, section, numero, code_arr, code_abs, source) {

   pad0 <- function(x, n){
      if (is.null(x)) return (NULL)
      gsub(" ", "0", sprintf(paste0("%0", n, "s"), x))
   }

   args <- list(
      "geom" = geom,
      "code_insee" = code_insee,
      "code_dep" = code_dep,
      "code_com" = pad0(code_com, 3),
      "section" = pad0(section , 2),
      "numero" = pad0(numero  , 4),
      "code_arr" = pad0(code_arr, 3),
      "code_abs" = pad0(code_abs, 3),
      "source_ign" = toupper(source),
      "_start" = 0,
      "_limit" = 500
   )

   args_not_null <- Filter(Negate(is.null), args) |> lapply(unique)
   args_df <- expand.grid(args_not_null, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
   args_list <- split(args_df, seq(nrow(args_df))) |> lapply(as.list)

   return(args_list)
}


#' @name fetch_data
#' @noRd
#' @description Fecth data from params
fetch_data <- function(params, type, progress) {
   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/cadastre") |>
      req_url_path_append(type) |>
      req_options(ssl_verifypeer = 0) |>
      req_url_query(!!!unlist(params))

   error_message <- paste(
      unlist(params[c("code_insee", "code_dep", "code_com", "section", "numero", "code_arr", "code_abs")]),
      collapse = " - "
   )

   resps <- tryCatch({
      req_perform_iterative(
         req,
         next_req = iterate_with_offset(
            "_start",
            start = 0,
            offset = 500,
            resp_pages = function(resp) {
               ceiling(resp_body_json(resp)$totalFeatures/500)
            }
         ),
         max_reqs = Inf,
         progress = progress
      )
   }, error = function(e) {
      if (grepl("URI Too Long", e$message)) {
         stop("Shape is too complex. \nTry increase `dTolerance` parameter.", call. = F)
      } else if (grepl("whole number", e$message)) {
         warning("No data found for : ", error_message, call. = F)
         return(NULL)
      } else {
         stop(e)  # Re-throw the original error if no condition matches
      }
   })

   return(resps)
}

#' @name process_responses
#' @noRd
#' @description Combines all responses in one sf object
process_responses <- function(resps) {
   res <- resps |>
      resps_data(\(resp) resp_body_string(resp)) |>
      lapply(read_sf)

   result <- do.call(rbind, res)
   result <- result[, !sapply(result, is.list)]

   return(result)
}
