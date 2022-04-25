#' Create isochron or isodistance from IGN routing API
#'
#' @usage get_iso(point,
#'                time = NULL,
#'                distance = NULL,
#'                transport = "Voiture",
#'                reverse = FALSE,
#'                smoothing = TRUE,
#'                holes = TRUE,
#'                crs = "EPSG:4326")
#'
#' @param point Object of class `sf` or `sfc`. Needs to be located in
#' France.
#' @param time Duration in minute to create isochron. If `time` and
#' `distance` parameters are set, only `time` will be used.
#' @param distance Distance in meter to create isodistance. If `time` and
#' `distance` parameters are set, only `time` will be used.
#' @param transport There is two type of transport : "Voiture" (car) or "
#' Pieton" (pedestrian).
#' @param reverse A boolean corresponding to the sens of travel. If `FALSE`,
#' `point` corresponding to the start.
#' @param smoothing A boolean determining whether the returned shape should
#' be smoothed or not
#' @param holes Some areas are inaccessible. If `TRUE` they are highlighted
#' @param crs System of coordinate
#'
#' @details
#' Native API parameter can be find at IGN documentation.
#'
#' @return
#' `get_iso()` returned a polygon corresponding to all the points reachable
#' in a defined time or distance
#'
#' @export
#'
#' @importFrom sf st_as_sfc st_sf st_coordinates st_crs st_transform
#' @importFrom httr accept_json content GET http_type modify_url
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(tmap); tmap_mode("view")
#'
#' point <- st_sfc(st_point(c(-4.340329361590764, 47.81236909325107)),
#'                 crs = 4326)
#' isodistance <- get_iso(point, distance = 1000, transport = "Pieton")
#'
#' qtm(isodistance)+
#' qtm(point, dots.col = "red")
#'
#' }
get_iso <- function(point,
                    time = NULL,
                    distance = NULL,
                    transport = "Voiture",
                    reverse = FALSE,
                    smoothing = TRUE,
                    holes = TRUE,
                    crs = "EPSG:4326") {

   # Test for distance and time combination
   if (is.null(distance) & is.null(time)){
      stop("time or distance parameter must be supplied")
   }else if (is.null(distance)) {
      add_to_query <- list(method = "time", time = time)
   }else if (is.null(time)){
      add_to_query <- list(method = "distance", distance = distance)
   }else{
      add_to_query <- list(method = "time", time = time)
   }

   # Test for transport
   if (isFALSE(transport %in% c("Voiture", "Pieton"))){
      stop("transport parameter must be \"Pieton\" or \"Voiture\"")
   }

   point <- st_transform(point, 4326)
   time <-  time * 60

   url <- modify_url("https://wxs.ign.fr",
                     path = "calcul/isochrone/isochrone.json?")

   query <- list(
      location = toString(st_coordinates(point)),
      graphName = transport,
      reverse = reverse,
      smoothing = smoothing,
      holes = holes,
      srs = crs
   )

   resp <- GET(url,
               query = c(query, add_to_query),
               accept_json())

   if (http_type(resp) != "application/json") {
      stop("API did not return json", call. = FALSE)
   }

   routing <- content(resp)$wktGeometry %>%
      st_as_sfc(crs = st_crs(crs)) %>%
      st_sf()

   return(routing)

}
