#' Apicarto module Geoportail de l'urbanisme
#'
#' @usage
#' get_apicarto_plu (x,
#'                   ressource = "zone-urba",
#'                   partition = NULL)
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
#' # If you know the partition
#' partition <- "DU_17345"
#' poly <- get_apicarto_plu(x = NULL, ressource = "zone-urba", partition = partition)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you don't know partition
#' poly <- get_apicarto_plu(x = point, ressource = "zone-urba", partition = "auto")
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # If you wanna find partition
#' document <- get_apicarto_plu(point, ressource = "document", partition = NULL)
#' partition <- unique(document$partition)
#'
#' # If you want only intersection between you're shape and PLU
#' poly <- get_apicarto_plu(point, ressource = "zone-urba", partition = NULL)
#' qtm(poly)+qtm(point, symbols.col = "red", symbols.size = 2)
#'
#' # Get all prescription : /!\ prescription is different than zone-urba
#'
#' partition <- "DU_17345"
#' ressources <- c("prescription-surf", "prescription-lin", "prescription-pct")
#' res <- list()
#' for (i in 1:3){
#'     res_temp <- get_apicarto_plu(x, ressources[i], partition)
#'     res[[i]] <- res_temp
#' }
#'
#'
#' }
#'
#'
get_apicarto_plu <- function(x,
                             ressource = "zone-urba",
                             partition = NULL){

   # Test input values
   assert(check_class(x, "sf"),
          check_class(x, "sfc"),
          check_null(x))
   assert(check_character(partition, pattern = "auto"),
          check_character(partition, pattern = "(?:DU|PSMW)_(?:[0-9]{5})$"),
          check_null(partition))
   assert_choice(ressource, c("document","zone-urba", "secteur-cc", "prescription-surf",
                               "prescription-lin", "prescription-pct",
                               "info-surf", "info-lin", "info-pct"))


   find_PLU_partition <- function(geom){
      resp <- request("https://apicarto.ign.fr/api/gpu/document") %>%
         req_url_query(geom = shp_to_geojson(x)) %>%
         req_perform() %>%
         resp_body_json()

      partition <- resp[["features"]][[1]][["properties"]][["partition"]]

   }

   # Avoid problem when partition == NULL in if statement
   partition <- switch(class(partition),
                       "NULL" = NULL,
                       "character" = ifelse(partition == "auto",
                                            find_PLU_partition(x),
                                            partition))

   if (is.character(partition)){
      x <- NULL
   }

   # Create URL
   request <- request("https://apicarto.ign.fr/api/gpu") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_path_append(ressource) %>%
      req_url_query(partition = partition, geom = shp_to_geojson(x)) %>%
      req_perform() %>%
      resp_body_string() %>%
      read_sf()

}

