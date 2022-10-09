#' Print latest news from geoservice
#'
#' This function connects directly to the RSS feed of the
#' geoservice site to get the latest information. This allows
#' to understand why some resources are sometimes not available.
#'
#' @usage
#' get_last_news()
#'
#' @importFrom httr2 request req_perform resp_body_xml resp_is_error req_options
#' @importFrom xml2 as_list xml_find_all
#' @importFrom magrittr `%>%`
#'
#' @return message
#' @export
#'
#' @examples
#' \dontrun{
#' get_last_news()
#' }
#'
get_last_news <- function(){

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
         as_list()

      last_actu <- paste0("Last news from IGN website : ",
                          "\"",
                          req[[1]][["title"]][[1]],
                          "\"",
                          " on ", substring(req[[1]][["pubDate"]][[1]], 6, 16),
                          " (", req[[1]][["link"]][[1]], ")\n")
   }

   message(last_actu)
}

