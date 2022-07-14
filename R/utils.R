#' Convert sf or sfc to geojson format
#'
#' @param shape A shape of class sf or sfc. Could be a POLYGON, POINT or
#' LINESTRING.
#'
#' @importFrom sf st_as_sfc st_transform st_geometry_type st_coordinates st_union
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
   geometry_type <- switch(as.character(st_geometry_type(st_union(shape))),
                           "POINT" = list("Point",0,"],["),
                           "LINESTRING" = list("LineString",1,"],["),
                           "POLYGON" = list("Polygon",2,"],["),
                           "MULTIPOLYGON" = list("MultiPolygon",3,"]],[["),
                           stop(as.character(st_geometry_type(shape)[1]),
                                " is not supported"))


   # bracketing coord for json [lat,long],[lat,long],...
   bracketing_coord <- function(shape){

      coord <- paste0("[",st_coordinates(shape)[,"X"], ",",
                      st_coordinates(shape)[,"Y"],"]", collapse = ",")
   }

   # apply this function to every features
   bracket_coord <- paste(lapply(shape, bracketing_coord), collapse = geometry_type[[3]])

   # create json
   res <- paste0('{"type":"',
                 geometry_type[[1]],
                 '","coordinates":',
                 paste(rep("[",geometry_type[[2]]), collapse = ""),
                 bracket_coord,
                 paste(rep("]",geometry_type[[2]]), collapse = ""),
                 '}')
   return(res)
}
