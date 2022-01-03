#' Download WFS layer
#'
#' Directly download a layer from the French National Institute of Geographic and Forestry. To do that, it need a location giving by a shapfile, an apikey thanks to get_apikey and the name of layer thanks to get_layer_metadata,
#'
#' @param shape Object of class sf. Needs to be located in France
#' @param apikey API key from get_apikey() (or directly from the website https://geoservices.ign.fr/services-web-experts)
#' @param layer_name Name of the layer from get_layers_metadata(apikey, "wfs) (or directly from the website https://geoservices.ign.fr/services-web-experts-addAPIkey
#' @export
#'
#' @importFrom sf st_bbox st_transform st_make_valid st_read st_as_sf
#' @importFrom httr modify_url GET content status_code stop_for_status
#' @importFrom dplyr select

get_wfs_layer = function(shape, apikey = "cartovecto", layer_name = "BDCARTO_BDD_WLD_WGS84G:troncon_route"){

   bbox <- NULL

   lapply_function = function(startindex, nb_request, apikey, layer_name, shape){
      cat("Request ",startindex+1,"/",nb_request+1," downloading...\n", sep = "")
      res = st_read(format_url(apikey, layer_name, shape, startindex = 1000*startindex), quiet = TRUE)
   }

   shape = st_make_valid(shape) |>
      st_transform(4326)

   resp = GET(format_url(apikey, layer_name, shape, startindex = 0))

   if (status_code(resp) == 403){
      stop_for_status(resp, task = paste0("find ressource. Check layer_name at https://geoservices.ign.fr/services-web-experts-",apikey))
   }

   nb_features = content(resp)$numberMatched
   if (nb_features == 0){stop("Ressource doesn't exist. Check the shape, it's probably out of France")}

   nb_request = nb_features %/% 1000

   result = lapply(X = 0:nb_request,
                   FUN = lapply_function,
                   nb_request = nb_request,
                   apikey = apikey,
                   layer_name = layer_name,
                   shape = shape) |>
      as.data.frame() |>
      st_as_sf() |>
      st_make_valid() |>
      select(-bbox)
}

format_bbox = function(shape = NULL){
   bbox = st_bbox(shape)
   paste(bbox["xmin"],bbox["ymin"],bbox["xmax"],bbox["ymax"],"epsg:4326", sep = ",")
}
format_url = function(apikey = NULL, layer_name = NULL, shape = NULL, startindex = NULL){

   url <- modify_url("https://wxs.ign.fr",
                     path = paste0(apikey,"/geoportail/wfs"),
                     query = list(SERVICE = "WFS",
                                  VERSION = "2.0.0",
                                  REQUEST = "GetFeature",
                                  outputFormat = "json",
                                  srsName = "EPSG:4326",
                                  typeName = layer_name,
                                  bbox = format_bbox(st_transform(shape,4326)),
                                  startindex = startindex))
   url
}



