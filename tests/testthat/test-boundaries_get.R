test_that("handles invalid inputs", {
  expect_error(boundaries_get(1, 1991),
    class = "error_not_single_string"
  )

  expect_error(boundaries_get(c("CAUTH", "CED"), 1991),
    class = "error_not_single_string"
  )

  expect_error(boundaries_get("random_text", 1991),
    class = "error_boundary_not_valid"
  )

  expect_error(boundaries_get("CAUTH", "123"),
               class = "error_not_single_number"
  )

  expect_error(boundaries_get("CAUTH", 123),
               class = "error_year_not_valid"
  )

  expect_error(boundaries_get("CAUTH", 1991, "BFE"),
    class = "error_boundary_invalid_combination"
  )
})
