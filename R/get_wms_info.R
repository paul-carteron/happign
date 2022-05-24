# library(httr2)
# library(sf)
# library(xml2)
#
# shape <- mapedit::drawFeatures()
#
# get_wms_info <- function(shape,
#                          layer_name = "ORTHOIMAGERY.ORTHOPHOTOS.BDORTHO",
#                          version = "1.3.0"){
#
#    bbox <- st_bbox(shape)
#    bbox <- paste(bbox["ymin"], bbox["xmin"], bbox["ymax"], bbox["xmax"], sep = ",")
#
#    request <- request("https://wxs.ign.fr/ortho/geoportail/r/wms") %>%
#       req_user_agent("happign (https://paul-carteron.github.io/happign/)") %>%
#       req_url_query(service = "WMS",
#                     version = version,
#                     request = "GetFeatureInfo",
#                     format = "image/geotiff",
#                     query_layers = layer_name,
#                     layers = layer_name,
#                     styles = "",
#                     width = 2064,
#                     height = 2064,
#                     crs = "EPSG:4326",
#                     bbox = bbox,
#                     I = 1,
#                     J = 1,
#                     info_format = "text/xml") %>%
#       req_perform() %>%
#       resp_body_xml() %>%
#       xml_child(2) %>%
#       xml_child(1) %>%
#       as_list()
#
#    res <- test[!grepl("geom", names(test))] %>%
#       unlist() %>%
#       bind_rows()
# }
