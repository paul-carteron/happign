x <- read_sf(system.file("extdata/penmarch.shp", package = "happign"))

# bbow_dim test
test_that("bbox_dim works", {
   dim <- bbox_dim(x)

   expect_error(bbox_dim(NA))
   expect_error(bbox_dim(NULL))
   expect_error(bbox_dim(10))

   expect_type(dim, "double")
   expect_named(dim, c("width", "height"))

   expect_equal(as.numeric(dim), c(766.03, 829.84), tolerance = 0.1)
})
test_that("bbox_dim handle multiple coordinate", {

   verif <- c(width = 766.03, height = 829.84)
   tol <- 0.1

   #Lambert 93
   x_2154 <- st_transform(x, 2154) |> bbox_dim() |>
      expect_equal(verif, tolerance = tol)
   #WGS84
   x_4326 <- st_transform(x, 4326) |> bbox_dim() |>
      expect_equal(verif, tolerance = tol)
   #Lambert II extended
   x_27572 <- st_transform(x, 27572) |> bbox_dim()|>
      expect_equal(verif, tolerance = tol)
   #Lambert I Used in Corsica
   x_27591 <- st_transform(x, 27591) |> bbox_dim()|>
      expect_equal(verif, tolerance = tol)
   #unprojected
   x_crs84 <- st_transform(x, "CRS:84") |> bbox_dim() |>
      expect_equal(verif, tolerance = tol)

})

# create_grid
test_that("create_grid works", {

   expect_error(create_grid(NA, res = 0.1))
   expect_error(create_grid(x, res = NA))
   expect_error(create_grid(x))

   grid <- create_grid(x, res = 0.1)

   expect_s3_class(grid, "sf")
   expect_equal(dim(grid), c(16, 1))

   })

# create url
test_that("create_urls works", {

   expect_error(create_urls(NA))
   expect_error(create_urls(x, "", NA))

   urls <- create_urls(rbind(x,x), base_url = "base_url", res = 1)
   expect_type(urls, "character")
   expect_length(urls, 2)
   expect_match(urls[1], "base_url&bbox=47.*,-4.*,47.*,-4.*&width=.*&height=")
})
test_that("create_urls longlat", {

   urls_2154 <- create_urls(st_transform(x, 2154),
                            base_url = "base_url",
                            res = 1)
   urls_4326 <- create_urls(st_transform(x, 4326),
                            base_url = "base_url",
                            res = 1)

   expect_type(urls_2154, "character")
   expect_type(urls_4326, "character")
   expect_length(urls_2154, 1)
   expect_length(urls_4326, 1)

   expect_match(urls_2154,
                "base_url&bbox=148682.*,6769648.*&width=.*&height=")
   expect_match(urls_4326,
                "base_url&bbox=47.*,-4.*&width=.*&height=")
})
