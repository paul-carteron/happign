#' Apicarto Codes Postaux
#'
#' Implementation of the "Codes Postaux" module from the
#'  [IGN's apicarto](https://apicarto.ign.fr/api/doc/codes-postaux). This
#'  API give information about commune from postal code.
#'
#' @usage
#' get_apicarto_codes_postaux(code_post)
#'
#' @param code_post `character` corresponding to the postal code of a commune
#'
#' @importFrom httr2 req_perform resp_body_json
#'
#' @return Object of class `data.frame`
#' @export
#'
#' @examples
#' \dontrun{
#'
#' info_commune <- get_apicarto_codes_postaux("29760")
#'
#' code_post <- c("29760", "29260")
#' info_communes <- get_apicarto_codes_postaux(code_post)
#'}
#'
#' @name get_apicarto_codes_postaux
#' @export
#'

get_apicarto_codes_postaux <- function(code_post){

   hit_code_post <- function(code_post){
      resp <- build_req(path = paste0("api/codes-postaux/communes/",
                                      code_post)) |>
         req_perform() |>
         resp_body_json()
      resp <- do.call(rbind, resp)
   }

   resp <- Map(hit_code_post,
               code_post)

   # bind rows of each Map call
   resp <- data.frame(do.call(rbind, resp))

   return(resp)
}
