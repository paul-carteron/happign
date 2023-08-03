#' @noRd
#'
.onAttach <- function(libname, pkgname) {
   packageStartupMessage("Please make sure you have an internet connection.")
   packageStartupMessage("Use happign::get_last_news() to display latest geoservice news.")

   # increases download time
   default_timeout <- options("timeout")
   options("default_timeout" = default_timeout)
   options("timeout" = 3600)
}

.onDetach <- function(libpath) {
   default_timeout <- options("default_timeout")
   options("timeout" = default_timeout)
}
