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
get_apicarto_gpu <- function(x,
                             ressource = "zone-urba",
                             categorie = list(NULL),
                             dTolerance = 0){

   # initialisation
   geom <- partition <- insee <- list(NULL)

   # check input ----
   # x
   if (!inherits(x, c("character", "sf", "sfc"))) { # x can have 3 class
      stop("x must be of class character, sf or sfc.")
   }

   # ressource
   match.arg(ressource,
             c("municipality", "document","zone-urba", "secteur-cc", "prescription-surf",
               "prescription-lin", "prescription-pct",
               "info-surf", "info-lin", "info-pct", "acte-sup",
               "assiette-sup-s", "assiette-sup-l", "assiette-sup-p",
               "generateur-sup-s", "generateur-sup-l", "generateur-sup-p"),
             several.ok = TRUE)

   # dTolerance
   bad_dTolerance <- inherits(dTolerance, "numeric") &
      dTolerance < 0
   if (bad_dTolerance) {
      stop("dTolerance must be a positive numeric.")
   }

   # if ressource == acte-sup, x can't be geometry
   if (any(ressource == "acte-sup") & inherits(x, c("sf", "sfc"))){
      stop("geometry can't be used when `ressource = \"acte-sup\"`.",
           " Use partition instead.",
           call. = F)
   }

   # prepare x to request ----
   # spatial object ie geom
   if(inherits(x, c("sf", "sfc"))){
      geom <- shp_to_geojson(x, 4326, dTolerance)
   }

   # character object : partition
   is_partition <- all(inherits(x, "character") & nchar(x) > 5)
   if (is_partition){
      # municipality only used with geom or insee code
      if (any(ressource == "municipality")){
         stop("partition can't be used when `ressource = \"municipality\"`.",
              " Use insee code instead.",
              call. = F)
      }

      # test format of partition
      if (all(incorrect_partition(x))) {
         stop(sprintf("\"%s\" isn't a valid format for `partition`.",
                      paste(x, collapse = "\" or \"")),
              call. = F)
      }

      partition <- x

   }

   # character object : insee code
   is_insee_code <- all(inherits(x, "character") & nchar(x) == 5)
   if (is_insee_code){
      insee <- x
      if(any(ressource != "municipality")){
         stop("insee code can only be used when `ressource = \"municipality\"`.",
              call. = F)
      }
   }

   # hit api ----
   message("Features downloaded : ", appendLF = F)

   tryCatch({
      resp <- Map(build_req_hit_api,
                  path = paste0("/api/gpu/", ressource),
                  "geom" = geom,
                  "partition" = partition,
                  "insee" = insee,
                  "categorie" = categorie)
   }, error = function(cnd){
      if (grepl(cnd, "HTTP 500")) {
         stop(cnd,
              "Apicarto gpu is currently unavailable, please try again later.", call. = F)
      }
   })


   # processing result ----
   if (all(is_empty(unlist(resp)))){
      warning("No data found, NULL is returned.", call. = FALSE)
      return(NULL)
   }

   # bind rows of each Map call
   tryCatch({
      resp <- suppressWarnings(do.call(rbind, resp))
      # Cleaning list column from features
      resp <- resp[ , !sapply(resp, is.list)]
      message(nrow(resp), appendLF = F)

   }, error = function(cnd){
      message(length(resp), appendLF = T)
      warning("Resources have different attributes and cannot be",
              " joined. List is returned.",
              call. = FALSE)
   })

   return(resp)

}

#' @description test partition parameter format from `get_apicarto_gpu`
#' @param x character
#' @return logical
#' @noRd
#'
incorrect_partition <- function(x){

   # see : https://apicarto.ign.fr/api/doc/pdf/docUser_moduleUrbanisme.pdf

   # DU_<codeINSEE> : "DU_93014" (POS, PLU, CC)
   # DU_<codeSIREN> : "DU_200057867" (PLUi)
   pattern1 <- "(?:DU)_(?:\\d{5}|\\d{9})$"

   # PSMV_<codeINSEE> : PSMV_78646 (PSMV)
   pattern2 <- "(?:PSMV)_(?:\\d){5}$"

   # {<idGest>_}SUP_<codeGeo>_<categorie> :
   ## "130007123_SUP_93_A7"
   ## "130007123_SUP_934_A7"
   ## "130007123_SUP_93014_A7"
   ## "SUP_93_A7"
   pattern3 <- "(?:\\d{9}_)?SUP_(?:\\d{2}|\\d{3}|\\d{5})_(?:\\w{2,6})$"

   # if one is FALSE then is incorrect partition
   !c(all(grepl(pattern1, x)),
      all(grepl(pattern2, x)),
      all(grepl(pattern3, x)))

}







