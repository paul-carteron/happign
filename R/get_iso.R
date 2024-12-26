#' @title isochronous/isodistance  calculations
#'
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
#'         distance_unit = "meter",
#'         direction = "departure",
#'         source = "pgr",
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
#' be used for the calculation. Currently, "valhalla" and "pgr" sources are
#' available (default "pgr"). See section `SOURCE` for further information.
#' @param constraints Used to express constraints on the characteristics
#' to calculate isochrones/isodistances. See section `CONSTRAINTS`.
#'
#' @section SOURCE:
#'
#'Isochrones are calculated using the same resources as for route calculation.
#'PGR" and "VALHALLA" resources are used, namely "bdtopo-valhalla" and "bdtopo-pgr".
#'
#'- bdtopo-valhalla" : To-Do
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
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap)
#'
#' # All area i can acces in less than 5 minute from penmarch centroid
#' penmarch <- get_apicarto_cadastre("29158")
#' penmarch_centroid <- st_centroid(penmarch)
#' isochrone <- get_isochrone(penmarch_centroid, 5)
#'
#' qtm(penmarch, col = "red")+qtm(isochrone, col = "blue")+qtm(penmarch_centroid, fill = "red")
#'
#' # All area i can acces as pedestrian in less than 1km
#' isodistance <- get_isodistance(penmarch_centroid, 1, unit = "kilometer", profile = "pedestrian")
#'
#' qtm(penmarch, col = "red")+qtm(isodistance, col = "blue")+qtm(penmarch_centroid, fill = "red")
#'
#' # In case of multiple point provided, the output will contain as many polygons as points.
#' code_insee <- c("29158", "29072", "29171")
#' communes_centroid <- get_apicarto_cadastre(code_insee) |> st_centroid()
#' isochrones <- get_isochrone(communes_centroid, 8)
#' isochrones$code_insee <- code_insee
#' qtm(isochrones, fill = "code_insee")
#'
#' # Find area where i can acces all communes centroid in less than 8 minutes
#' area <- st_intersection(isochrones)
#' qtm(communes_centroid, fill = "red")+ qtm(area[area$origins == "1:3",])
#' }
get_iso <- function(x,
                    value,
                    type = "time",
                    profile = "pedestrian",
                    time_unit = "minute",
                    distance_unit = "meter",
                    direction = "departure",
                    source = "pgr",
                    constraints = NULL){

   # test input args ----
   match.arg(type, c("time", "distance"))
   match.arg(profile, c("car", "pedestrian"))
   match.arg(time_unit, c("hour", "minute", "second", NULL))
   match.arg(distance_unit, c("meter", "kilometer",  NULL))
   match.arg(direction, c("departure", "arrival"))
   match.arg(source, c("valhalla", "pgr"))

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
   # To-Do : test for Null response (ex : 5 "second")
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
#'
#' @param point `character`; point formated with `x_to_iso`.
#' @inheritParams  get_iso
#' @importFrom httr2 request req_url_path_append req_options req_url_query
#'
#' @return `httr2_request` object

build_iso_query <- function(point, source, value,
                        type, profile, direction,
                        constraints, distance_unit, time_unit) {

   req <- request("https://data.geopf.fr/") |>
      req_url_path_append("navigation", "isochrone") |>
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
#'                 unit = "meter",
#'                 source = "pgr",
#'                 profile = "car",
#'                 direction = "departure",
#'                 constraints = NULL)
#'
#' @param dist `numeric`; A quantity of time.
#' @export
#'
get_isodistance <- function(x,
                            dist,
                            unit = "meter",
                            source = "pgr",
                            profile = "car",
                            direction = "departure",
                            constraints = NULL){

   res <- get_iso(x,
                  value = dist,
                  type = "distance",
                  profile = profile,
                  time_unit = NULL,
                  distance_unit = unit,
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
#'               unit = "minute",
#'               source = "pgr",
#'               profile = "car",
#'               direction = "departure",
#'               constraints = NULL)
#'
#' @param time `numeric`; A quantity of time.
#' @param unit see `time_unit` and `distance_unit` param.
#' @export
#'
get_isochrone <- function(x,
                          time,
                          unit = "minute",
                          source = "pgr",
                          profile = "car",
                          direction = "departure",
                          constraints = NULL){

   res <- get_iso(x,
                  value = time,
                  type = "time",
                  profile = profile,
                  time_unit = unit,
                  distance_unit = NULL,
                  direction = direction,
                  source = source,
                  constraints = NULL)

   return(res)
}
