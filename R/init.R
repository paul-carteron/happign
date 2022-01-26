#' @importFrom curl has_internet
#' @importFrom httr http_error
#'
#' @export
#'
.onAttach <- function(libname, pkgname) {

   # check Internet connection
   if (!curl::has_internet()) {
      packageStartupMessage("No Internet connection.")
   }

   base_url <- "http://geoservices.ign.fr/"
   # check that iNat can be reached
   if (httr::http_error(base_url)) { # TRUE: 400 or above
      packageStartupMessage("IGN web service API is unavailable.")
   }else{
      packageStartupMessage("IGN web service API is available.")
   }
}
