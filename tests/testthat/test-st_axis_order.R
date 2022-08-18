test_that("grid", {

   sf::st_axis_order(authority_compliant = T)

   shp <- sf::st_transform(
      sf::st_sfc(sf::st_point(c(45, -64)), crs = "EPSG:4326"),
      "OGC:CRS84"
   )

   expect_equal(as.numeric(shp[[1]]), c(-64,45))

})

test_that("grid", {

   sf::st_axis_order(authority_compliant = F)

   crs <- 4326

   shp <- sf::st_sfc(sf::st_point(c(45, -64)), crs = st_crs(crs))
   shp

   if(st_is_longlat(st_crs(crs))){
      st_axis_order(T)
      shp <- st_transform(shp, "CRS:84")
   }

   expect_equal(as.numeric(shp[[1]]), c(-64,45))

})


