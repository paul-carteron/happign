#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_plu(x,
#'                  ressource = "zone-urba",
#'                  partition = NULL,
#'                  timeout = 10)
#'
#' @param x An object of clas `sf` or `sfc`. If NULL, `partition` must be filled by partition of PLU.
#' @param ressource A character from this list : "document", "zone-urba", "secteur-cc", "prescription-surf",
#' "prescription-lin", "prescription-pct", "info-surf", "info-lin", "info-pct". See detail for more info.
#' @param partition A character corresponding to PLU partition (can be retrieve using
#' `get_apicarto_plu(x, "document", partition = NULL)`). If `partition` is explicitely set, all PLU
#' features are returned and `geom` is override
#' @param timeout Time to wait between two request. It's useful when `get_apicarto_plu()` is implemented
#' inside dynamic document. If API doesn't work for some reasons, it will try again (3 times). Be careful,
#' if you're download is longer than `timeout`, the download will not have time to complete
#'
#' @details
#' * `"document'` :
#' * `"zone-urba"` :
#' * `"secteur-cc"` :
#' * `"prescription-surf"` :
#' * `"prescription-lin"` :
#' * `"prescription-pct"` :
#' * `"info-surf"` :
#' * `"info-lin"` :
#' * `"info-pct"` :
#'
#' @importFrom checkmate assert assert_choice check_character check_class check_null
#' @importFrom sf read_sf
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request resp_body_json resp_body_string req_retry req_timeout
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
#' # I recommend to use purrr package for loop
#' library(purrr)
#' all_prescription <- map(.x = ressources,
#'                         .f = ~ get_apicarto_plu(point, .x, partition))
#' }
#'
get_apicarto_plu <- function(x,
                             ressource = "zone-urba",
                             partition = NULL,
                             timeout = 10){

   # Test input values
   assert(check_class(x, "sf"),
          check_class(x, "sfc"),
          check_null(x))
   assert(check_character(partition, pattern = "(?:DU|PSMW)_(?:[0-9])+$"),
          check_null(partition))
   assert_choice(ressource, c("document","zone-urba", "secteur-cc", "prescription-surf",
                               "prescription-lin", "prescription-pct",
                               "info-surf", "info-lin", "info-pct"))

   if (!is.null(partition)){
      x = NULL
   }

   # Create URL
   request <- request("https://apicarto.ign.fr/api/gpu") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_path_append(ressource) %>%
      req_url_query(partition = partition,
                    geom = shp_to_geojson(x)) %>%
      req_retry(3) %>% # Nombre d'essai
      req_timeout(timeout) %>% # Time to wait between two request. Be careful f download is too long. Test down with 1043 feature (partition = "DU_75056", ressources = "zone-urba), 10s looks ok
      req_perform() %>%
      resp_body_string() %>%
      read_sf()

}
