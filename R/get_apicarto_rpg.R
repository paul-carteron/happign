#' Apicarto RPG (Registre Parcellaire Graphique)
#'
#' Implementation of the "RPG" module from the
#' [IGN's apicarto](https://apicarto.ign.fr/api/doc/rpg). This function
#' is a wrapper around version 1 and 2 of the API.
#'
#' @usage
#' get_apicarto_rpg(x,
#'                  annee,
#'                  code_cultu = NULL,
#'                  dTolerance = 0L,
#'                  progress = TRUE)
#'
#' @param x Object of class `sf`. Needs to be located in France.
#' @param annee numeric between 2010 and 2023.
#' @param code_cultu character corresponding to code culture, see detail.
#' @param dTolerance numeric; tolerance parameter. The value of `dTolerance`
#' must be specified in meters, see detail.
#' @param progress Display a progress bar? Use TRUE to turn on a basic progress
#' bar, use a string to give it a name. See [httr2::req_perform_iterative()].
#'
#' @details
#' Since 2014 the culture code has changed its format. Before it should be
#' a value ranging from "01" to "28", after it should be a trigram (ex : "MIE").
#' More info can be found at the
#' [documentation page](https://apicarto.ign.fr/api/doc/pdf/docUser_moduleRPG.pdf)
#'
#' `dTolerance` is needed when geometry are too complex. Its the same parameter
#'  found in `sf::st_simlplify`.
#'
#' @return `list` or object of class `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' penmarch <- get_apicarto_cadastre("29158", type = "commune")
#'
#' # failure with too complex geom
#' rpg <- get_apicarto_rpg(st_buffer(penmarch, 10), 2020)
#'
#' # avoid complex data by setting dTolerance
#' rpg <- get_apicarto_rpg(penmarch, 2020, dTolerance = 15)
#'
#' # multiple years after 2014
#' rpg <- get_apicarto_rpg(penmarch, 2020:2021, dTolerance = 15)
#'
#' # years before and after 2014
#' # list is returned because attributs are different
#' rpg <- get_apicarto_rpg(penmarch, c(2010, 2021), dTolerance = 15)
#'
#' # filter by code_cultu
#' rpg <- get_apicarto_rpg(penmarch, 2021, code_cultu = "MIE", dTolerance = 15)
#'
#' # all "MIE" from 2020 and all "PPH" from 2021
#' rpg <- get_apicarto_rpg(penmarch, 2020:2021,
#'                         code_cultu = c("MIE", "PPH"),
#'                         dTolerance = 15)
#'
#' # vectorization : all "MIE" from 2020 and 2021
#' rpg <- get_apicarto_rpg(x, 2020:2021, code_cultu = "MIE", dTolerance = 15)
#'}
#'
#' @name get_apicarto_rpg
#' @export
#'

get_apicarto_rpg <- function(x,
                             annee,
                             code_cultu = NULL,
                             dTolerance = 0L,
                             progress = FALSE){

   # check parameter : x
   if (!inherits(x, c("sf", "sfc"))) { # x can have 3 class
      stop("Input 'x' must be of class 'sf' or 'sfc'")
   }

   # check parameter : annee
   year_range <- 2010:2023
   if (!all(annee %in% year_range)){
      stop(sprintf("Input 'annee' must be between %s and %s.",
           min(year_range),
           max(year_range)))
   }

   # deal with changement of api path before and after 2014
   version <- ifelse(annee <= 2014, "v1", "v2")

   geom <- get_geojson(x, dTolerance)

   params <- create_rpg_params(annee, geom, code_cultu, version)
   resps <- lapply(params, fetch_rpg_data, progress)

   if (all(sapply(resps, is.null))) {
      warning("No data found, NULL is returned.")
      return(NULL)
   }

   result <- process_rpg_responses(resps, annee)

   return(result)
}

#' @name create_rpg_params
#' @noRd
#' @description Create parameters for RPG API request
create_rpg_params <- function(annee, geom, code_cultu, version) {
   create_single_rpg_params <- function(annee, geom, code_cultu, version) {
      params <- list(
         "annee" = annee,
         "geom" = geom,
         "code_cultu" = code_cultu,
         "version" = version
      )
      return(params)
   }


   all_params <- Map(
      create_single_rpg_params,
      if (is.null(annee)) NULL else annee,
      if (is.null(geom)) list(NULL) else geom,
      if (is.null(code_cultu)) list(NULL) else code_cultu,
      if (is.null(version)) list(NULL) else version
      )

   return(all_params)
}

#' @name fetch_rpg_data
#' @noRd
#' @description Fecth data from params
fetch_rpg_data <- function(params, progress) {
   # version is used for creating url, and should be dynamic if there before and
   # after 2014 request.
   # It's then removed to use query params as !!!params
   version <- params$version
   params$version <- NULL

   req <- request("https://apicarto.ign.fr") |>
      req_url_path("api/rpg") |>
      req_url_path_append(version) |>
      req_options(ssl_verifypeer = 0) |>
      req_url_query(!!!params)

   resps <- tryCatch({
      req_perform_iterative(
         req,
         next_req = iterate_with_offset(
            "_start",
            start = 0,
            offset = 1000,
            resp_pages = function(resp) {
               total_features <- resp_body_json(resp)$totalFeatures
               ceiling(total_features / 1000)  # Calculate the number of pages
            }
         ),
         max_reqs = Inf,
         progress = progress
      )
   }, error = function(e) {
      if (grepl("URI Too Long", e$message)) {
         stop("Shape is too complex. \nTry increase `dTolerance` parameter.", call. = F)
      } else if (grepl("whole number", e$message)) {
         warning("No data found for", call. = F)
         return(NULL)
      } else {
         stop(e)  # Re-throw the original error if no condition matches
      }
   })

   return(resps)
}

#' @name process_rpg_responses
#' @noRd
#' @description Process the RPG API responses and combine them into an `sf` object
process_rpg_responses <- function(resps, annee) {
   if (all(is.null(resps))) {
      warning("No valid responses to process.")
      return(NULL)
   }

   result <- resps |>
      unlist(recursive = F) |>
      resps_data(\(resp) resp_body_string(resp)) |>
      lapply(read_sf)

   names(result) <- annee
   result <- mapply(cbind, result, "annee" = annee, SIMPLIFY = FALSE)

   tryCatch({
      result <- do.call(rbind, result)
      result <- result[, !sapply(result, is.list)]  # Remove list columns
   }, error = function(cnd) {
      warning("Data before and after 2014 are different, returning as list.",
              call. = F)
      return(result)
   })

   return(result)
}
