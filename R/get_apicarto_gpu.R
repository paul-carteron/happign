# get_apicarto_gpu
# API document permet de récupérer les id de tous les documents d'urbanismes
# Celle avec prescription surfacique permet d'avoir les shapes ;)
# Limiter à 5000 shape, il va falloir créer la boucle
# Il faudra également lancer les API pour les linéaire et les points
#
# library(sf)
# library(httr)
# library(geojsonsf)
# library(geojsonR)
#
# x <- st_transform(shape, 4326)
# geojson_geom <- sfc_geojson(st_as_sfc(x))
# query_parameter = list(geom = geojson_geom)
#
# urls <- modify_url("https://apicarto.ign.fr",
#                             path = "api/gpu/prescription-surf",
#                             query = query_parameter)
#
# nb_loop <- lapply(urls, function(x){content(GET(x))$totalFeatures %/% 5000 + 1})
#
# test <- read_sf(GET(urls),  quiet = TRUE)
#
#
# parcelles <- lapply(seq_along(urls), bind_resp, urls) %>%
#    bind_rows()
