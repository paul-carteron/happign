#' Apicarto module Géoportail de l'urbanisme
#'
#' TO DO DESCRIPTION & USAGE
#'
#' @param x An object of clas `sf` or `sfc`. If NULL, `partition` must be filled by partition of PLU.
#' @param ressource A character from this list : "document", "zone-urba", "secteur-cc", "prescription-surf",
#' "prescription-lin", "prescription-pct", "info-surf", "info-lin", "info-pct". See detail for more info.
#' @param partition A character corresponding to PLU partition (can be retrieve using
#' `get_apicarto_plu(x, "document", partition = NULL)`). If partition, is not known, it can be set to
#' `"auto"`. In this case all PLU from the commune is downloaded. If it's set to NULL, only PLU
#' features intersecting `x` are downloaded.
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
#' @importFrom checkmate assert assert_choice check_character check_class
#' @importFrom sf read_sf
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request resp_body_json
#'
#' @return A object of class `sf`
#' @export
#'
#' @examples
#' \dontrun{
#' library(tmap)
#' library(sf)
#' point <- st_sfc(st_point(c(-0.4950188466302029, 45.428039987269926)), crs = 4326)
#' }
#'
get_apicarto_plu <- function(x = NULL,
                             ressource = "zone-urba",
                             partition = "auto"){

   # Test input values
   assert(check_class(x, "sf"),
          check_class(x, "sfc"))
   assert(check_character(partition, pattern = "auto"),
          check_character(partition, pattern = "(?:DU|PSMW)_(?:[0-9]{5})$"))
   assert_choice(ressource, c("zone-urba", "secteur-cc", "prescription-surf",
                               "prescription-lin", "prescription-pct",
                               "info-surf", "info-lin", "info-pct"))

   if (partition == "auto"){
      resp <- request("https://apicarto.ign.fr/api/gpu/document") %>%
         req_url_query(geom = shp_to_geojson(x)) %>%
         req_perform() %>%
         resp_body_json()

      partition <- resp[["features"]][[1]][["properties"]][["partition"]]
   }

   if (is.character(partition)){
      x <- NULL
   }

   # Create URL
   request <- request("https://apicarto.ign.fr/api/gpu") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_path_append(ressource) %>%
      req_url_query(partition = partition, geom = shp_to_geojson(x))

   shp <- read_sf(request$url)

}
