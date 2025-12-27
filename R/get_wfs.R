#' @title Download data from IGN WFS layer
#'
#' @description
#' Download features from the IGN Web Feature Service (WFS) using a
#' spatial predicate, an ECQL attribute query, or both.
#'
#' @param x `sf`, `sfc` or `NULL`. If `NULL`, no spatial filter is applied
#' and `query` must be provided.
#' @param layer `character`; name of the WFS layer. Must correspond to a
#' layer available on the IGN WFS service (see [get_layers_metadata()]).
#' @param predicate `list`; a spatial predicate definition created with helper
#' such as `bbox()`, `intersects()`, `within()`, `contains()`, `touches()`,
#' `crosses()`, `overlaps()`, `equals()`, `dwithin()`, `beyond()` or
#' `relate()`. See [spatial_predicates] for more info.
#' @param query `character`; an ECQL attribute query. When both `x` and `query`
#' are provided, the spatial predicate and the attribute query are combined.
#' @param verbose `logical`; if `TRUE`, display progress information and
#' other informative message.
#'
#' @return
#' An object of class `sf`.
#'
#' @details
#' * `get_wfs` use ECQL language : a query language created by the
#' OpenGeospatial Consortium. More info about ECQL language can be
#' found [here](https://docs.geoserver.org/latest/en/user/filter/ecql_reference.html).
#'
#' @seealso
#' [get_layers_metadata()]
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' # Load a geometry
#' x <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))
#'
#' # Retrieve commune boundaries intersecting x
#' commune <- get_wfs(
#'   x = x,
#'   layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
#' )
#'
#' plot(st_geometry(commune), border = "firebrick")
#'
#' # Attribute-only query (no spatial filter)
#'
#' # If unknown, available attributes can be retrieved using `get_wfs_attributes()`
#' attrs <- get_wfs_attributes("LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")
#' print(attrs)
#'
#' plou_communes <- get_wfs(
#'   x = NULL,
#'   layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
#'   query = "nom_officiel ILIKE 'PLOU%'"
#' )
#' plot(st_geometry(plou_communes))
#'
#' # Multiple Attribute-only query (no spatial filter)
#' plou_inf_2000 <- get_wfs(
#'   x = NULL,
#'   layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
#'   query = "nom_officiel ILIKE 'PLOU%' AND population < 2000"
#' )
#' plot(st_geometry(plou_communes))
#' plot(st_geometry(plou_inf_2000), col = "firebrick", add = TRUE)
#'
#' # Spatial predicate usage
#'
#' layer <- "BDCARTO_V5:rond_point"
#'
#' bbox_feat <- get_wfs(commune, layer, predicate = bbox())
#' plot(st_geometry(bbox_feat), col = "red")
#' plot(st_geometry(commune), add = TRUE)
#'
#' intersects_feat <- get_wfs(commune, layer, predicate = intersects())
#' plot(st_geometry(intersects_feat), col = "red")
#' plot(st_geometry(commune), add = TRUE)
#'
#' dwithin_feat <- get_wfs(commune, layer, predicate = dwithin(5, "kilometers"))
#' plot(st_geometry(dwithin_feat), col = "red")
#' plot(st_geometry(commune), add = TRUE)
#' }
#'
#' @export
#'
get_wfs <- function(
      x = NULL,
      layer = NULL,
      predicate = bbox(),
      query = NULL,
      verbose = TRUE
      ){

   if (!inherits(x, c("sf", "sfc", "NULL"))){
      stop("`x` should have class `sf`, `sfc` or `NULL` if `ecql_filter` is set.",
           call. = FALSE)
   }

   cql <- character(0)
   if (!is.null(x)) {
      cql <- c(cql, spatial_cql(x, layer, predicate))
   }

   if (!is.null(query)) {

      attrs <- get_wfs_attributes(layer)
      query_attrs <- extract_identifiers(query)
      unknown <- setdiff(query_attrs, attrs)

      if (length(unknown)) {
         stop(
            sprintf(
               "Unknown attribute(s) in `query`: %s.\nAvailable attributes are: %s",
               paste(unknown, collapse = ", "),
               paste(attrs, collapse = ", ")
            ),
            call. = FALSE
         )
      }

      cql <- c(cql, sprintf("(%s)", query))
   }

   if (!length(cql)) {
      stop("At least one of `x` or `query` must be provided.", call. = FALSE)
   }

   cql <- paste(cql, collapse = " AND ")

   offset <- 500
   params <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      outputFormat = "json",
      typeName = layer,
      count = offset
   )

   req <- httr2::request("https://data.geopf.fr/") |>
      httr2::req_url_path_append("wfs/ows") |>
      httr2::req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
      httr2::req_url_query(!!!params) |>
      httr2::req_body_form(cql_filter = cql)

   resps <- httr2::req_perform_iterative(
      req,
      next_req = httr2::iterate_with_offset(
         "startindex",
         start = 0,
         offset = offset,
         resp_pages = function(resp) {
            total <- httr2::resp_body_json(resp)$numberMatched
            max(1L, ceiling(total / offset)) # If total = 0 fake 1 page
         }
      ),
      max_reqs = Inf,
      progress = verbose
   )

   features <- resps |>
      httr2::resps_data(\(resp) httr2::resp_body_string(resp)) |>
      lapply(read_sf)

   features <- do.call(rbind, features) |> suppressWarnings()
   features <- features[, !sapply(features, is.list)]

   no_feature <- nrow(features) == 0L
   if (no_feature && verbose) {
      message("WFS query returned no features.")
   }

   return(features)
}

extract_identifiers <- function(query) {

   # remove quoted strings
   q <- gsub("'[^']*'", "", query)

   # extract words (letters, digits, underscore)
   tokens <- gregexpr("[A-Za-z_][A-Za-z0-9_]*", q)
   words <- unique(regmatches(q, tokens)[[1]])

   # ECQL keywords to ignore
   keywords <- c(
      "AND", "OR", "NOT",
      "LIKE", "ILIKE", "IN", "BETWEEN",
      "IS", "NULL",
      "EXISTS", "DOES", "INCLUDE", "EXCLUDE",
      "TRUE", "FALSE"
   )

   return(setdiff(words, keywords))
}

