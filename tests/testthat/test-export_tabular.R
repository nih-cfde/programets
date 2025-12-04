library(gitcreds)

test_that("export_tabular writes an Excel file", {
  temp_file <- file.path(tempdir(), paste0("programets_", Sys.Date(), ".xlsx", sep = ""))
  on.exit(unlink(temp_file))
  core_project_numbers <- c("OT2OD030545")
  token <- gitcreds_get()$password
  export_tabular(core_project_numbers = core_project_numbers, token = token, dir = tempdir())
  expect_true(file.exists(temp_file))
})

test_that("export_tabular throws an error if the file already exists", {
  temp_file <- file.path(tempdir(), paste0("programets_", Sys.Date(), ".xlsx", sep = ""))
  on.exit(unlink(temp_file))
  core_project_numbers <- c("OT2OD030545")
  token <- gitcreds_get()$password
  file.create(temp_file)
  expect_error(export_tabular(core_project_numbers = core_project_numbers, token = token, dir = tempdir()), "File already exists")
})

