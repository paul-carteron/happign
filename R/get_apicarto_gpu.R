#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_gpu(x,
#'                  ressource = "zone-urba",
#'                  categorie = list(NULL),
#'                  dTolerance = 0)
#'
#' @param x An object of class `sf` or `sfc` for geometric intersection. Otherwise
#' a `character` corresponding to __GPU partition__ or
#' __insee code__ when `ressource` is set to `municipality`.
#' @param ressource A character from this list : "document", "zone-urba",
#' "secteur-cc", "prescription-surf", "prescription-lin", "prescription-pct",
#' "info-surf", "info-lin", "info-pct". See detail for more info.
#' @param categorie public utility easement according to the
#' [national nomenclature](https://www.geoportail-urbanisme.gouv.fr/infos_sup/)
#' @param dTolerance numeric; Complex shape cannot be handle by API; using `dTolerance` allow to simplify them. See `?sf::st_simplify`
#'
#' @details
#' **/!\ For the moment the API cannot returned more than 5000 features.**
#'
#' All existing parameters for `ressource` :
#' * "municipality : information on the communes (commune with RNU, merged commune)
#' * "document' : information on urban planning documents (POS, PLU, PLUi, CC, PSMV)
#' * "zone-urba" : zoning of urban planning documents,
#' * "secteur-cc" : communal map sectors
#' * "prescription-surf", "prescription-lin", "prescription-pct" : its's a constraint or a possibility indicated in an urban planning document (PLU, PLUi, ...)
#' * "info-surf", "info-lin", "info-pct" : its's an information indicated in an urban planning document (PLU, PLUi, ...)
#' * "acte-sup" : act establishing the SUP
#' * "generateur-sup-s", "generateur-sup-l", "generateur-sup-p" : an entity (site or monument, watercourse, water catchment, electricity or gas distribution of electricity or gas, etc.) which generates on the surrounding SUP  (of passage, alignment, protection, land reservation, etc.)
#' * "assiette-sup-s", "assiette-sup-l", "assiette-sup-p" : spatial area to which SUP it applies.
#'
#' @return A object of class `sf` or `df`
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' # find if commune is under the RNU (national urbanism regulation)
#' rnu <- get_apicarto_gpu("93014", "municipality")
#' rnu$is_rnu
#'
#' # get urbanism document
#' x <- get_apicarto_cadastre("93014", "commune")
#' document <- get_apicarto_gpu(x, ressource = "document")
#' partition <- document$partition
#'
#' # get gpu features
#' ## from shape
#' gpu <- get_apicarto_gpu(x, ressource = "zone-urba")
#'
#' ## from partition
#' gpu <- get_apicarto_gpu("DU_93014", ressource = "zone-urba")
#'
#' # example : all prescriptions
#' ressources <- c("prescription-surf",
#'                 "prescription-lin",
#'                 "prescription-pct")
#' prescriptions <- get_apicarto_gpu("DU_93014",
#'                                   ressource = ressources)
#'
#' # example : public utility servitude (SUP) assiette
#' assiette_sup_s <- get_apicarto_gpu(x, ressource = "assiette-sup-s")
#' protection_forest <- get_apicarto_gpu(x,
#'                                       ressource = "assiette-sup-s",
#'                                       categorie = "A7")
#'
#' # example : public utility servitude (SUP) generateur
#' ## /!\ a generator can justify several assiette
#' ressources <- c("generateur-sup-p",
#'                 "generateur-sup-l",
#'                 "generateur-sup-s")
#' all_gen <- get_apicarto_gpu(x, ressource = ressources)
#'
#'}
#'

get_gpu_layers <- function(type = NULL){
   ressources <- list(
      "document" = "commune",
      "zone-urba" = "du",
      "secteur-cc" = "du",
      "prescription-surf" = "du",
      "prescription-lin" = "du",
      "prescription-pct" = "du",
      "info-surf" = "du",
      "info-lin" = "du",
      "info-pct" = "du",
      "acte-sup" = "acte-sup",
      "assiette-sup-s" = "sup",
      "assiette-sup-l" = "sup",
      "assiette-sup-p" = "sup",
      "generateur-sup-s" = "sup",
      "generateur-sup-l" = "sup",
      "generateur-sup-p" = "sup"
   )

   if (is.null(type)) return(ressources)

   ressources[ressources %in% type]

}

