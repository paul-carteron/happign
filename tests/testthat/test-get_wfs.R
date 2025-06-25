test_that("get_wfs_input_error", {
   # bad x class
   expect_error(get_wfs("bad_x", "intersects"),
                "`x` should have class `sf`, `sfc` or `NULL`")
   # wrong layer
   expect_error(get_wfs(happign:::point, "bad_layer"),
                "DescribeFeatureType returned 404")
   # wrong spatial filter
   expect_error(get_wfs(happign:::point, spatial_filter = "bad_spatial_filter"),
                "`spatial_filter` should be one")
})

test_that("save_wfs", {

   filename <- tempfile(fileext = ".shp")

   # throw error when file already exist
   expect_no_error(save_wfs(filename, point, F, quiet  =T))
   expect_error(save_wfs(filename, point, F),
                "Dataset already exists")

   # warning when colname is more than 10 char
   warn_resp <- st_as_sf(point)
   warn_resp$longerthant10char <- NA
   expect_warning(save_wfs(filename, warn_resp, overwrite = T, quiet  =T),
                  "abbreviated for ESRI Shapefile driver")


})

test_that("build_wfs_req", {
   skip_on_ci()
   skip_on_cran()
   req_by_shp <- lapply(list(point, multipoint, line, multiline, poly, multipoly),
                          build_wfs_req,
                          layer = "ELEVATION.CONTOUR.LINE:courbe",
                          spatial_filter = "within",
                          crs = 4326)

   cql_filters <- lapply(req_by_shp, function(x){x$body$data$cql_filter})

   expect_match(cql_filters[[1]], "WITHIN%28geom%2C%20POINT%20%2847", fixed = T)
   expect_match(cql_filters[[2]], "WITHIN%28geom%2C%20MULTIPOINT%20", fixed = T)
   expect_match(cql_filters[[3]], "WITHIN%28geom%2C%20LINESTRING%20", fixed = T)
   expect_match(cql_filters[[4]], "WITHIN%28geom%2C%20MULTILINESTRI", fixed = T)
   expect_match(cql_filters[[5]], "WITHIN%28geom%2C%20POLYGON%20%28", fixed = T)
   expect_match(cql_filters[[6]], "WITHIN%28geom%2C%20MULTIPOLYGON%", fixed = T)

   # if x = NULL there cannot be any spatial filters
   req <- build_wfs_req(x = NULL,layer = "ELEVATION.CONTOUR.LINE:courbe",
                        spatial_filter = "within",
                        crs = 4326)
   ecql_filter <- req$body$data$cql_filter
   expect_match(ecql_filter, "")

   # combine spatial and ecql filter
   req <- build_wfs_req(x = point,
                        layer = "ELEVATION.CONTOUR.LINE:courbe",
                        spatial_filter = "within",
                        ecql_filter = "ecql_filter1",
                        crs = 4326)
   ecql_filter <- req$body$data$cql_filter
   expect_match(ecql_filter,
                "WITHIN%28geom%2C%20POINT%20%2847.813%20-4.344%29%29%20AND%20ecql_filter1",
                fixed = T)
})

with_mock_dir("wfs_intersect", {
   test_that("wfs_intersect", {
      skip_on_cran()
      skip_on_ci()
      skip_if_offline()

      layer <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      spatial_filter <- "intersects"

      get_wfs_by_shp <- lapply(list(point, multipoint, line, multiline, poly, multipoly),
                             get_wfs,
                             layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
                             spatial_filter = "intersects")

      invisible(lapply(get_wfs_by_shp,
                       expect_s3_class, class = "sf"))
      })
   },simplify = FALSE)

with_mock_dir("wfs_ecql_filter", {
   test_that("get_wfs_ecql", {
      skip_on_cran()
      skip_if_offline()

      layer <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      spatial_filter <- NULL
      ecql_filter <- "nom_officiel_en_majuscules LIKE 'PEN%RCH' AND population < 6000"

      resp <- get_wfs(point, layer, NULL, spatial_filter, ecql_filter)
      expect_s3_class(resp, "sf")
})},
simplify = FALSE)

with_mock_dir("wfs_empty", {
   test_that("get_wfs empty_features", {
      skip_on_cran()
      skip_if_offline()

      layer <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      ecql_filter <- "nom_officiel_en_majuscules LIKE 'BADNAME'"

      expect_warning(get_wfs(layer = layer,
                             ecql_filter = ecql_filter),
                     "No data found, NULL is returned.")
})},
simplify = FALSE)
#
# # test for construct spatial filter
# expect_no_error(get_wfs(point, spatial_filter = "intersects"))
# expect_no_error(get_wfs(point, spatial_filter = "INTERSECTS"))
# expect_no_error(get_wfs(point, spatial_filter = c("intersects")))
# expect_no_error(get_wfs(point, spatial_filter = c("intersects", NULL)))
# expect_no_error(get_wfs(point, spatial_filter = c("dwithin", 50, "meters")))
