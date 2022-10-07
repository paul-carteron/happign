#' Download WFS layer
#'
#' Directly download a shapefile layer from the French National Institute
#' of Geographic and Forestry. To do that, it need a location giving by
#' a shapefile, an apikey and the name of layer. You can find those
#' information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @usage
#' get_wfs(shape,
#'         apikey,
#'         layer_name,
#'         filename = NULL,
#'         interactive = FALSE)
#'
#' @param shape Object of class `sf`. Needs to be located in
#' France.
#' @param apikey API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from `get_layers_metadata(apikey, "wfs")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param filename Either a character string naming a file or a connection open
#' for writing. (ex : "test.shp" or "~/test.shp")
#' @param interactive if set to TRUE, no need to specify `apikey` and `layer_name`, you'll be ask.
#'
#' @return
#' `get_wfs`return an object of class `sf`
#'
#' @export
#'
#' @importFrom sf read_sf st_bbox st_make_valid st_transform st_write st_sf st_point
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent
#' request resp_body_json resp_body_string
#' @importFrom checkmate assert assert_character check_character
#' check_class check_null
#' @importFrom utils menu
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # Get the borders of best town in France --------------------
#'
#' apikey <- get_apikeys()[1]
#' metadata_table <- get_layers_metadata(apikey, "wfs")
#' layer_name <- as.character(metadata_table[32,1])
#'
#' # One point from the best town in France
#' shape <- st_point(c(-4.373937, 47.79859))
#' shape <- st_sfc(shape, crs = st_crs(4326))
#'
#' # Download borders
#' borders <- get_wfs(shape, apikey, layer_name)
#'
#' # Verif
#' tmap_mode("view") # easy interactive map
#' qtm(borders, fill = NULL, borders = "firebrick") # easy map
#'
#' # Get forest_area of the best town in France ----------------
#' forest_area <- get_wfs(shape = borders,
#'                        apikey = get_apikeys()[9],
#'                        layer_name = "LANDCOVER.FORESTINVENTORY.V1:resu_bdv1_shape")
#'
#' # Verif
#' qtm(forest_area, fill = "libelle")
#'
#' # Get roads of the best town in France ----------------------
#' roads <- get_wfs(shape = borders,
#'                  apikey = "cartovecto",
#'                  layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route")
#'
#' # Verif
#' qtm(roads)
#'
#' }
get_wfs <- function(shape,
                    apikey = "cartovecto",
                    layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route",
                    filename = NULL,
                    interactive = FALSE){

   # Rewrite apikey and layer_name with interactive session
   if (interactive){
      apikeys <- get_apikeys()
      apikey <- apikeys[menu(apikeys)]

      layers <- get_layers_metadata(apikey, data_type = "wfs")$Name
      layer_name <- layers[menu(layers)]
   }

   # Check input parameter
   assert(check_class(shape, "sf"),
          check_class(shape, "sfc"))
   assert_character(apikey, max.len = 1)
   assert_character(layer_name, max.len = 1)
   assert(check_character(filename, max.len = 1),
          check_null(filename))

   # Allow 1 hour long downloading
   default <- options("timeout")
   options("timeout" = 3600)
   on.exit(options(default))

   # Looping because length of request is limited to 1000
   shape <- st_make_valid(shape)

   res <- hit_api_wfs(shape, apikey, layer_name, startindex = 0)
   message("Features downloaded : ", nrow(res), appendLF = F)

   i <- 1000
   res_temp <- res
   while(nrow(res_temp) == 1000){
      message("...", appendLF = F)
      res_temp <- hit_api_wfs(shape, apikey, layer_name, startindex = i)
      res <- rbind(res, res_temp)
      message(nrow(res), appendLF = F)
      i <- i + 1000
   }
   message("\n")
   # Cleaning list column from features
   res <- res[ , !sapply(res, is.list)]

   # Saving file
   if (!is.null(filename)) {
      path <- normalizePath(filename, mustWork = FALSE)
      path <- enc2utf8(path)

      if (sum(nchar(names(res))>10) > 1){
         st_write(res, sub("\\.[^.]*$", ".gpkg", path))
         message("Some variables names are more than 10 character so .gpkg format is used.")
      }else{
         st_write(res, path, append = FALSE)

      }
   }

   # Returned empty geometry if no features returned
   if (dim(res)[1] == 0){
      res <- st_sf(st_sfc(st_point()))
      warning("No features find, an empty point geometry is returned.")
   }

  return(res)
}

#' format url and request it
#' @param apikey API key from `get_apikeys()`
#' @param shape Object of class `sf`. Needs to be located in France.
#' @param layer_name Name of the layer
#' @param startindex startindex for features returned limit
#' @noRd
#'
hit_api_wfs <- function(shape, apikey, layer_name, startindex = 0) {

   bbox <- st_bbox(st_transform(shape, 4326))
   formated_bbox <- paste(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          "epsg:4326",
                          sep = ",")

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      srsName = "EPSG:4326",
      typeName = layer_name,
      bbox = formated_bbox,
      startindex = startindex,
      count = 1000
   )

   request <- request("https://wxs.ign.fr") %>%
      req_url_path_append(apikey) %>%
      req_url_path_append("geoportail/wfs") %>%
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
      req_url_query(!!!params) %>%
      req_perform() %>%
      resp_body_string() %>%
      read_sf()
}
