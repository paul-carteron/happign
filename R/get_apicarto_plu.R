#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_plu(x,
#'                  ressource = "zone-urba",
#'                  partition = NULL,
#'                  categorie = NULL)
#'
#' @param x An object of class `sf` or `sfc`. If NULL, `partition` must be filled
#' by partition of PLU.
#' @param ressource A character from this list : "document", "zone-urba",
#' "secteur-cc", "prescription-surf", "prescription-lin", "prescription-pct",
#' "info-surf", "info-lin", "info-pct". See detail for more info.
#' @param partition A character corresponding to PLU partition (can be retrieve
#' using `get_apicarto_plu(x, "document", partition = NULL)`). If `partition`
#' is explicitly set, all PLU features are returned and `geom` is override
#'
#' @details
#' For the moment the API cannot returned more than 5000 features.
#'
#' All resssources description :
#' * `"municipality` : information on the communes (commune with RNU, merged commune)
#' * `"document'` : information on urban planning documents (POS, PLU, PLUi, CC, PSMV)
#' * `"zone-urba"` : zoning of urban planning documents,
#' * `"secteur-cc"` : communal map sectors
#' * `"prescription-surf"` : surface prescriptions like Classified wooded area, Area contributing to the green and blue framework, Landscape element to be protected or created, Protected open space, ...
#' * `"prescription-lin"` : linear prescription like pedestrian path, bicycle path, hedges or tree lines to be protected, ...
#' * `"prescription-pct"` : punctual prescription like Building of architectural interest, Building to protect, Remarkable tree, Protected pools, ...
#' * `"info-surf"` : surface information perimeters of urban planning documents like Protection of drinking water catchments, archaeological sector, noise classification, ...
#' * `"info-lin"` : linear information perimeters of urban planning documents like Bicycle path to be created, Long hike, Façade and/or roof protected as historical monuments, ...
#' * `"info-pct"` : punctual information perimeters of urban planning documents like Archaeological heritage, Listed or classified historical monument, Underground cavity, ...
#'
#' @importFrom checkmate assert assert_choice check_character check_class check_null
#' @importFrom sf read_sf
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request resp_body_json resp_body_string
#' @importFrom geojsonsf sf_geojson geojson_sf
#'
#' @return A object of class `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(tmap)
#' library(sf)
#' point <- st_sfc(st_point(c(-0.4950188466302029, 45.428039987269926)), crs = 4326)
#'
#' # If you know the partition (all PLU features are returned, geom is override)
#' partition <- "DU_17345"
#' poly <- get_apicarto_plu(x = NULL, ressource = "zone-urba", partition = partition)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you don't know partition (only intersection between geom and PLU features is returned)
#' poly <- get_apicarto_plu(x = point, ressource = "zone-urba", partition = NULL)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you wanna find partition
#' document <- get_apicarto_plu(point, ressource = "document", partition = NULL)
#' partition <- unique(document$partition)
#'
#' # Get all prescription : /!\ prescription is different than zone-urba
#' partition <- "DU_17345"
#' ressources <- c("prescription-surf", "prescription-lin", "prescription-pct")
#'
#' library(purrr)
#' all_prescription <- map(.x = ressources,
#'                         .f = ~ get_apicarto_plu(point, .x, partition))
#' }
#'
get_apicarto_plu <- function(x,
                             ressource = "zone-urba",
                             partition = NULL,
                             categorie = NULL){

   # Test input values
   assert(check_class(x, "sf"),
          check_class(x, "sfc"),
          check_null(x))
   assert(check_character(partition, pattern = "(?:DU|PSMW)_(?:[0-9])+$"),
          check_null(partition))
   assert_choice(ressource, c("document","zone-urba", "secteur-cc", "prescription-surf",
                              "prescription-lin", "prescription-pct",
                              "info-surf", "info-lin", "info-pct", "acte-sup",
                              "assiette-sup-s", "assiette-sup-l", "assiette-sup-p",
                              "generateur-sup-s", "generateur-sup-l", "generateur-sup-p"))

   if (!is.null(partition)){
      x <- NULL
   }

   if ("sf" %in% class(x)){
      x <- st_as_sfc(x)
   }

   param <- list(
      geom = sfc_geojson(st_make_valid(x)),
      partition = partition,
      categorie = categorie,
      startindex = 0
   )

   # When start parameter will appear im prepare
   # res <- NULL
   # i <- 0
   #
   # while(length(res) == 5000){
   #    res <- hit_api(ressource, param)
   #    res <- rbind(res)
   #    i <- i + 5000
   # }

   res <- hit_api(param, ressource)
   return(res)

}
#' format url and request it
#' @param ressource name of ressource you want
#' @param param liste of param for hitting API
#' @noRd
hit_api <- function(ressource, param){

   req <- request("https://apicarto.ign.fr/api/gpu") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_path_append(ressource) %>%
      req_url_query(!!!param) %>%
      req_perform() %>%
      resp_body_string() %>%
      read_sf()

   return(req)
}

