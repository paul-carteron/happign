structure(list(method = "POST", url = "https://data.geopf.fr/wfs/ows?service=WFS&version=2.0.0&request=GetFeature&outputFormat=json&srsName=EPSG%3A4326&typeName=LIMITES_ADMINISTRATIVES_EXPRESS.LATEST%3Acommune&startindex=0&count=1000", 
    status_code = 200L, headers = structure(list(date = "Thu, 28 Mar 2024 10:54:41 GMT", 
        `content-type` = "application/json;charset=UTF-8", `www-authenticate` = "Key realm=\"kong\"", 
        `cache-control` = "private, max-age=1814400", `x-frame-options` = "SAMEORIGIN", 
        `content-disposition` = "inline; filename=commune.json", 
        `content-encoding` = "gzip", `strict-transport-security` = "max-age=15724800; includeSubDomains", 
        `access-control-allow-origin` = "*", `access-control-allow-credentials` = "true", 
        `access-control-allow-methods` = "GET, PUT, POST, DELETE, PATCH, OPTIONS", 
        `access-control-allow-headers` = "DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization", 
        `access-control-max-age` = "1728000", `set-cookie` = "REDACTED", 
        `transfer-encoding` = "chunked", `set-cookie` = "REDACTED"), class = "httr2_headers"), 
    body = charToRaw("{\"type\":\"FeatureCollection\",\"features\":[],\"totalFeatures\":0,\"numberMatched\":0,\"numberReturned\":0,\"timeStamp\":\"2024-03-28T10:54:41.070Z\",\"crs\":null}"), 
    request = structure(list(url = "https://data.geopf.fr/wfs/ows?service=WFS&version=2.0.0&request=GetFeature&outputFormat=json&srsName=EPSG%3A4326&typeName=LIMITES_ADMINISTRATIVES_EXPRESS.LATEST%3Acommune&startindex=0&count=1000", 
        method = NULL, headers = list(), body = list(data = list(
            cql_filter = structure("nom_m%20LIKE%20%27BADNAME%27", class = "AsIs")), 
            type = "form", content_type = "application/x-www-form-urlencoded", 
            params = list()), fields = list(), options = list(
            useragent = "happign (https://paul-carteron.github.io/happign/)"), 
        policies = list()), class = "httr2_request"), cache = new.env(parent = emptyenv())), class = "httr2_response")