get_apicarto_gpu(x, layer, category = NULL, progress){

   match.arg(layer, names(get_gpu_layers()), several.ok = TRUE)

   is_geom <- inherits(x, c("sf", "sfc"))
   is_partition <- lapply(x, \(x) is_valid_gpu_partition(x)$valid) |> unlist()
   is_insee_code <- pad0(x, 5) %in% happign::com_2025$COM

   layers_type <- unlist(unique(get_gpu_layers()[layer]))
   is_same_layer_type <- length(layers_type) == 1

   if (!is_same_layer_type){
      stop("`layer` can't mix type `",
           paste(layers_type, collapse = "`, `"),
           "`. See ?get_gpu_layers for more info.",
           call. = FALSE)
   }

   if (is_geom) {
      if (length(st_geometry(x)) > 1) {
         stop("GPU API only accepts one geometry per request. ",
              "You provided ", length(x), " geometries.\n",
              "Use `sf::st_union()` to combine them or split into multiple requests.",
              call. = FALSE)
      }
      if (layer == "acte-sup"){
         stop("`x` can't be an object of class `sf` or `sfc` when `layer` ", "
              == \"acte-sup\". Use partition instead.",
              call. = F)
      }
   }

   if (!is_geom){
      info <- switch(
         type,
         "municipality" = list(validator = is_insee_code,
                               what = "INSEE code(s)",
                               help = "`data(com_2025)`"),
         list(validator = is_partition,
              what = "partition code(s)",
              help = "https://www.geoportail-urbanisme.gouv.fr/image/UtilisationAPI_GPU_1-0.pdf")
      )

      if (!all(info$validator)) {
         bad <- paste(x[!info$validator], collapse = ", ")
         stop(sprintf("Unknown %s: %s. See %s", info$what, bad, info$help), call. = FALSE)
      }
   }

   is_sup <- layers_type == "sup"

   vectorized_args <- list(
      "geom" = if (is_geom) as_geojson(x) else NULL,
      "insee" = if (all(is_insee_code)) x else NULL,
      "partition" = if (all(is_partition)) x else NULL,
      "category" = if (is_sup) category else NULL,
   )

   args_not_null <- Filter(Negate(is.null), vectorized_args)
   args_df <- expand.grid(args_not_null, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)

   args_list <- split(args_df, seq(nrow(args_df))) |> lapply(as.list)
   resps <- lapply(args_list, fetch_gpu_data, type = type, progress = progress)

   result <- lapply(resps, process_gpu_resp)

   result <- do.call(rbind, result)
   result <- result[, !sapply(result, is.list)]

   return(result)
}


#' @name fetch_gpu_data
#' @noRd
#' @description Fecth data from args
fetch_gpu_data <- function(args, type, progress) {

   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/gpu") |>
      req_url_path_append(type) |>
      req_options(ssl_verifypeer = 0) |>
      req_method("POST") |>
      req_url_query(!!!args)

   error_na_data_found <- unlist(args["code_insee"])

   resps <- tryCatch({
      req_perform(req)
      },
      error = function(e) {
      warning("No data found for : ", error_na_data_found, call. = F)
         return(NULL)
      }
   )

   return(resps)
}

#' @name process_gpu_resps
#' @noRd
#' @description Combines all responses in one sf object
process_gpu_resp <- function(resp) {
   res <- resp_body_string(resp) |>
      lapply(read_sf)

   result <- do.call(rbind, res)
   result <- result[, !sapply(result, is.list)]

   return(result)
}


#' @description test partition parameter format from `get_apicarto_gpu`
#' @param x character
#' @return logical
#' @noRd
#'
is_valid_gpu_partition <- function(x) {
   # normalize
   x <- toupper(trimws(x))

   # elementary tokens
   re_insee  <- "[0-9]{5}"                       # commune INSEE
   re_siren  <- "[0-9]{9}"                       # SIREN
   re_codedu <- "[A-Z0-9]+"                      # fallback: CodeDU (alnum)

   # codeGeo: INSEE|dept(2,3 or 2A/2B)|region RXX|FR... (broad)
   re_dept   <- "(?:[0-9]{2}|[0-9]{3}|2A|2B)"
   re_region <- "R[0-9]{2}"
   re_codefr <- "FR[A-Z0-9-]+"
   re_codegeo <- paste0("(?:", re_insee, "|", re_dept, "|", re_region, "|", re_codefr, ")")
   re_catsup <- "[A-Z0-9]+"                      # SUP category (national nomenclature, broad)

   patterns <- list(
      DU_communal          = paste0("^DU_", re_insee, "$"),
      DU_intercommunal     = paste0("^DU_", re_siren, "(?:_", re_codedu, ")?$"),
      PSMV                 = paste0("^PSMV_", re_insee, "(?:_", re_codedu, ")?$"),
      SUP_with_idgest      = paste0("^", re_siren, "_SUP_", re_codegeo, "_", re_catsup, "$"),
      SUP_no_idgest        = paste0("^SUP_", re_codegeo, "_", re_catsup, "$"),
      SCOT                 = paste0("^", re_siren, "_SCOT(?:_", re_codedu, ")?$")
   )

   which_match <- names(patterns)[vapply(patterns, function(p) grepl(p, x, perl = TRUE), logical(1))]
   list(valid = length(which_match) == 1L, type = if (length(which_match)) which_match else NA_character_)
}





