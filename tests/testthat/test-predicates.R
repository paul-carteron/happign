test_that("simple predicate constructors return correct structure", {

   predicates <- list(
      "intersects" = intersects(),
      "within" = within(),
      "contains" = contains(),
      "touches" = touches(),
      "crosses" = crosses(),
      "overlaps" = overlaps(),
      "equals" = equals(),
      "bbox" = bbox()
   )

  Map(function(p, type) {
      expect_type(p, "list")
      expect_named(p, "type")
      expect_equal(p$type, type)
   }, predicates, names(predicates))

})

test_that("dwithin() and beyond() accept valid distance and units", {

   p1 <- dwithin(10, "meters")
   p2 <- beyond(5, "kilometers")

   expect_equal(p1$type, "dwithin")
   expect_equal(p1$distance, 10)
   expect_equal(p1$units, "meters")

   expect_equal(p2$type, "beyond")
   expect_equal(p2$distance, 5)
   expect_equal(p2$units, "kilometers")
})

test_that("dwithin() and beyond() reject invalid distance", {

   expect_error(dwithin("a", "meters"), "distance")
   expect_error(dwithin(c(1, 2), "meters"), "distance")
   expect_error(dwithin(NA_real_, "meters"), "distance")
   expect_error(dwithin(-1, "meters"), "non-negative")

   expect_error(beyond("a", "meters"), "distance")
   expect_error(beyond(-5, "meters"), "non-negative")
})

test_that("dwithin() and beyond() reject invalid units", {

   expect_error(dwithin(10, 1), "units")
   expect_error(dwithin(10, c("meters", "feet")), "units")

   expect_error(dwithin(10, "lightyears"), "Invalid")
   expect_error(dwithin(10, "yards"),"Invalid")

   expect_error(beyond(10, 1), "units")
   expect_error(beyond(10, c("meters", "feet")), "units")

   expect_error(beyond(10, "lightyears"), "Invalid")
   expect_error(beyond(10, "yards"),"Invalid")
})

test_that("relate() accepts valid DE-9IM pattern", {

   p <- relate("T*F**F***")

   expect_type(p, "list")
   expect_equal(p$type, "relate")
   expect_equal(p$pattern, "T*F**F***")
})

test_that("relate() rejects invalid patterns", {

   expect_error(relate(1))
   expect_error(relate("TF"))
   expect_error(relate("T*F**F**"))   # 8 chars
   expect_error(relate("T*F**F****")) # 10 chars
})
