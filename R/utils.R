#' Convert sf or sfc to geojson format
#'
#' @param shape A shape of class sf or sfc. Could be a POLYGON, POINT or
#' LINESTRING.
#'
#' @importFrom sf st_as_sfc st_transform st_geometry_type st_coordinates
#' @return Return a geojson string
#' @export
#'
shp_to_geojson <- function(shape){

   if (is.null(shape)){
      return(NULL)
   }

   # an sfc dimension is NULL compare to sf
   if (!is.null(dim(shape))){
      shape <- st_as_sfc(shape)
   }

   # always work with same crs
   shape <- st_transform(shape, 4326)

   # creating json type depending on geometry
   geometry_type <- switch(as.character(st_geometry_type(shape)[1]),
                           "POINT" = "Point",
                           "LINESTRING" = "LineString",
                           "POLYGON" = "Polygon")

   # calculate the number of bracket needed depending on type
   nb_bracket <- switch(as.character(st_geometry_type(shape)[1]),
                        "POINT" = 0,
                        "LINESTRING" = 1,
                        "POLYGON" = 2)

   # bracketing coord for json [lat,long],[lat,long],...
   bracketing_coord <- function(shape){

      coord <- paste0("[",st_coordinates(shape)[,"X"], ",",
                      st_coordinates(shape)[,"Y"],"]", collapse = ",")
   }

   # apply this function to every features
   bracket_coord <- paste(lapply(shape, bracketing_coord), collapse = "],[")

   # create json
   res <- paste0('{"type":"',
                 geometry_type,
                 '","coordinates":',
                 paste(rep("[",nb_bracket), collapse = ""),
                 bracket_coord,
                 paste(rep("]",nb_bracket), collapse = ""),
                 '}')
   return(res)
}
