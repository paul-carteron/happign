#' @importFrom httr http_error
#'
#' @export
#'
.onAttach <- function(libname, pkgname) {

   base_url <- "http://geoservices.ign.fr/"
   # check that iNat can be reached
   if (http_error(base_url)) { # TRUE: 400 or above
      packageStartupMessage("IGN web service API is unavailable.\n",
                            "It may be due to a site crash ",
                            "or an update of the IGN data. More information at ",
                            "<https://geoservices.ign.fr/actualites>.")
   }else{
      packageStartupMessage("IGN web service API is available.")
   }
}
