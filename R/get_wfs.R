#' @title Download WFS layer
#'
#' @description
#' Read simple features from IGN Web Feature Service (WFS).
#' Three minimal info are needed : a location, an apikey
#' and the name of layer. You can find those information from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#'
#' @usage
#' get_wfs(x = NULL,
#'         apikey = NULL,
#'         layer = NULL,
#'         filename = NULL,
#'         spatial_filter = "bbox",
#'         ecql_filter = NULL,
#'         overwrite = FALSE,
#'         interactive = FALSE)
#'
#' @param x Object of class `sf` or `sfc`. Needs to be located in
#' France.
#' @param apikey `character`; API key from `get_apikeys()` or directly
#' from [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param layer `character`; name of the layer from `get_layers_metadata(apikey, "wfs")`
#' or directly from
#' [IGN website](https://geoservices.ign.fr/services-web-experts)
#' @param filename Either a character string naming a file or a connection open
#' for writing. (ex : "test.shp" or "~/test.shp")
#' @param spatial_filter `character`; spatial predicate from ECQL language.
#' See detail and examples for more info.
#' @param ecql_filter `character`; corresponding to an ECQL query.
#' See detail and examples for more info.
#' @param overwrite `logical`; if TRUE, file is overwrite.
#' @param interactive `character`; if TRUE, no need to specify `apikey`
#' and `layer`, you'll be ask.
#'
#' @return
#' `sf` object from `sf` package or `NULL` if no data.
#'
#' @export
#'
#' @importFrom sf read_sf st_make_valid st_write
#' @importFrom httr2 req_perform req_url_path_append req_url_query req_user_agent request
#' resp_body_string req_body_form
#' @importFrom utils menu
#'
#' @details
#' * `get_wfs` use ECQL language : a query language created by the OpenGeospatial Consortium.
#' It provide multiple spatial filter : "intersects", "disjoint", "contains", "within", "touches",
#' "crosses", "overlaps", "equals", "relate", "beyond", "dwithin". For "relate", "beyond",
#' "dwithin", argument can be provide using vector like :
#' spatial_filter = c("dwithin", distance, units). More info about ECQL language
#' [here](https://docs.geoserver.org/latest/en/user/filter/ecql_reference.html).
#' Be aware that "dwithin" is broken and it doesn't accept units properly. Only degrees can be used.
#' To avoid this, create a buffer and then use "within" instead od "dwithin".
#' * ECQL query can be provided to `ecql_filter`. This allows direct query of the IGN's WFS
#' geoservers. If `x` is set, then the `ecql_filter` comes in addition to the
#' `spatial_filter`. More info for writing ECQL
#' [here](https://docs.geoserver.org/latest/en/user/tutorials/cql/cql_tutorial.html)
#'
#' @seealso
#' [get_apikeys()], [get_layers_metadata()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # shape from the best town in France
#' penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # For quick testing, use interactive = TRUE
#' shape <- get_wfs(x = penmarch,
#'                  interactive = TRUE)
#'
#' # For specific use, choose apikey with get_apikey() and layer with get_layers_metadata()
#' ## Getting borders of best town in France
#' apikey <- get_apikeys()[1]
#' metadata_table <- get_layers_metadata(apikey, "wfs")
#' layer <- metadata_table[32,1]
#'
#' # Downloading borders
#' borders <- get_wfs(penmarch, apikey, layer)
#'
#' # Plotting result
#' qtm(borders, fill = NULL, borders = "firebrick") # easy map
#'
#' # Get forest_area of the best town in France
#' forest_area <- get_wfs(x = borders,
#'                        apikey = "environnement",
#'                        layer = "LANDCOVER.FORESTINVENTORY.V1:resu_bdv1_shape")
#'
#' qtm(forest_area, fill = "libelle")
#'
#' # using ECQL filters to query IGN server
#'
#' # find all commune's name starting by "plou".
#' # First you need the name of the attribute to filter
#' names(borders) # In our case "nom_m" is what we need
#'
#' attribute_name <- names(get_wfs(penmarch,apikey, layer))
#' plou_borders <- get_wfs(x = NULL, # When x is NULL, all France is query
#'                         apikey = "administratif",
#'                         layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
#'                         ecql_filter = "nom_m LIKE 'PLOU%'")
#'
#' # it's also possible to combine ecql_filter
#' plou_borders <- get_wfs(x = NULL, # When x is NULL, all France is query
#'                         apikey = "administratif",
#'                         layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
#'                         ecql_filter = "nom_m LIKE 'PLOU%' AND population < 2000")
#'
#'
#' }
get_wfs <- function(x = NULL,
                    apikey = NULL,
                    layer = NULL,
                    filename = NULL,
                    spatial_filter = "bbox",
                    ecql_filter = NULL,
                    overwrite = FALSE,
                    interactive = FALSE){

   # check input ----
   ## x
   if (!inherits(x, c("sf", "sfc", "NULL"))){
      stop("`x` should have class `sf`, `sfc` or `NULL` if `ecql_filter` is set.",
           call. = FALSE)
   }

   if (!is.null(x)){
      x <- st_make_valid(x)
   }

   ## spatial_filter
   if(!is.null(spatial_filter)){
      spatial_predicate <- c("INTERSECTS", "DISJOINT", "CONTAINS", "WITHIN", "TOUCHES", "BBOX",
                             "CROSSES", "OVERLAPS", "EQUALS", "RELATE", "DWITHIN", "BEYOND")

      is_valid_predicate <- is.element(toupper(spatial_filter[1]), spatial_predicate)
      if (!is_valid_predicate){
         stop("`spatial_filter` should be one of : ",
              paste0(spatial_predicate, collapse =", "), call. = FALSE)
      }
   }


   # interactive session ----
   if (interactive){
      apikeys <- get_apikeys()
      apikey <- apikeys[menu(apikeys)]

      layers <- get_layers_metadata(apikey, data_type = "wfs")$Name
      layer <- layers[menu(layers)]
   }

   # prep url and hit api ----
   # When spatial filter "bbox" isn't used, crs are needed
   is_bbox <- sum(spatial_filter == "bbox") == 1
   if(!is_bbox){
      crs <- get_wfs_default_crs(apikey, layer)
   }

   # hit api and loop if there more than 1000 features
   req <- build_wfs_req(x, apikey, layer, spatial_filter,
                        ecql_filter, startindex = 0, crs)
   resp <- hit_api_wfs(req, ecql_filter, apikey)

   # Succesful request but no feature found
   if (is_empty(resp)){
      warning("No data found, NULL is returned.", call. = FALSE)
      return(NULL)
   }

   message("Features downloaded : ", nrow(resp), appendLF = F)

   i <- 1000
   temp <- resp
   while(nrow(temp) == 1000){
      message("...", appendLF = F)
      url <- build_wfs_req(x, apikey, layer, spatial_filter,
                           ecql_filter, startindex = i, crs)
      temp <- hit_api_wfs(url, ecql_filter, apikey)
      resp <- rbind(resp, temp)
      message(nrow(resp), appendLF = F)
      i <- i + 1000
   }
   cat("\n")

   # post treatment ----
   # Cleaning list column from features
   resp <- resp[ , !sapply(resp, is.list)]

   # properly saving file
   filename_exist <- !is.null(filename)
   if (filename_exist & !is_empty(resp)){
      save_wfs(filename, resp, overwrite)
   }

   return(resp)
}

