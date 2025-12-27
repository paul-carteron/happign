#' Spatial predicate constructors
#'
#' These functions create spatial predicates used by [get_wfs()] to filter
#' features based on their spatial relationship with a reference geometry.
#'
#' Predicates describe *how* geometries should be compared (e.g. intersection,
#' containment, distance-based relations). Users should not construct predicates
#' manually; instead, use the helper functions listed below.
#'
#' - `bbox()`: Select features intersecting the bounding box of the reference geometry.
#' - `intersects()`: Select features whose geometry intersects the reference geometry.
#' - `within()`: Select features completely within the reference geometry.
#' - `contains()`: Select features that completely contain the reference geometry.
#' - `touches()`: Select features that touch the reference geometry at the boundary.
#' - `crosses()`: Select features that cross the reference geometry.
#' - `overlaps()`: Select features that partially overlap the reference geometry.
#' - `equals()`: Select features geometrically equal to the reference geometry.
#' - `dwithin(distance, units)`: Select features within a given distance of the reference geometry.
#' - `beyond(distance, units)`: Select features farther than a given distance from the reference geometry.
#' - `relate(pattern)`: Select features matching a DE-9IM spatial relationship pattern.
#'
#' @param distance Numeric distance value (single value).
#' @param units Distance units supported by the WFS server (e.g. `"meters"`, `"kilometers"`).
#' @param pattern A 9-character DE-9IM pattern string.
#'
#' @return A spatial predicate object (used internally by [get_wfs()]).
#'
#' @seealso [get_wfs()]
#'
#' @examples
#' intersects()
#' bbox()
#' dwithin(50, "meters")
#' beyond(100, "meters")
#' relate("T*F**F***")
#'
#' @name spatial_predicates
NULL

#' @noRd
predicate <- function(type, ...) {
   list(type = type, ...)
}

#' @rdname spatial_predicates
intersects <- function() predicate("intersects")

#' @rdname spatial_predicates
within <- function() predicate("within")

#' @rdname spatial_predicates
contains <- function() predicate("contains")

#' @rdname spatial_predicates
touches <- function() predicate("touches")

#' @rdname spatial_predicates
crosses <- function() predicate("crosses")

#' @rdname spatial_predicates
overlaps <- function() predicate("overlaps")

#' @rdname spatial_predicates
equals <- function() predicate("equals")

#' @rdname spatial_predicates
bbox <- function() predicate("bbox")

#' @rdname spatial_predicates
dwithin <- function(distance, units = "meters") {
   # distance checks
   if (!is.numeric(distance) || length(distance) != 1 || is.na(distance)) {
      stop(
         "`distance` must be a single, non-missing numeric value.",
         call. = FALSE
      )
   }

   if (distance < 0) {
      stop("`distance` must be a non-negative value.",call. = FALSE)
   }

   # units checks
   valid_units <- c(
      "feet", "meters", "kilometers",
      "statute miles", "nautical miles"
   )

   if (!is.character(units) || length(units) != 1) {
      stop("`units` must be a single character string.", call. = FALSE)
   }

   if (!units %in% valid_units) {
      stop(
         "Invalid `units`: '", units, "'.\n",
         "Valid units are: ",
         paste(valid_units, collapse = ", "),
         call. = FALSE
      )
   }

   predicate("dwithin", distance = distance, units = units)
}

#' @rdname spatial_predicates
beyond <- function(distance, units = "meters") {
   # distance checks
   if (!is.numeric(distance) || length(distance) != 1 || is.na(distance)) {
      stop(
         "`distance` must be a single, non-missing numeric value.",
         call. = FALSE
      )
   }

   if (distance < 0) {
      stop("`distance` must be a non-negative value.",call. = FALSE)
   }

   # units checks
   valid_units <- c(
      "feet", "meters", "kilometers",
      "statute miles", "nautical miles"
   )

   if (!is.character(units) || length(units) != 1) {
      stop("`units` must be a single character string.", call. = FALSE)
   }

   if (!units %in% valid_units) {
      stop(
         "Invalid `units`: '", units, "'.\n",
         "Valid units are: ",
         paste(valid_units, collapse = ", "),
         call. = FALSE
      )
   }

   predicate("beyond", distance = distance, units = units)
}

