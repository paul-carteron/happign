#' Apicarto Cadastre
#'
#' Implementation of the cadastre module from the
#' [IGN's apicarto](https://apicarto.ign.fr/api/doc/cadastre)
#'
#' @usage
#' get_apicarto_cadastre(x,
#'                       type = "commune",
#'                       section = NULL,
#'                       numero = NULL,
#'                       code_abs = NULL,
#'                       source = "pci",
#'                       progress = TRUE)
#'
#' @param x `sf`, `sfc`, `character` or `numeric` :
#' * Shape : must be an object of class `sf` or `sfc`.
#' * Code insee : must be a `character` of length 5 (see [happign::com_2025])
#' * Code departement : must be a `character` of length  2 or 3 (DOM-TOM)
#' (see [happign::dep_2025])
#' @param type `character` : type of data needed, default to `"commune"`.
#' One of `"commune"`, `"parcelle"`, `"section"`, `"localisant"`.
#' @param section `character` : corresponding to section of a city.
#' @param numero `character` : corresponding to numero of cadastral parcels.
#' @param code_abs `character` : corresponding to the code of absorbed commune.
#' This prefix is useful to differentiate between communes that have merged
#' @param source `character` : `"bdp"` for BD Parcellaire or `"pci"` for
#' Parcellaire express. Default to `"pci"`. See detail for more info.
#' @param progress Display a progress bar? Use TRUE to turn on a basic progress
#' bar, use a string to give it a name. See [httr2::req_perform_iterative()].
#'
#' @details
#' **Vectorisation**:
#'
#' Arguments `x`, `section`, `numero`, and `code_abs` are vectorized
#' if only one argument has `length > 1` (**Cartesian product**)
#' ```
#' x = 29158; section = c("A", "B")
#' → (29158, "A"), (29158, "B")
#'
#' x = 29158, section = "A", numero = 1:3
#' → (29158, "A", 1); (29158, "A", 2); (29158, "A", 3)
#' ```
#'
#' In case all vectorised arguments have the same length **Pairwise matching**
#' is used
#' ```
#' x = c(29158, 29158); section = c("A", "B"); numero = 1:2
#' → (29158, "A", 1), (29158, "B", 2)
#' ```
#'
#' **Ambiguous vectorisation**:
#'
#' If more than one argument has `length > 1` but lengths differ, it is unclear
#' whether to combine them pairwise or via cartesian product. This is rejected
#' with an error to avoid unintended queries.
#' ```
#' x = 29158, section = c("A", "B"), numero = 1:2
#' Possible interpretations:
#' 1. Pairwise: (29158, "A", 1), (29158, "B", 2)
#' 2. Cartesian: (29158, "A", 1), (29158, "A", 2), (29158, "B", 1), (29158, "B", 2)
#' ```
#'
#' **Source**:
#'
#' BD Parcellaire (`"bdp"`) is no longer updated and its use is discouraged.
#' PCI Express (`"pci"`) is strongly recommended and will become mandatory.
#' See IGN's [product comparison table](https://geoservices.ign.fr/sites/default/files/2021-07/Comparatif_PEPCI_BDPARCELLAIRE.pdf).
#'
#' @return Object of class `sf`
#' @export
#'
#' @importFrom sf st_geometry st_geometry_type st_make_valid st_transform
#' @importFrom jsonlite toJSON
#' @importFrom httr2 req_method req_perform_iterative iterate_with_offset resp_body_string
#' req_options req_url_path req_url_query resp_body_json resps_data req_url_path_append req_method
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
#' qtm(parcels, fill="section")
#'
#' ## from insee code
#' parcels <- get_apicarto_cadastre("29158", type = "parcelle")
#' qtm(parcels, fill="section")
#'
#' # Use parameter recycling
#' ## get sections "AW" parcels from multiple insee_code
#' parcels <- get_apicarto_cadastre(
#'    c("29158", "29135"),
#'    section = "AW",
#'    type = "parcelle"
#'    )
#' qtm(borders, fill = NA)+qtm(parcels)
#'
#' ## if multiple args with length > 1 result is ambigous
#' parcels <- get_apicarto_cadastre(
#'    x = c("29158", "29135"),
#'    section = c("AW", "AB"),
#'    numero = 1,
#'    type = "parcelle"
#' )
#'
#' ## get parcels numbered "0001", "0010" of section "AW" and "BR"
#' insee <- rep("29158", 2)
#' section <- c("AW", "BR")
#' numero <- c("0001", "0010")
#' parcels <- get_apicarto_cadastre(insee, section = section, numero = numero, type = "parcelle")
#' qtm(penmarch_borders, fill = NA)+qtm(parcels)
#'
#' # Arrondissement insee code should be used for paris, lyon, marseille
#' error <- get_apicarto_cadastre(c(75056, 69123, 13055))
#' paris_arr123 <- get_apicarto_cadastre(c(75101, 75102, 75103))
#' qtm(paris_arr123, fill = "code_insee")
#'
#'}
#'
#' @name get_apicarto_cadastre
#' @export
#'
get_apicarto_cadastre <- function(x,
                                  type = "commune",
                                  section = NULL,
                                  numero = NULL,
                                  code_abs = NULL,
                                  source = "pci",
                                  progress = TRUE) {

   type <- match.arg(type, c("parcelle", "commune", "section", "localisant"))

   is_geom <- inherits(x, c("sf", "sfc"))
   is_code_insee <- all(pad0(x, 5) %in% happign::com_2025$COM)
   is_code_dep <- all(pad0(x, 2) %in% happign::dep_2025$DEP)

   if (!(is_geom || is_code_insee || is_code_dep)) {
      stop("`x` must be either an `sf` / `sfc` object, or a character vector",
           " of valid 5-digit INSEE codes or valid department codes. See",
           "`data(com_2025, dep_025)`." , call. = FALSE)
   }

   if (is_geom) {
      if (length(st_geometry(x)) > 1) {
         stop("Cadastre API only accepts one geometry per request. ",
              "You provided ", length(x), " geometries.\n",
              "Use `sf::st_union()` to combine them or split into multiple requests.",
              call. = FALSE)
      }
      if (st_geometry_type(x) == "MULTIPOINT"){
         stop("`MULTIPOINT` geometry aren't supported by apicarto.", call. = FALSE)
      }
   }

   if(is_code_insee) ensure_is_not_arr(x)

   if (type == "section"){
      type <- if (source == "pci") "feuille" else "division"
   }

   vectorized_args <- list(
      "geom" = if (is_geom) as_geojson(x) else NULL,
      "code_insee" = if (is_code_insee) x else NULL,
      "code_dep" = if (is_code_dep) x else NULL,
      "section" = pad0(section, 2),
      "numero" = pad0(numero, 4),
      "code_abs" = pad0(code_abs, 3)
   )

   args_not_null <- Filter(Negate(is.null), vectorized_args)

   vectorized_args_size <- lapply(args_not_null, length)
   can_expand <- sum(vectorized_args_size > 1) == 1
   can_use <- length(unique(vectorized_args_size)) == 1 # all args have same length

   if (!can_expand & !can_use){
      stop("Ambiguous vectorization: multiple arguments have length > 1: ", call. = FALSE)
   }

   # expand if possible
   if (can_expand){
      args_df <- expand.grid(args_not_null, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
   }

   # split list into multiple list of params
   if (can_use){
      args_df <- as.data.frame(args_not_null, check.names = FALSE)
   }

   args_df <- transform(args_df,
      "source_ign" = toupper(source),
      "_start" = 0,
      "_limit" = 500
   )

   args_list <- split(args_df, seq(nrow(args_df))) |> lapply(as.list)
   resps <- lapply(args_list, fetch_data, type = type, progress = progress)
   result <- lapply(resps, process_responses)

   result <- do.call(rbind, result)
   result <- result[, !sapply(result, is.list)]
   return(result)
}


#' @name fetch_data
#' @noRd
#' @description Fecth data from args
fetch_data <- function(args, type, progress) {

   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/cadastre") |>
      req_url_path_append(type) |>
      req_options(ssl_verifypeer = 0) |>
      req_method("POST") |>
      req_url_query(!!!args)

   error_na_data_found <- paste(
      unlist(args[c("code_insee", "code_dep", "code_com", "section", "numero", "code_arr", "code_abs")]),
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
         warning("No data found for : ", error_na_data_found, call. = F)
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

#' @name ensure_is_not_arr
#' @noRd
#' @description Throw error when insee_code is from citie with arrondissement
ensure_is_not_arr <- function(insee_code){
   arr_to_check <- c(paris = 75056, lyon = 69123, marseille = 13055)
   is_arr <- insee_code %in% arr_to_check
   what_is_arr <- arr_to_check[which(is_arr, arr_to_check)]

   if (any(is_arr)) {
      stop(
         "Codes ", paste(what_is_arr, collapse = ", "),
         " correspond to cities with arrondissements : use arrondissement codes instead.\n",
         "See `subset(happign::com_2025, TYPECOM == \"ARM\")`.",
         call. = FALSE)

   }
}

