#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_gpu(x, layer, category = NULL)
#'
#' @param x `sf`, `sfc` or `character` :
#' * Shape : must be an object of class `sf` or `sfc`.
#' * Code insee (layer = `"municipality"`) : must be a `character` of length 5 (see [happign::com_2025])
#' * Partition : must be a valid partition `character` (see [happign::is_valid_gpu_partition()]
#' for checking and
#' [Geoportail](https://www.geoportail-urbanisme.gouv.fr/image/UtilisationAPI_GPU_1-0.pdf")
#' for documentation
#' @param layer `character`; Layer name from [happign::get_gpu_layers()]
#' @param category public utility easement according to the
#' [national nomenclature](https://www.geoportail-urbanisme.gouv.fr/infos_sup/)
#'
#' @details
#' **/!\ API cannot returned more than 5000 features.**
#'
#' All existing parameters for `layer` :
#' * `"municipality"` : information on the communes (commune with RNU, merged commune)
#' * `"document"` : information on urban planning documents (POS, PLU, PLUi, CC, PSMV, SCoT)
#' * `"zone-urba"` : zoning of urban planning documents,
#' * `"secteur-cc"` : communal map sectors
#' * `"prescription-surf"`, `"prescription-lin"`, `"prescription-pct"` : its's
#' a constraint or a possibility indicated in an urban planning document (PLU, PLUi, ...)
#' * `"info-surf"`, `"info-lin"`, `"info-pct"` : its's an information indicated
#' in an urban planning document (PLU, PLUi, ...)
#' * `"acte-sup"` : act establishing the SUP
#' * `"generateur-sup-s"`, `"generateur-sup-l"`, `"generateur-sup-p"` : an
#' entity (site or monument, watercourse, water catchment, electricity or gas
#' distribution of electricity or gas, etc.) which generates on the surrounding
#' SUP  (of passage, alignment, protection, land reservation, etc.)
#' * `"assiette-sup-s"`, `"assiette-sup-l"`, `"assiette-sup-p"` : spatial area
#' to which SUP it applies.
#'
#' @return `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # Find if commune is under the RNU (national urbanism regulation)
#' # If no RNU it means communes probably have a PLU
#' rnu <- get_apicarto_gpu("29158", "municipality")
#' rnu$is_rnu
#'
#' # Get urbanism document
#' # Rq : when using geometry, multiple documents can be returned due to intersection
#' x <- get_apicarto_cadastre("29158", "commune")
#' document <- get_apicarto_gpu(x, "document")
#' document$partition
#' penmarch <- document$partition[2]
#'
#' # get gpu features
#' ## from shape
#' gpu <- get_apicarto_gpu(x, "zone-urba")
#' qtm(gpu, fill="typezone")
#'
#' ## from partition
#' gpu <- get_apicarto_gpu(penmarch, "zone-urba")
#' qtm(gpu, fill="typezone")
#'
#' # example : all prescription
#' layers <- names(get_gpu_layers("prescription"))
#' prescriptions <- lapply(layers, \(x) get_apicarto_gpu(penmarch, x)) |>
#'    setNames(layers)
#'
#' qtm(prescriptions$`prescription-pct`, fill = "libelle")+
#' qtm(prescriptions$`prescription-lin`, col = "libelle")+
#' qtm(prescriptions$`prescription-surf`, fill = "libelle")
#'
#' # When using SUP, category can be used for filtering
#' # AC1 : Monuments historiques
#' penmarch <- get_apicarto_cadastre(29158)
#' mh <- get_apicarto_gpu(penmarch, "assiette-sup-s", category = "AC1")
#'
#' # example : public utility servitude (SUP) generateur
#' ## /!\ a generator can justify several assiette
#' gen_mh <- get_apicarto_gpu(penmarch, "generateur-sup-s", "AC1")
#'
#' qtm(mh, fill = "lightblue")+qtm(gen_mh, fill = "red")
#'
#'}
#'
get_apicarto_gpu <- function(x, layer, category = NULL){

   layer <- match.arg(layer, names(get_gpu_layers()), several.ok = TRUE)

   if (length(layer) != 1){
      stop("`layer` can't have multiple argument",
           ". See ?get_gpu_layers for available layers.",
           call. = FALSE)
   }

   is_geom <- inherits(x, c("sf", "sfc"))
   is_partition <- if (!is_geom) lapply(x, \(x) is_valid_gpu_partition(x)$valid) |> unlist() else NULL
   is_insee_code <- if (!is_geom) pad0(x, 5) %in% happign::com_2025$COM else NULL
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
      info <- list(validator = is_partition,
                   what = "partition code(s)",
                   help = "https://www.geoportail-urbanisme.gouv.fr/image/UtilisationAPI_GPU_1-0.pdf")

      is_municipality <- all(layer == "municipality")
      if (is_municipality){
         info <- list(validator = is_insee_code,
                      what = "INSEE code(s)",
                      help = "`data(com_2025)`")
      }


      if (!all(info$validator)) {
         bad <- paste(x[!info$validator], collapse = ", ")
         stop(sprintf("Unknown %s: %s. See %s", info$what, bad, info$help), call. = FALSE)
      }
   }

   is_sup <- layer %in% names(get_gpu_layers(c("acte-sup", "assiette", "generateur")))

   vectorized_args <- list(
      "geom" = if (is_geom) as_geojson(x) else NULL,
      "insee" = if (all(is_insee_code) && !is_geom) x else NULL,
      "partition" = if (all(is_partition) && !is_geom) x else NULL,
      "categorie" = if (is_sup) category else NULL
   )

   args_not_null <- Filter(Negate(is.null), vectorized_args)
   args_df <- expand.grid(args_not_null, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)

   args_list <- split(args_df, seq(nrow(args_df))) |> lapply(as.list)
   resps <- lapply(args_list, fetch_gpu_data, layer = layer)

   result <- lapply(resps, \(x) resp_body_string(x) |> read_sf())
   result_not_null <- Filter(\(x) !is_empty(x), result)

   if (length(result_not_null) == 0){
      warning("No data found, NUll is returned", call. = FALSE)
      return(NULL)
   }

   result <- do.call(rbind, result)
   result <- result[, !sapply(result, is.list)]

   return(result)
}

