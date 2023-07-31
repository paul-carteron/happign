#' @title build_req
#' @description Build request from path and parameter.
#'
#' @param path `character`; path of the api
#' @param ... request parameters
#'
#' @importFrom httr2 request req_url_path req_url_query
#'
#' @return `httr2_request` object
#' @noRd
#'
build_req <- function(path, ...) {

   class_check(path, "character")

   params <- list(...)

   req <- request("https://apicarto.ign.fr") |>
      req_url_path(path) |>
      req_url_query(!!!params)
}

#' @title hit_api
#' @description Hit api from an httr2 request and read result as `sf` object.
#'
#' @param req `httr2_request` object
#'
#' @importFrom httr2 req_perform resp_body_string
#' @importFrom sf read_sf
#'
#' @return `sf` object
#' @noRd
#'
hit_api <- function(req){
   tryCatch({
      resp <- req_perform(req) |>
         resp_body_string() |>
         read_sf(quiet = TRUE)
   },
   error = function(cnd){

      error1 <- "Send failure: Connection was reset"
      error2 <- "Failure when receiving data from the peer"
      error3 <- "HTTP 404 Not Found"
      error4 <- "HTTP 400 Bad Request"

      if (grepl(error1, cnd) | grepl(error2, cnd)){
         stop("May be due to an overly complex shape : try increase `dTolerance` parameter.",
              call. = F)
      }else if (grepl(error3, cnd) | grepl(error4, cnd)){
         stop(cnd, "Probably due to bad parameters.", call. = F)
      }
      stop(cnd)

   })
}

#' @title build_req_hit_api
#' @description Combine `build_req` and `hit_api` function.
#'
#' @param path `character`; path of the api
#' @param ... request parameters
#'
#' @return `sf` object
#' @noRd
#'
build_req_hit_api <- function(path, ...){
   req <- build_req(path = path, ...)
   resp <- hit_api(req)

   return(resp)
}

#' @title loop_api
#' @description Loop over api when limit exist.
#'
#' @param path `character`; path of the api
#' @param limit `integer`; max number of feature api can returned
#' @param ... request parameters
#'
#' @return `sf` object
#' @noRd
#'
loop_api <- function(path, limit, ...){

   # init
   message("Features downloaded : ", appendLF = F)
   resp <- build_req_hit_api(path, "_start" = 0, ...)
   message(nrow(resp), appendLF = F)

   # if more features than the limit are matched, it loop until everything is downloaded
   i <- limit
   temp <- resp
   while(nrow(temp) == limit){
      message("...", appendLF = F)
      temp <- build_req_hit_api(path, "_start" = i, ...)
      resp <- rbind(resp, temp)
      message(nrow(resp), appendLF = F)
      i <- i + limit
   }

   cat("\n")
   return(resp)
}
