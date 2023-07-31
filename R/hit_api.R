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

      # test if cnd correspond to one error for complex shape
      too_complex_shape <- any(
         sapply(c("Send failure: Connection was reset",
                  "Failure when receiving data from the peer",
                  "OpenSSL SSL_read", #ubuntu
                  "HTTP 431", #macos
                  "Empty reply from server" #macos
                  ),
                function(x, cnd){grepl(x, cnd)},
                cnd = cnd))

      error6 <- "HTTP 404 Not Found"
      error7 <- "HTTP 400 Bad Request"

      if (too_complex_shape){
         stop("May be due to an overly complex shape : try increase `dTolerance` parameter.",
              call. = F)
      }else if (any(grepl(error6, cnd), grepl(error7, cnd))){
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
