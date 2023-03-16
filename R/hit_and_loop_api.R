#' @description build request from path and parameter
#' @param path path of the api
#' @param ... request parameters
#' @return httr2_request object
#' @noRd
#'
build_req <- function(path, ...) {
   params <- list(...)
   req <- request("https://apicarto.ign.fr") |>
      req_url_path(path) |>
      req_url_query(!!!params)
}
#'
#' @description hit api from and httr2 request
#' @param req an httr2_request object
#' @return sf object
#' @noRd
#'
hit_api <- function(req){
   resp <- req_perform(req) |>
      resp_body_string() |>
      read_sf(quiet = TRUE)
}
#'
#' @description combine build_req and hit_api
#' @inheritParams build_req
#' @return sf object
#' @noRd
#'
build_req_hit_api <- function(path, ...){
   req <- build_req(path = path, ...)
   resp <- hit_api(req)
   message(nrow(resp), appendLF = F)

   return(resp)
}
#'
#' @description loop over api when limit exist
#' @param path path of the api
#' @param limit max number of feature api can returned
#' @param ... request parameters
#' @return sf object
#' @noRd
#'
loop_api <- function(path, limit, ...){

   # init
   message("Features downloaded : ", appendLF = F)
   resp <- build_req_hit_api(path, "_start" = 0, ...)

   # if more features than the limit are matched, it loop until everything is downloaded
   i <- limit
   temp <- resp
   while(nrow(temp) == limit){
      message("...", appendLF = F)
      temp <- build_req_hit_api(path, "_start" = i, ...)
      resp <- rbind(resp, temp)
      i <- i + limit
   }

   cat("\n")
   return(resp)
}
