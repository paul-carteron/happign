#' @export
#'
.onAttach <- function(libname, pkgname) {
   packageStartupMessage("Please make sure you are connected to the internet.")
   packageStartupMessage("Use happign::get_last_news() to display latest geoservice news.")
}

