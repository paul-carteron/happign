test_that("apikeys return good keys", {
   apikeys = c(
      "administratif",
      "adresse",
      "agriculture",
      "altimetrie",
      "calcul",
      "cartes",
      "cartovecto",
      "clc",
      "economie",
      "environnement",
      "geodesie",
      "l93",
      "ortho",
      "orthohisto",
      "parcellaire",
      "satellite",
      "sol",
      "topographie",
      "transports"
   )
  expect_equal(get_apikeys(), apikeys)
  expect_equal(length(get_apikeys()), 19)
})
