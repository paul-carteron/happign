#' @importFrom curl has_internet
#' @importFrom httr2 request req_perform resp_body_xml resp_is_error req_options
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

   req <- request("http://geoservices.ign.fr/actualites/rss.xml") %>%
      req_options(ssl_verifypeer = 0) %>%
      req_perform()

   if (resp_is_error(req)){
      return(packageStartupMessage("IGN actuality is unavailable.\n",
                                   "It may be due to a site crash ",
                                   "or an update of the IGN data. More ",
                                   "information at ",
                                   "<https://geoservices.ign.fr/actualites>."))
   }else{
      req <- req %>%
         resp_body_xml(check_type = FALSE) %>%
         xml_find_all("//item") %>%
         as_list() %>%
         bind_rows()

      last_actu <- paste0("Last news from IGN website : ",
                          "\"",
                          unlist(req[1,1]),
                          "\"",
                          " on ", substring(unlist(req[1, 2]), 39, 48),
                          " (", unlist(req[1, 2]), ")\n")
   }

   resp <- request("http://geoservices.ign.fr/") %>%
      req_options(ssl_verifypeer = 0) %>%
      req_perform()

   if (resp_is_error(resp)) {
      return(packageStartupMessage("IGN web service API is unavailable.\n",
                                   "It may be due to a site crash ",
                                   "or an update of the IGN data. More ",
                                   "information at ",
                                   "<https://geoservices.ign.fr/actualites>."))
   }else{
      return(packageStartupMessage("IGN web service API is available.\n",
                            last_actu))
   }


}

