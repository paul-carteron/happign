#' Download raw LIDAR data
#'
#' Check if raw LIDAR data are available at the shape location.
#' The raw LIDAR data are not classified; they correspond to a cloud point.
#'
#' @param shape Object of class `sf` or `sfc`. Needs to be located in
#' France.
#' @param destfile Folder path where data are downloaded. By default set to "." e.g. the current directory
#' @param grid_path Folder path where grid is downloaded. By default set to "." e.g. the current directory
#' @param quiet if TRUE download is silent
#'
#' @details
#' `get_raw_lidar()` first download a grid containing the name of LIDAR tiles which is
#' then intersected with `shape` to determine which ones will be uploaded.
#' The grid is downloaded to `grid_path` and lidar data to `destfile`. For both
#' directory, function check if grid or data already exist to avoid re-downloading them.
#'
#' @return No object.
#' @export
#'
#' @importFrom sf read_sf st_crs st_filter st_transform st_crs<-
#' @importFrom archive archive archive_extract
#' @importFrom utils download.file
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' # Create shape
#' shape <- st_polygon(list(matrix(c(8.852234, 42.55466,
#'                                   8.852234, 42.57289,
#'                                   8.860474, 42.57289,
#'                                   8.860474, 42.55466,
#'                                   8.852234, 42.55466),
#'                                  ncol = 2, byrow = TRUE)))
#' shape <- st_sfc(shape, crs = st_crs(4326))
#'
#' # Download data to current directory
#' get_raw_lidar(shape)
#'
#' # Check all .laz file
#' list.files(".", pattern = ".laz", recursive = TRUE)
#' }
#'
get_raw_lidar <- function(shape, destfile = ".", grid_path = ".", quiet = F){

   grid <- get_lidar_grid(grid_path, quiet = quiet)
   shape <- st_transform(shape, 2154)

   urls <- grid |>
      st_filter(shape, .predicate = st_intersects)
   urls <- urls$url_telech

   if (identical(urls, character(0))){
      return(warning("There is no lidar data on this area."))
   }

   already_dowload <- paste(list.files(destfile, pattern = "LIDARHD"), collapse = "|")
   urls <- urls[!(urls %in% already_dowload)]

   if(length(urls) != 0){
      message ("Tiles to download : ", length(urls))
   }

   invisible(lapply(urls, download_extract_7z, destfile = destfile, quiet = quiet))

   message("LIDAR data are download at : ",
           normalizePath(destfile))

}
#' download and extract .7z file
#' @param url source of data
#' @param destfile folder path where data are downloaded. By default set to "." e.g. the current
#'  directory
#' @noRd
download_extract_7z <- function(url, destfile = ".", quiet = quiet){

   tf <- tempfile()
   download.file(url, tf , mode = "wb", quiet = quiet)

   # ---- Lecture avec archive et sf ----
   invisible(archive(tf))
   archive_extract(tf, dir = destfile)

}
#' download grid from pcrs.ign.fr
#' @param destfile folder path where data are downloaded. By default set to "." e.g. the current
#'  directory
#' @noRd
get_lidar_grid <- function(destfile = ".", grid_path = ".", quiet = quiet){

   tryCatch({
      if (length(list.files(destfile, pattern = "lidarhd.shp$")) == 0){
         url <- "https://pcrs.ign.fr/download/lidar/shp"
         invisible(download_extract_7z(url, destfile, quiet = quiet))
      }
   },
   error = function(cnd){
      stop("Downloading of grid is unavailable. Please submit new issue to https://github.com/paul-carteron/happign/issues.", call. = FALSE)
   })

   grid <- read_sf(list.files(destfile,
                              pattern = "lidarhd.shp$",
                              full.names = TRUE))
   st_crs(grid) <- st_crs(2154)
   message("Grid is dowloaded at : ", normalizePath(grid_path))
   return(grid)
}
