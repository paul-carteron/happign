#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_gpu(x,
#'                  ressource = "zone-urba",
#'                  partition = NULL)
#'
#' @param x An object of clas `sf` or `sfc`. If NULL, `partition` must be filled
#' by partition of GPU.
#' @param ressource A character from this list : "document", "zone-urba",
#' "secteur-cc", "prescription-surf", "prescription-lin", "prescription-pct",
#' "info-surf", "info-lin", "info-pct". See detail for more info.
#' @param partition A character corresponding to GPU partition (can be retrieve
#' using `get_apicarto_gpu(x, "document", partition = NULL)`). If `partition`
#' is explicitely set, all GPU features are returned and `geom` is override
#'
#' @details
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
#' * `"acte-sup"` : the Servitudes of Public Utility (SUP) affect the use of the grounds according to the administrative limitations to the right of ownership
#' * `"assiette-sup-s"` :  Protected area, historical monument, risk prevention plan perimeter, ...
#' * `"assiette-sup-l"` : No example
#' * `"assiette-sup-p"` : No example
#' * `"generateur-sup-s"` : National Park, Forest, Monument, Site, ...
#' * `"generateur-sup-l"` : Waterways, Supports and Cables, ...
#' * `"generateur-sup-p"` : No example
#'
#' @importFrom checkmate assert assert_choice check_character check_class check_null
#' @importFrom sf read_sf
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request resp_body_json resp_body_string
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
#' # If you know the partition (all GPU features are returned, geom is override)
#' partition <- "DU_17345"
#' poly <- get_apicarto_gpu(x = NULL, ressource = "zone-urba", partition = partition)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you don't know partition (only intersection between geom and GPU features is returned)
#' poly <- get_apicarto_gpu(x = point, ressource = "zone-urba", partition = NULL)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you wanna find partition
#' document <- get_apicarto_gpu(point, ressource = "document", partition = NULL)
#' partition <- unique(document$partition)
#'
#' # Get all prescription : /!\ prescription is different than zone-urba
#' partition <- "DU_17345"
#' ressources <- c("prescription-surf", "prescription-lin", "prescription-pct")
#'
#' # I recommend to use purrr package for loop
#' library(purrr)
#' all_prescription <- map(.x = ressources,
#'                         .f = ~ get_apicarto_gpu(point, .x, partition))
#' }
#'
get_apicarto_gpu <- function(x,
                             ressource = "zone-urba",
                             partition = NULL){

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

   # Create URL
   request <- request("https://apicarto.ign.fr/api/gpu") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_path_append(ressource) %>%
      req_url_query(partition = partition,
                    geom = shp_to_geojson(x)) %>%
      req_perform() %>%
      resp_body_string() %>%
      read_sf()

}
