#' @importFrom httr http_error
#' @importFrom curl has_internet
#'
#' @export
#'
.onAttach <- function(libname, pkgname) {

   if (!has_internet()){
      stop("No internet connection.")
   }

   # base_url <- "http://geoservices.ign.fr/"
   # # check that IGN web service can be reached
   # if (http_error(base_url)) { # TRUE: 400 or above
   #    packageStartupMessage("IGN web service API is unavailable.\n",
   #                          "It may be due to a site crash ",
   #                          "or an update of the IGN data. More information at ",
   #                          "<https://geoservices.ign.fr/actualites>.")
   # }else{
   #    packageStartupMessage("IGN web service API is available.")
   # }
}
