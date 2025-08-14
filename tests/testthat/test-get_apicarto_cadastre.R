f_test <- \(x, ...) get_apicarto_cadastre(x, ..., progress = FALSE)

test_that("bad type", {
   expect_error(f_test("29158", type = "bad"), regexp = "should be one of")
})

test_that("multipoint aren't supported", {
   err_msg <- "`MULTIPOINT` geometry aren't supported by apicarto."
   expect_error(f_test(happign:::multipoint), err_msg)
})


test_that("x must be sf/sfc or valid INSEE/DEP", {
   err_msg <- "must be either an `sf` / `sfc` object, or a character vector"

   expect_error(f_test("oops"), err_msg)
   expect_error(f_test("00000"), err_msg)
   expect_error(f_test("123"), err_msg)
   expect_error(f_test(123), err_msg)
})

test_that("geometry must contain exactly one feature", {
   err_msg <- "Cadastre API only accepts one geometry per request"
   two_features <- c(happign:::poly, happign:::poly)
   expect_error(f_test(two_features), err_msg)
})

test_that("arrondissement INSEE codes are enforced", {

   err_msg <- \(x) paste("Codes", paste(x, collapse = ", "), "correspond to cities with arrondissements")
   arr <- c(75056, 69123, 13055)

   expect_error(ensure_is_not_arr(arr[1]), err_msg(arr[1]))
   expect_error(ensure_is_not_arr(arr), err_msg(arr))

   # nothing happened when insee_code is valid
   expect_null(ensure_is_not_arr(29158))

})

test_that("ambiguous vectorisation", {

   err_msg <- "Ambiguous vectorization: multiple arguments have length > 1"
   expect_error(
      f_test(c("29158", "29135"), section = c("AW", "BR"), numero  = "0001"),
      err_msg
   )

   expect_error(
      f_test("29158", section = c("AW", "BR"), numero  = c("0001", "0002")),
      err_msg
   )

})

# tests/testthat/test-cadastre-httptest2.R
with_mock_dir("apicarto-cadastre", {
   skip_on_cran()
   skip_if_offline()

   expect_sf <- \(x, type = c("POLYGON", "MULTIPOLYGON"), row = 1) {
      expect_s3_class(x, "sf")
      expect_true(any(st_geometry_type(x) %in% type))
      expect_true(nrow(x) >= row)
   }

   test_that("apicarto cadastre works insee", {
      expect_sf(f_test("29158"))
   })

   test_that("apicarto cadastre works dep", {
      expect_sf(f_test("29", section="FG", type = "section"))
   })

   test_that("apicarto cadastre geom", {
      lapply(
         list(
            happign:::poly, happign:::multipoly,
            happign:::point, #happign:::multipoint,
            happign:::line, happign:::multiline
            ),
         \(x) {expect_sf(f_test(x))}
      )

   })

   test_that("apicarto cadastre vectorization works", {
      expect_sf(
         f_test("29158", section = "AW", numero = 1:2, type = "parcelle"),
         row = 2
      )
   })

   test_that("apicarto cadastre localisant works", {
      expect_sf(
         f_test("29158", section = "AW", numero = 1, type = "localisant"),
         type = c("POINT", "MULTIPOINT")
      )
   })

   test_that("apicarto cadastre section works", {
      expect_sf(f_test("29158", section = "AW", type = "section"))
      expect_sf(f_test("29158", section = "AW", type = "section", source = "bdp"))
   })

   test_that("empty results are handled", {
         expect_warning(
            f_test("29158", type = "parcelle", section = "ZZ", numero = "9999"),
            "No data found for : 29158 - ZZ - 9999"
            )

         expect_null(f_test("29158", type = "parcelle", section = "ZZ") |> suppressWarnings())

      })

})
