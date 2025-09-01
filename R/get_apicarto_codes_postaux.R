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
#' code_post <- c("29760", "08170")
#' info_communes <- get_apicarto_codes_postaux(code_post)
#'
#' code_post <- c("12345")
#' info_communes <- get_apicarto_codes_postaux(code_post)
#'
#' code_post <- c("12345", "08170")
#' info_communes <- get_apicarto_codes_postaux(code_post)
#'}
#'
#' @name get_apicarto_codes_postaux
#' @export
#'

get_apicarto_codes_postaux <- function(code_post){

   pad0 <- \(x, n) if (is.null(x)) NULL else gsub(" ", "0", sprintf(paste0("%", n, "s"), x))
   code_post <- pad0(code_post, 5) |> unique()

   fetch_data <- function(code_post){
      tryCatch({
         req <- request("https://apicarto.ign.fr") |>
            req_url_path("api/codes-postaux/communes") |>
            req_url_path_append(code_post) |>
            req_user_agent("happign (https://paul-carteron.github.io/happign/)") |>
            req_options(ssl_verifypeer = 0) |>
            req_perform() |>
            resp_body_json()
      },
      error = function(e) {
         warning("No data found for : ", code_post, call. = F)
         return(NULL)
      })}

   resp <- lapply(code_post, fetch_data)
   resp <- Filter(Negate(is.null), resp)

   df <- do.call(rbind, lapply(resp, function(x) {
      do.call(rbind.data.frame, x)
   }))

   return(df)
}
