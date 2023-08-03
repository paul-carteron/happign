structure(list(method = "GET", url = "https://apicarto.ign.fr/api/rpg/v1?param1=param1", 
    status_code = 400L, headers = structure(list(`Access-Control-Allow-Origin` = "*", 
        `Cache-Control` = "private, no-cache, no-store, must-revalidate", 
        Expires = "-1", Pragma = "no-cache", Vary = "Origin", 
        `Access-Control-Allow-Credentials` = "true", `Content-Type` = "application/json; charset=utf-8", 
        `Content-Length` = "154", Date = "Thu, 03 Aug 2023 10:21:18 GMT", 
        Connection = "keep-alive", `Keep-Alive` = "timeout=5", 
        `Set-Cookie` = "REDACTED", `Strict-Transport-Security` = "max-age=31536000; includeSubDomains"), class = "httr2_headers"), 
    body = charToRaw("{\"code\":400,\"message\":{\"annee\":{\"msg\":\"Invalid value\",\"param\":\"annee\",\"location\":\"body\"},\"geom\":{\"msg\":\"Invalid value\",\"param\":\"geom\",\"location\":\"body\"}}}")), class = "httr2_response")
