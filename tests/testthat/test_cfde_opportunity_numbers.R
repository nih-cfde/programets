test_that("cfde_opportunity_numbers returns a character vector", {
  # Test with a known CFDE opportunity number
  result <- cfde_opportunity_numbers()
  expect_type(result, "character")
})

test_that("cfde_opportunity_numbers returns expected pattern", {
  # Test that the returned opportunity numbers match the expected pattern
  result <- cfde_opportunity_numbers()
  pattern <- "(RFA|OTA|NOT)-[A-Z]{2}-\\d{2}-\\d{3}"
  expect_true(all(grepl(pattern, result)))
})