test_that("get_geojson work", {
   poly <- happign:::poly
   poly_json <- get_geojson(poly)
   expect_match(poly_json,
                paste0('\\{"type":"Polygon","coordinates":\\[\\[',
                       '\\[-4\\.34.*,47\\.81.*\\],',
                       '\\[-4\\.34.*,47\\.81.*\\],',
                       '\\[-4\\.34.*,47\\.81.*\\],',
                       '\\[-4\\.34.*,47\\.81.*\\]',
                       '\\]\\]\\}'))
})

test_that("process_character_input work", {
   expect_equal(process_character_input("123"),
                list(code_insee = NULL, code_dep = "123"))
   expect_equal(process_character_input("12"),
                list(code_insee = NULL, code_dep = "12"))
   expect_equal(process_character_input("12345"),
                list(code_insee = "12345", code_dep = NULL))
   expect_error(process_character_input("123245"),"Character input 'x' must be")
})

test_that("create_params work", {
   simple_params <- create_params(1, 2, 3, 4, 5, 6, 7, 8, "pci")
   expect_equal(simple_params,
                list(
                   list(geom = 1, code_insee = 2, code_dep = 3, code_com = "004",
                        section = '05', numero = '0006', code_arr = '007', code_abs = '008',
                        source_ign = "PCI", `_start` = 0, `_limit` = 500)
                )
   )

   multiple_params <- create_params(c(1, 1), c(2, 2), NULL, NULL, NULL, NULL, NULL, NULL, "pci")
   expect_equal(multiple_params,
                list(
                   list(
                      geom = 1,
                      code_insee = 2,
                      code_dep = NULL,
                      code_com = NULL,
                      section = NULL,
                      numero = NULL,
                      code_arr = NULL,
                      code_abs = NULL,
                      source_ign = "PCI",
                      `_start` = 0,
                      `_limit` = 500
                   ),
                   list(
                      geom = 1,
                      code_insee = 2,
                      code_dep = NULL,
                      code_com = NULL,
                      section = NULL,
                      numero = NULL,
                      code_arr = NULL,
                      code_abs = NULL,
                      source_ign = "PCI",
                      `_start` = 0, `_limit` = 500)
                   )
                )

})

with_mock_dir("fetch_data", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("fetch_data", {
      skip_on_cran()
      skip_if_offline()
      skip_on_ci()

      simple_params <- list(list(geom = NULL, code_insee = "29158", code_dep = NULL,
                                 code_com = NULL, section = NULL, numero = NULL, code_arr = NULL,
                                 code_abs = NULL, source_ign = "PCI", `_start` = 0, `_limit` = 500))
      res = fetch_data(simple_params[[1]], "commune", F)

      expect_equal(class(res), "list")
      expect_s3_class(res[[1]], "httr2_response")
      expect_equal(res[[1]]$url, "https://apicarto.ign.fr/api/cadastre/commune?code_insee=29158&source_ign=PCI&_start=0&_limit=500")
   })
}, simplify = FALSE)

with_mock_dir("fetch_data error dtolerance", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("fetch_data", {
      skip_on_cran()
      skip_if_offline()
      skip_on_ci()

      # Error
      dtolerance_params <- list(list(geom = get_geojson(st_buffer(happign:::point, 10000)),
                                     code_insee = NULL, code_dep = NULL,
                                     code_com = NULL, section = NULL, numero = NULL, code_arr = NULL,
                                     code_abs = NULL, source_ign = "PCI", `_start` = 0, `_limit` = 500))
      expect_error(fetch_data(dtolerance_params[[1]], "commune", F),
                   "Shape is too complex.")
      })
}, simplify = FALSE)

with_mock_dir("fetch_data error no data", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("fetch_data", {
      skip_on_cran()
      skip_if_offline()
      skip_on_ci()

      # Error
      no_data_params <- list(list(geom = NULL,
                                  code_insee = "29760", code_dep = NULL,
                                  code_com =  NULL, section = "0001", numero = NULL, code_arr = NULL,
                                  code_abs = NULL, source_ign = "PCI", `_start` = 0, `_limit` = 500))
      expect_warning(fetch_data(no_data_params[[1]], "commune", F),
                     "No data found for : 29760 - 0001")
      })
}, simplify = FALSE)


with_mock_dir("process_responses", {
   #/!\ Again, you have to manually change encoding "UTF-8" to "ISO-8859-1" !
   test_that("fetch_data", {
      skip_on_cran()
      skip_if_offline()
      skip_on_ci()

      simple_params <- list(list(geom = NULL, code_insee = "29158", code_dep = NULL,
                                 code_com = NULL, section = NULL, numero = NULL, code_arr = NULL,
                                 code_abs = NULL, source_ign = "PCI", `_start` = 0, `_limit` = 500))
      resp1 = fetch_data(simple_params[[1]], "commune", F)
      res = process_responses(resp1)

      expect_s3_class(res, "sf")
      expect_equal(dim(res), c(1, 5))

   })
}, simplify = FALSE)

with_mock_dir("get_apicarto_cadastre", {
   test_that("fetch_data", {
      skip_on_cran()
      skip_if_offline()
      skip_on_ci()

      params <- expand.grid(code_insee = c("29158", "29135"),
                            section = c("AX"),
                            numero = c("0001", "0010"),
                            stringsAsFactors = FALSE)
      parcels <- get_apicarto_cadastre(params$code_insee,
                                       section = params$section,
                                       numero = params$numero,
                                       type = "parcelle")

      expect_s3_class(parcels, "sf")
      expect_equal(dim(parcels), c(4, 13))
   })
}, simplify = FALSE)
