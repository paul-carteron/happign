structure(list(method = "GET", url = "https://apicarto.ign.fr/api/cadastre/parcelle?code_insee=29135&section=AX&numero=0010&source_ign=PCI&_start=0&_limit=500", 
    status_code = 200L, headers = structure(list(Date = "Mon, 09 Sep 2024 07:27:08 GMT", 
        `Content-Type` = "application/json; charset=utf-8", `Content-Length` = "804", 
        Connection = "keep-alive", `X-Powered-By` = "Express", 
        `Access-Control-Allow-Origin` = "*", `Cache-Control` = "private, no-cache, no-store, must-revalidate", 
        Expires = "-1", Pragma = "no-cache", Vary = "Origin", 
        `Access-Control-Allow-Credentials` = "true", ETag = "W/\"324-S+XHBZApe71O/QRWx4fySbDpbbU\"", 
        `Strict-Transport-Security` = "max-age=31536000; includeSubDomains"), class = "httr2_headers"), 
    body = charToRaw("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"id\":\"parcelle.472931\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[-4.19691629,47.80650745],[-4.19690919,47.80661733],[-4.19690468,47.80668494],[-4.19582764,47.80665889],[-4.19583718,47.80647402],[-4.19691629,47.80650745]]]]},\"geometry_name\":\"geom\",\"properties\":{\"numero\":\"0010\",\"feuille\":1,\"section\":\"AX\",\"code_dep\":\"29\",\"nom_com\":\"Loctudy\",\"code_com\":\"135\",\"com_abs\":\"000\",\"code_arr\":\"000\",\"idu\":\"29135000AX0010\",\"code_insee\":\"29135\",\"contenance\":1633},\"bbox\":[-4.19691629,47.80647402,-4.19582764,47.80668494]}],\"totalFeatures\":1,\"numberMatched\":1,\"numberReturned\":1,\"timeStamp\":\"2024-09-09T07:27:08.024Z\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::4326\"}},\"bbox\":[-4.19691629,47.80647402,-4.19582764,47.80668494]}"), 
    cache = new.env(parent = emptyenv())), class = "httr2_response")
