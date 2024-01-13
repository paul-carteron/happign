structure(list(method = "POST", url = "https://wxs.ign.fr/administratif/geoportail/wfs?service=WFS&version=2.0.0&request=GetFeature&outputFormat=json&srsName=EPSG%3A4326&typeName=LIMITES_ADMINISTRATIVES_EXPRESS.LATEST%3Acommune&startindex=0&count=1000", 
    status_code = 200L, headers = structure(list(date = "Sat, 13 Jan 2024 16:04:31 GMT", 
        `content-type` = "application/json;charset=UTF-8", `transfer-encoding` = "chunked", 
        `x-frame-options` = "SAMEORIGIN", `content-disposition` = "inline; filename=features.json", 
        `wl-original-content-type` = "application/json;charset=UTF-8", 
        `cache-control` = "public, max-age=1814400", `access-control-allow-methods` = "GET, POST", 
        `access-control-max-age` = "43200", `access-control-allow-origin` = "*"), class = "httr2_headers"), 
    body = charToRaw("{\"type\":\"FeatureCollection\",\"features\":[],\"totalFeatures\":0,\"numberMatched\":0,\"numberReturned\":0,\"timeStamp\":\"2024-01-13T16:04:31.448Z\",\"crs\":null}"), 
    request = structure(list(url = "https://wxs.ign.fr/administratif/geoportail/wfs?service=WFS&version=2.0.0&request=GetFeature&outputFormat=json&srsName=EPSG%3A4326&typeName=LIMITES_ADMINISTRATIVES_EXPRESS.LATEST%3Acommune&startindex=0&count=1000", 
        method = NULL, headers = list(), body = list(data = list(
            cql_filter = structure("nom_m%20LIKE%20%27BADNAME%27", class = "AsIs")), 
            type = "form", content_type = "application/x-www-form-urlencoded", 
            params = list()), fields = list(), options = list(
            useragent = "happign (https://paul-carteron.github.io/happign/)"), 
        policies = list()), class = "httr2_request"), cache = new.env(parent = emptyenv())), class = "httr2_response")