#' @title build_wfs_req
#' @description construct url
#'
#' @param x Object of class `sf`. Needs to be located in France.
#' @param apikey API key from `get_apikeys()`
#' @param layer Name of the layer
#' @param spatial_filter See ?get_wfs
#' @param ecql_filter See ?get_wfs
#' @param startindex startindex for looping when more than 1000 features are returned
#' @param crs epsg character from `get_wfs_default_crs`
#' @noRd
#'
build_wfs_req <- function(x,
                          apikey,
                          layer,
                          spatial_filter = NULL,
                          ecql_filter = NULL,
                          startindex = 0,
                          crs = NULL){

   shape_exist <- !is.null(x)
   spatial_filter_exist <- !is.null(spatial_filter)
   spatial_predicate <- NULL

   if (shape_exist & spatial_filter_exist){
      spatial_predicate <- construct_spatial_filter(x, spatial_filter,
                                                    crs, apikey)
   }

   all_filter <- paste(c(spatial_predicate, ecql_filter), collapse = " AND ")

   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      srsName = "EPSG:4326",
      typeName = layer,
      startindex = startindex,
      count = 1000
   )

   request <- request("https://wxs.ign.fr") |>
      req_url_path_append(apikey) |>
      req_url_path_append("geoportail/wfs") |>
      req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      req_url_query(!!!params) |>
      req_body_form(cql_filter=all_filter)

   return(request)
}