#' @rdname spatial_predicates
relate <- function(pattern) {
   stopifnot(is.character(pattern), nchar(pattern) == 9)
   predicate("relate", pattern = pattern)
}

#' Build a spatial ECQL filter
#'
#' Converts a spatial predicate and a reference geometry into an ECQL
#' expression suitable for use in a WFS `GetFeature` request.
#'
#' This function is an internal helper used by [get_wfs()] to translate
#' spatial predicate objects (see [spatial_predicates]) into ECQL syntax understood by the WFS server.
#'
#' Users should not call this function directly.
#'
#' @param x An `sf` or `sfc`
#' @param layer `character` giving the WFS layer name.
#' @param predicate A spatial predicate object created by predicate helpers.
#'
#' @return A character string containing a spatial ECQL filter.
#'
#' @keywords internal
spatial_cql <- function(x, layer, predicate) {

   if (!is.list(predicate) || is.null(predicate$type)) {
      stop(
         "`predicate` must be a list with at least a `type` element, not : ", predicate,
         call. = FALSE
      )
   }

   geom_name <- get_wfs_default_geometry_name(layer)
   crs <- sf::st_crs(get_wfs_default_crs(layer))

   if (predicate$type == "bbox") {
      return(bbox_cql(x, geom_name, crs))
   }

   geom <- sf::st_as_text(sf::st_union(sf::st_geometry(x)))
   if (!is.na(crs$epsg)) {
      geom <- sprintf("SRID=%s;%s", crs$epsg, geom)
   }

   switch(
      predicate$type,

      intersects = sprintf("INTERSECTS(%s, %s)", geom_name, geom),
      within     = sprintf("WITHIN(%s, %s)", geom_name, geom),
      contains   = sprintf("CONTAINS(%s, %s)", geom_name, geom),
      touches    = sprintf("TOUCHES(%s, %s)", geom_name, geom),
      crosses    = sprintf("CROSSES(%s, %s)", geom_name, geom),
      overlaps   = sprintf("OVERLAPS(%s, %s)", geom_name, geom),
      equals     = sprintf("EQUALS(%s, %s)", geom_name, geom),

      dwithin = sprintf(
         "DWITHIN(%s, %s, %s, %s)",
         geom_name, geom,
         predicate$distance, predicate$units
      ),

      beyond = sprintf(
         "BEYOND(%s, %s, %s, %s)",
         geom_name, geom,
         predicate$distance, predicate$units
      ),

      relate = sprintf(
         "RELATE(%s, %s, '%s')",
         geom_name, geom,
         predicate$pattern
      ),

      stop("Unknown predicate type: ", predicate$type)
   )
}

#' Build a BBOX ECQL filter
#'
#' Constructs a spatial ECQL `BBOX` expression from a reference geometry.
#'
#' The bounding box is computed from the geometry provided in `x`, after
#' transforming it to the CRS of the target WFS layer. If the layer CRS has
#' a valid EPSG code, it is included in the ECQL expression.
#'
#' This function is an internal helper used by [spatial_cql()] and should
#' not be called directly by users.
#'
#' @param x An `sf` object providing the reference geometry.
#' @param geom_name Character string giving the geometry attribute name
#'   of the WFS layer.
#' @param crs A CRS definition (as accepted by [sf::st_crs()]) corresponding
#'   to the WFS layer.
#'
#' @return A character string containing a `BBOX` ECQL filter.
#'
#' @seealso [spatial_cql()]
#' @keywords internal
bbox_cql <- function(x, geom_name, crs) {
   crs <- sf::st_crs(crs)
   x <- sf::st_transform(x, crs)

   bb <- sf::st_bbox(x)
   coords <- sprintf(
      "%f, %f, %f, %f",
      bb["xmin"], bb["ymin"], bb["xmax"], bb["ymax"]
   )

   crs_part <- if (!is.na(crs$epsg)) sprintf(", 'EPSG:%s'", crs$epsg) else ""

   sprintf("BBOX(%s, %s%s)", geom_name, coords, crs_part)
}
