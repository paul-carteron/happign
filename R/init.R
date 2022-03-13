#' @importFrom httr http_error set_config config reset_config
#' @importFrom curl has_internet
#' @importFrom dplyr bind_rows
#' @importFrom magrittr `%>%`
#' @importFrom xml2 read_xml as_list xml_find_all
#'
#' @export
#'
.onAttach <- function(libname, pkgname) {

   if (!has_internet()) {
      stop("No internet connection.")
   }

   # Last actu

   resp <- GET("http://geoservices.ign.fr/actualites/rss.xml", config(ssl_verifypeer = 0))

   doc <- read_xml(resp) %>%
      xml_find_all("//item") %>%
      as_list() %>%
      bind_rows()

   last_actu = paste0("Last news from IGN website : ",
                      "\"",
                      unlist(doc[1,1]),
                      "\"",
                      " on ", substring(unlist(doc[1, 2]), 39, 48),
                     " (", unlist(doc[1, 2]), ")\n")

   base_url <- "http://geoservices.ign.fr/"

   # check that IGN web service can be reached (400 or above-
   if (http_error(GET(base_url, config(ssl_verifypeer = 0)))) {
      packageStartupMessage("IGN web service API is unavailable.\n",
                            "It may be due to a site crash ",
                            "or an update of the IGN data. More ",
                            "information at ",
                            "<https://geoservices.ign.fr/actualites>.")
   }else{
      packageStartupMessage("IGN web service API is available.\n",
                            last_actu)
   }

   reset_config()
}
