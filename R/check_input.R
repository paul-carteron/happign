#' check get_wms_raster input
#'
#' @param x see get_wms_raster
#' @param apikey see get_wms_raster
#' @param layer see get_wms_raster
#' @param res see get_wms_raster
#' @param filename see get_wms_raster
#' @param crs see get_wms_raster
#' @param overwrite see get_wms_raster
#' @param version see get_wms_raster
#' @param styles see get_wms_raster
#' @param interactive see get_wms_raster
#'
#' @importFrom sf st_crs
#'
#' @noRd
#'
check_get_wms_raster_input <- function(x,
                                       apikey,
                                       layer,
                                       res,
                                       filename,
                                       crs,
                                       overwrite,
                                       version,
                                       styles,
                                       interactive){

   # x
   if (!inherits(x, c("sf", "sfc", "NULL"))) {
      stop("`x` must be of class sf, sfc or NULL.")
   }

   # apikey
   is_apikey <- apikey %in% get_apikeys()
   is_personal_key <- grepl("^[[:alnum:]]{24}$", apikey)
   if (!any(is_apikey, is_personal_key)) {
      stop("`apikey` must be a character from `get_apikey()` or a personal key.")
   }

   # layer
   if (!inherits(layer, "character")) {
      stop("`layer` must be of class character.")
   }

   # resolution
   if (!inherits(res, "numeric")) {
      stop("`resolution` must be of class numeric.")
   }

   # filename
   if (!inherits(filename, c("character", "NULL"))) {
      stop("`filename` must be of class character or NULL.")
   }

   if (!is.null(filename)){
      filename_ext <- strsplit(basename(filename), split="\\.")[[1]] # split one point
      filename_ext <- filename_ext[length(filename_ext)] # get last element of the list
      ext <- c("tif", "png", "vrt", "ntf", "toc", "xml", "img", "gff")

      if(!(filename_ext %in% ext) ){
         stop("filename extension should be one of ",
              paste(ext, collapse = ", "), ".", call. = FALSE)
      }

   }

  # crs : can take any crs object
   tryCatch({st_crs(crs)},
            error = function(cnd){stop("Invalid crs : ", crs, call. = FALSE)},
            warning = function(cns){stop("Invalid crs : ", crs, call. = FALSE)})

   # version
   if (!inherits(version, c("character"))) {
      stop("`version` must be of class character.")
   }
   if (!grepl("^[0-9]{1}\\.[0-9]{1}\\.[0-9]{1}$", version)) {
      stop("`version` is is badly formatted.")
   }

   # style
   if (!inherits(styles, c("character"))) {
      stop("`styles` must be of class character.")
   }

   # overwrite
   if (!inherits(overwrite, c("logical"))) {
      stop("`overwrite` must be of class logical.")
   }

   # interactive
   if (!inherits(interactive, c("logical"))) {
      stop("`interactive` must be of class logical.")
   }
}