#' Available GPU layers
#'
#' Helpers that return available GPU layers and their type.
#'
#' @usage get_gpu_layers(type = NULL)
#'
#' @param type `character` One of `"commune"`, `"du"`, `"prescription"`,
#' `"acte-sup"`, `"assiette"`, `"generateur"`.
#' If `NULL`, all layers are retuned. `NULL` by default
#'
#' @details
#' `"du"`: "Document d'urbanisme"
#' `"sup"`: "Servitude d'utilité publique"
#'
#' @return list
#'
#' @export
#'
#' @examples
#' # All layers
#' names(get_gpu_layers())
#'
#' # All sup layers
#' names(get_gpu_layers("generateur"))
#'
#' # All sup and du layers
#' names(get_gpu_layers(c("generateur", "prescription")))
#'
get_gpu_layers <- function(type = NULL){

   layers <- list(
      "municipality" = "commune",
      "document" = "du",
      "zone-urba" = "du",
      "secteur-cc" = "du",
      "prescription-surf" = "prescription",
      "prescription-lin" = "prescription",
      "prescription-pct" = "prescription",
      "info-surf" = "info",
      "info-lin" = "info",
      "info-pct" = "info",
      "acte-sup" = "acte-sup",
      "assiette-sup-s" = "assiette",
      "assiette-sup-l" = "assiette",
      "assiette-sup-p" = "assiette",
      "generateur-sup-s" = "generateur",
      "generateur-sup-l" = "generateur",
      "generateur-sup-p" = "generateur"
   )

   if (is.null(type)) return(layers)

   type <- match.arg(type, unique(layers), several.ok = TRUE)
   layers[layers %in% type]

}


#' @name fetch_gpu_data
#' @noRd
#' @description Fecth data from args
fetch_gpu_data <- function(args, layer) {

   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/gpu") |>
      req_url_path_append(layer) |>
      req_options(ssl_verifypeer = 0) |>
      req_body_json(args)

   resps <- tryCatch({
      req_perform(req)
      },
      error = function(e) {
         warning("No data found, NUll is returned", call. = FALSE)
         return(NULL)
      }
   )

   return(resps)
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





