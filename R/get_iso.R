#' @title isochronous/isodistance  calculations
#' @description
#' Calculates isochrones or isodistances in France from an sf object using the
#' IGN API on the Géoportail platform. The reference data comes from the IGN
#' BD TOPO® database. For further information see IGN
#' [documentation.](https://geoservices.ign.fr/documentation/services/api-et-services-ogc/isochrone/api)
#'
#' @usage
#' get_iso(x,
#'         value,
#'         type = "time",
#'         profile = "pedestrian",
#'         time_unit = "minute",
#'         distance_unit = "kilometer",
#'         direction = "departure",
#'         source = "iso",
#'         constraints = NULL)
#'
#' @param x Object of class `sf` or `sfc` with POINT geometry. There may be
#' several points in the object. In this case, the output will contain as many
#' polygons as points.
#' @param value `numeric`; A quantity of time or distance.
#' @param type  `character`; Specifies the type of calculation performed:
#' "time" for isochrone or "distance" for isodistance (isochrone by default).
#' @param profile  `character`; Type of cost used for calculation: "pedestrian"
#' for #' pedestrians and "car" for cars. and "car" for cars ("pedestrian"
#'  by default).
#' @param time_unit `character`; Allows you to specify the unit in which times
#' are expressed in the answer: "hour", "minute" or "second" (minutes by
#' default).
#' @param distance_unit `character`; Allows you to specify the unit in which
#' distances are expressed in the answer: "meter" or "kilometer" (meter by
#' default).
#' @param  direction `character`; Direction of travel. Either define a
#' "departure" point and obtain the potential arrival points. Or define an
#' "arrival" point and obtain the potential points ("departure" by default).
#' @param source `character`; This parameter specifies which source will
#' be used for the calculation. Currently, "iso" and "pgr" sources are
#' available (default "iso"). See section `SOURCE` for further information.
#' @param constraints Used to express constraints on the characteristics
#' to calculate isochrones/isodistances. See section `CONSTRAINTS`.
#'
#' @section SOURCE:
#'
#'Isochrones are calculated using the same resources as for route calculation.
#'PGR" and "ISO" resources are used, namely "bdtopo-iso" and "bdtopo-pgr".
#'
#'- bdtopo-pgr" is based solely on the new engine, but lacks performance on
#'large isochrones. On the other hand, it is functional for small isochrones.
#'
#'- bdtopo-iso" is based on the old services over a certain distance, to solve
#'performance problems. We recommend its use for large isochrones.
#'
#'PGR resources are resources that use the PGRouting engine to calculate
#'isochrones. ISO resources are more generic. The engine used for calculations
#'varies according to several parameters. At present, the parameter concerned
#'is cost_value, i.e. the requested time or distance.
#'
#' @seealso [get_isodistance], [get_isochrone]
#'
#' @return object of class `sf` with `POLYGON` geometry
#'
#' @importFrom sf read_sf st_make_valid
#' @importFrom httr2 req_perform_parallel resps_data resp_body_string
#'
get_iso <- function(x,
                    value,
                    type = "time",
                    profile = "pedestrian",
                    time_unit = "minute",
                    distance_unit = "kilometer",
                    direction = "departure",
                    source = "iso",
                    constraints = NULL){

   match.arg(source, c("iso", "pgr"))
   match.arg(profile, c("car", "pedestrian"))
   match.arg(direction, c("departure", "arrival"))

   x <- x_to_iso(x)

   reqs <- lapply(x,
                  build_iso_query,
                  value = value,
                  type = type,
                  profile = profile,
                  time_unit = time_unit,
                  distance_unit = distance_unit,
                  direction = direction,
                  source = source,
                  constraints = constraints)

   resps <- req_perform_parallel(reqs, on_error = "continue") |>
      resps_data(\(resp) resp_body_string(resp)) |>
      lapply(read_sf)

   res <- do.call(rbind, resps) |>
      st_make_valid()

   return(res)

}

#' @title x_to_iso
#' @description format sf point for isochrone-dist API
#'
#' @param x Object of class `sf` or `sfc` with `POINT` geometry type.
#'
#' @importFrom sf st_geometry st_geometry_type st_is st_transform
#'
#' @noRd
#' @return a list of points in the right format for the query
x_to_iso <- function(x){

   if (!inherits(x, c("sf", "sfc"))) {
      stop("x should be of class sf or sfc, not ",
           class(x), ".",
           call. = F)
   }

   if (!all(st_is(x, "POINT"))) {
      stop("Geometry type of x should be POINT, not ",
           st_geometry_type(x), ".",
           call. = F)
   }

   x <- st_transform(x, 4326)
   x <- as.list(gsub( "[c|(|)| ]", "", st_geometry(x)))

   return(x)
}

#' @title build_iso_query
#' @description build query for isochrone-dist API
#'
#' @inheritParams get_iso
#' @param point `character`; point formated with `x_to_iso`.
#'
#' @importFrom httr2 request req_url_path_append req_options req_url_query
#'
#' @return `httr2_request` object

build_iso_query <- function(point, source, value,
                        type, profile, direction,
                        constraints, distance_unit, time_unit) {

   req <- request("https://wxs.ign.fr") |>
      req_url_path_append("calcul", "geoportail", "isochrone",
                          "rest", "1.0.0", "isochrone") |>
      req_options(ssl_verifypeer = 0) |>
      req_url_query(point = point,
                    resource =  paste0("bdtopo-", source),
                    costValue = value,
                    costType = type,
                    profile = profile,
                    direction = direction,
                    constraints = constraints,
                    geometryFormat = "geojson",
                    distanceUnit = distance_unit,
                    timeUnit = time_unit,
                    crs = "EPSG:4326"
                    )
}

#' @title Calculate isodistance
#' @describeIn get_iso Wrapper function to calculate isodistance from [get_iso].
#'
#' @usage
#' get_isodistance(x,
#'                 dist,
#'                 units = "meter",
#'                 source = "iso",
#'                 profile = "car",
#'                 direction = "departure",
#'                 constraints = NULL)
#'
#' @inheritParams get_iso
#' @param dist `numeric`; A quantity of time.
#' @param units see `time_unit` and `distance_unit` param.
#'
get_isodistance <- function(x,
                            dist,
                            units = "meter",
                            source = "iso",
                            profile = "car",
                            direction = "departure",
                            constraints = NULL){

   match.arg(units, c("meter", "kilometer"))

   res <- get_iso(x,
                  value = dist,
                  type = "distance",
                  profile = profile,
                  time_unit = NULL,
                  distance_unit = units,
                  direction = direction,
                  source = source,
                  constraints = NULL)

   return(res)
}

#' @title Calculate isochrone
#' @describeIn get_iso Wrapper function to calculate isochrone from [get_iso].
#'
#' @usage
#' get_isochrone(x,
#'               time,
#'               units = "minute",
#'               source = "iso",
#'               profile = "car",
#'               direction = "departure",
#'               constraints = NULL)
#'
#' @inheritParams get_iso
#' @param time `numeric`; A quantity of time.
#'
get_isochrone <- function(x,
                          time,
                          units = "minute",
                          source = "iso",
                          profile = "car",
                          direction = "departure",
                          constraints = NULL){

   match.arg(units, c("hour", "minute", "second"))

   res <- get_iso(x,
                  value = time,
                  type = "time",
                  profile = profile,
                  time_unit = NULL,
                  distance_unit = units,
                  direction = direction,
                  source = source,
                  constraints = NULL)

   return(res)
}
