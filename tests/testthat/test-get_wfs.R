test_that("chek_wfs_input", {
   expect_error(check_get_wfs_input("bad_input", "intersects"),
                "`shape` should have class `sf`, `sfc` or `NULL`")
   expect_error(check_get_wfs_input(point, "bad_input"),
                "`spatial_filter` should be one of : ")
   expect_no_error(check_get_wfs_input(point, "intersects"))
   expect_no_error(check_get_wfs_input(point, "INTERSECTS"))
   expect_no_error(check_get_wfs_input(point, c("intersects")))
   expect_no_error(check_get_wfs_input(point, c("intersects", NULL)))
   expect_no_error(check_get_wfs_input(point, c("dwithin", 50, "meters")))
})
test_that("save_wfs", {

   filename <- tempfile(fileext = ".shp")

   expect_no_warning(save_wfs(filename, point, F))
   expect_error(save_wfs(filename, point, F),
                "Dataset already exists")

   warn_resp <- st_as_sf(point)
   warn_resp$longerthant10char <- NA
   expect_warning(save_wfs(filename, warn_resp, T),
                  "abbreviated for ESRI Shapefile driver")

})
with_mock_dir("build_wfs", {
   test_that("build_wfs_req", {
      skip_on_cran()
      skip_if_offline()

      all_shp_type <- lapply(list(point, multipoint, line, multiline, poly, multipoly),
                             build_wfs_req,
                             apikey = "altimetrie",
                             layer_name = "ELEVATION.CONTOUR.LINE:courbe",
                             spatial_filter = "within")
      res <- lapply(all_shp_type, function(x){x$body$data$cql_filter})

      expect_match(res[[1]], "WITHIN(the_geom, POINT (47.813 -4.34", fixed = T)
      expect_match(res[[2]], "WITHIN(the_geom, MULTIPOINT ((47.813", fixed = T)
      expect_match(res[[3]], "WITHIN(the_geom, LINESTRING (47.813 ", fixed = T)
      expect_match(res[[4]], "WITHIN(the_geom, MULTILINESTRING ((4", fixed = T)
      expect_match(res[[5]], "WITHIN(the_geom, POLYGON ((47.813 -4", fixed = T)
      expect_match(res[[6]], "WITHIN(the_geom, MULTIPOLYGON (((47.", fixed = T)

      # no shape = no spatial filter
      expect_match(build_wfs_req(NULL, "altimetrie", "ELEVATION.CONTOUR.LINE:courbe","within")$body$data$cql_filter,
                   "")
      # combine spatial and ecql filter
      expect_match(build_wfs_req(point, "altimetrie", "ELEVATION.CONTOUR.LINE:courbe","within",
                                 "ecql_filter1 OR ecql_filter2")$body$data$cql_filter,
                   "WITHIN(the_geom, POINT (47.813 -4.344)) AND ecql_filter1 OR ecql_filter2",
                   fixed = T)
   })},
   simplify = FALSE)
with_mock_dir("wfs_intersect", {
   test_that("wfs_intersect", {
      skip_on_cran()
      skip_if_offline()

      apikey <- "administratif"
      layer_name <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      spatial_filter <- "intersects"

      all_shp_type <- lapply(list(point, multipoint, line, multiline, poly, multipoly),
                             get_wfs,
                             apikey = "administratif",
                             layer_name = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune",
                             spatial_filter = "intersects")

      invisible(lapply(all_shp_type, expect_s3_class, class = "sf"))
      invisible(lapply(all_shp_type, function(x){expect_equal(dim(x), c(1,12))}))
      invisible(lapply(all_shp_type, function(x){expect_true(st_drop_geometry(x)[1,3] == "PENMARCH")}))
   })},
   simplify = FALSE)

with_mock_dir("wfs_ecql_filter", {
   test_that("get_wfs_ecql", {
      skip_on_cran()
      skip_if_offline()

      apikey <- "administratif"
      layer_name <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      spatial_filter <- NULL
      ecql_filter <- "nom_m LIKE 'PEN%RCH' AND population < 6000"

      resp <- get_wfs(point, apikey, layer_name, NULL, spatial_filter, ecql_filter)
      expect_s3_class(resp, "sf")
      expect_equal(dim(resp), c(1,12))
      expect_true(st_drop_geometry(resp)[1,3] == "PENMARCH")
})},
simplify = FALSE)

with_mock_dir("wfs_empty", {
   test_that("get_wfs empty_features", {
      skip_on_cran()
      skip_if_offline()

      apikey <- "administratif"
      layer_name <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"
      ecql_filter <- "nom_m LIKE 'BADNAME'"

      expect_warning(get_wfs(apikey = apikey,
                              layer_name = layer_name,
                              ecql_filter = ecql_filter),
                     "No features find.")
})},
simplify = FALSE)

