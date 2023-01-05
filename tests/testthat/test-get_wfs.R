penmarch <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

test_that("chek_wfs_input", {
   expect_error(check_get_wfs_input("bad_input", "intersects"),
                "`shape` should have class `sf`, `sfc` or `NULL`")
   expect_error(check_get_wfs_input(penmarch, "bad_input"),
                "`spatial_filter` should be one of : ")
   expect_no_error(check_get_wfs_input(penmarch, "intersects"))
   expect_no_error(check_get_wfs_input(penmarch, "INTERSECTS"))
   expect_no_error(check_get_wfs_input(penmarch, c("intersects")))
   expect_no_error(check_get_wfs_input(penmarch, c("intersects", NULL)))
   expect_no_error(check_get_wfs_input(penmarch, c("dwithin", 50, "meters")))
})
test_that("save_wfs", {

   filename <- tempfile(fileext = ".shp")

   warn_resp <- penmarch[,1]
   names(warn_resp)[1] <- "longerthant10char"

   expect_no_warning(save_wfs(filename, penmarch[,1], F))
   expect_error(save_wfs(filename, penmarch[,1], F),
                "Dataset already exists")
   expect_warning(save_wfs(filename, warn_resp, T),
                  "abbreviated for ESRI Shapefile driver")

})

with_mock_dir("build_wfs", {
   test_that("build_wfs_req", {
      skip_on_cran()
      skip_if_offline()

      point <- suppressWarnings(st_centroid(penmarch))
      expect_match(build_wfs_req(point,"altimetrie", "ELEVATION.CONTOUR.LINE:courbe","within")$body$data$cql_filter,
                   "WITHIN(the_geom, POINT (47.79967 -4.369559))", fixed = T)
      # no shape = no spatial filter
      expect_match(build_wfs_req(NULL, "altimetrie", "ELEVATION.CONTOUR.LINE:courbe","within")$body$data$cql_filter,
                   "")
      # combine spatial and ecql filter
      expect_match(build_wfs_req(point, "altimetrie", "ELEVATION.CONTOUR.LINE:courbe","within",
                                 "ecql_filter1 OR ecql_filter2")$body$data$cql_filter,
                   "WITHIN(the_geom, POINT (47.79967 -4.369559)) AND ecql_filter1 OR ecql_filter2",
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

      resp <- get_wfs(penmarch, apikey, layer_name, NULL, spatial_filter)
      expect_s3_class(resp, "sf")
      expect_equal(dim(resp), c(1,12))
      expect_true(st_drop_geometry(resp)[1,3] == "PENMARCH")
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

      resp <- get_wfs(penmarch, apikey, layer_name, NULL, spatial_filter, ecql_filter)
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

