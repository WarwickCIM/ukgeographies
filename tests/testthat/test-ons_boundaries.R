test_that("Boundaries with unique ids", {
  expect_true(
    anyDuplicated(ons_boundaries$id) == 0, 
    info = "There are duplicate values in the 'id' column of the 'ons_boundaries' dataframe"
  )
})
