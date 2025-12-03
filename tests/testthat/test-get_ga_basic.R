test_that("get_ga_basic returns expected values", {
  core_project_numbers <- c("u54od036472", "99999999")
  result <- get_ga_basic(core_project_numbers = core_project_numbers)
  expect_s3_class(result, "tbl_df")
   expect_true("account_name" %in% names(result))
  expect_true("accountId" %in% names(result))
  expect_true("propertyId" %in% names(result))
  expect_true("property_name" %in% names(result))
  expect_true("core_project_num" %in% names(result))
  }
)
