structure(list(method = "GET", url = "https://wxs.ign.fr/environnement/geoportail/r/wms?service=WMS&version=1.3.0&request=GetFeatureInfo&format=image%2Fgeotiff&query_layers=FORETS.PUBLIQUES&layers=FORETS.PUBLIQUES&styles=&width=1&height=1&crs=EPSG%3A4326&bbox=47.812%2C-4.345%2C47.814%2C-4.343&I=1&J=1&info_format=application%2Fjson", 
    status_code = 200L, headers = structure(list(date = "Thu, 03 Aug 2023 10:22:17 GMT", 
        `content-type` = "application/json;charset=UTF-8", `transfer-encoding` = "chunked", 
        `content-disposition` = "filename=\"file\"", `wl-original-content-type` = "application/json;charset=UTF-8", 
        `cache-control` = "public, max-age=1814400", `access-control-allow-methods` = "GET, POST", 
        `access-control-max-age` = "43200", `access-control-allow-origin` = "*"), class = "httr2_headers"), 
    body = charToRaw("{\"type\":\"FeatureCollection\",\"features\":[],\"totalFeatures\":\"unknown\",\"numberReturned\":0,\"timeStamp\":\"2023-08-03T10:22:17.246Z\",\"crs\":null}")), class = "httr2_response")