#' format url and request it
#' @param req httr2 request from `build_wfs_req`
#' @param ecql_filter see `?get_wfs`
#' @param apikey see `?get_wfs`
#' @noRd
#'
hit_api_wfs <- function(req,
                        ecql_filter,
                        apikey) {

   tryCatch({
      resp <- req_perform(req) |>
         resp_body_string()
      features <- read_sf(resp, quiet = T)
      },
      error = function(cnd){
         if (!is.null(ecql_filter)){
            stop("Check that `ecql_filter` is properly set.", call. = F)
         }else{
            stop("Please check that :\n",
                 "- x is not empty ;\n",
                 "- layer is valid by running ",
                 "`get_layers_metadata(\"", apikey, "\", \"wfs\")`\n",
                 call. = F)
         }})

   return(features)
}

#' save wfs
#' @param filename Either a character string naming a file or a connection open
#' for writing. (ex : "test.shp" or "~/test.shp")
#' @param resp response from hit_api_wfs request
#' @param overwrite If TRUE, file is overwrite
#' @param quiet see ?sf::st_write
#' @noRd
save_wfs <- function(filename, resp, overwrite, quiet = F){

   path <- normalizePath(filename, mustWork = FALSE)
   path <- enc2utf8(path)

   tryCatch({
      st_write(resp, path, delete_dsn = overwrite, quiet = quiet)
   },
   error = function(cnd){
      if (grepl("Dataset already exists", cnd)){
         stop("Dataset already exists at :\n", filename, call. = F)
      }else{
         stop(cnd)
      }
   })
}


#' @description construct ecql spatial filter string
#' @param shape object of class sf or sfc
#' @param spatial_filter list containing spatial operation and other argument
#' @param crs epsg character from `get_wfs_default_crs`
#' @param apikey character from `get_apikeys()`
#' @importFrom sf st_bbox
#' @return ecql string
#' @noRd
#'
construct_spatial_filter <- function(x = NULL,
                                     spatial_filter = NULL,
                                     crs = NULL,
                                     apikey = NULL){

   # Test for units
   units <- c("feet", "meters", "statute miles", "nautical miles", "kilometers")
   units_exist <- !is.na(spatial_filter[3])
   is_good_units <- spatial_filter[3] %in% units
   if (units_exist & !is_good_units){
      stop("When using \"", spatial_filter[1],
           "\" units should be one of \"", paste0(units, collapse = "\", \""),
           "\".",call. = F)
   }

   # particular case for bbox
   is_bbox <- (spatial_filter[1] == "bbox")
   if (is_bbox){
      bbox <- st_bbox(x)
      spatial_filter <- c(spatial_filter,
                          bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"],
                          sprintf("'EPSG:%s'", st_crs(x)$epsg))
   }

   # if is "bbox", geom is null
   geom <- switch(is_bbox + 1, st_as_text_happign(x, crs), NULL)

   # Build final spatial filter
   spatial_filter <- sprintf("%s(%s, %s)",
                             toupper(spatial_filter[1]),
                             ifelse(apikey == "topographie", "geometrie", "the_geom"),
                             paste(c(geom, spatial_filter[-1]), collapse = ", "))

   return(spatial_filter)
}
