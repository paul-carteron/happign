#' Print latest news from geoservice website
#'
#' This function is a wrapper around the RSS feed of the
#' geoservice site to get the latest information.
#'
#' @usage
#' get_last_news()
#'
#' @importFrom httr2 request req_perform resp_body_xml resp_is_error req_options req_error
#' @importFrom xml2 as_list xml_find_all
#'
#' @return message or error
#' @export
#'
#' @examples
#' \dontrun{
#' get_last_news()
#' }
#'
get_last_news <- function(){

   custom_error <- function(resp){
     paste0("Geoservice website <https://geoservices.ign.fr> is",
            " unavailable, try again later to get last news.")
   }

   req <- request("http://geoservices.ign.fr/actualites/rss.xml") |>
      req_options(ssl_verifypeer = 0) |>
      req_error(body = custom_error) |>
      req_perform() |>
      resp_body_xml(check_type = FALSE) |>
      xml_find_all("//item") |>
      as_list()

   last_actu <- paste0("Last news from Geoservice website : ",
                       "\"",
                       req[[1]][["title"]][[1]],
                       "\"",
                       " on ", substring(req[[1]][["pubDate"]][[1]], 6, 16),
                       " (", req[[1]][["link"]][[1]], ")")

   message(last_actu)
}

