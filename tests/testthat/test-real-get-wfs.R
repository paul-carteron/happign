test_that("get_wfs() works", {

   skip_on_cran()
   skip_if_offline()
   skip_if_not(Sys.getenv("RUN_REAL_API_TESTS") == "true")

   x <- sf::read_sf(system.file("extdata/penmarch.shp", package = "happign"))
   layer <- "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune"

   res <- get_wfs(x, layer, verbose = FALSE)

   expect_s3_class(res, "sf")
   expect_shape(res, nrow = 1)
})

test_that("get_wfs() all predicate works", {

   skip_on_cran()
   skip_if_offline()
   skip_if_not(Sys.getenv("RUN_REAL_API_TESTS") == "true")

   x <- sf::read_sf(system.file("extdata/penmarch.shp", package = "happign"))
   x_com <- get_wfs(x, "BDCARTO_V5:commune")
   x_point <- sf::st_centroid(x) |> suppressWarnings()

   bbox <- get_wfs(x_point, "BDCARTO_V5:occupation_du_sol", bbox())
   disjoint <- get_wfs(x_point, "patrinat_rnc:pnm", disjoint())
   intersects <- get_wfs(x_point, "BDCARTO_V5:occupation_du_sol", intersects())
   contains <- get_wfs(x_point, "BDCARTO_V5:occupation_du_sol", contains())
   within <- get_wfs(x_com, "BDCARTO_V5:occupation_du_sol", within())
   crosses <- get_wfs(x_com, "BDCARTO_V5:cours_d_eau", crosses())
   overlaps <- get_wfs(x_point, "BDCARTO_V5:occupation_du_sol", contains())
   dwithin <- get_wfs(x_point, "BDCARTO_V5:occupation_du_sol", dwithin(distance = 10, unit = "meters"))
   beyond <- get_wfs(x_point, "patrinat_rnc:pnm", beyond(distance = 500, unit = "kilometers"))
   #"LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune" = touches(),
   #"LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune" = equals(),

   res <- list(bbox, disjoint, intersects, contains, within, crosses, overlaps, dwithin, beyond)
   lapply(res, \(x){
      expect_s3_class(x, "sf")
      expect_true(nrow(x) >= 1)
   })
})


