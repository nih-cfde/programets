library(testthat)
library(programets)
library(gitcreds)

test_that("get_github_by_topic_graphql() errors if topics is empty", {
  skip_on_cran()
  skip_on_ci()
  expect_error(get_github_by_topic_graphql(character(), token = gitcreds_get()$password), "At least one topic must be provided")
})

test_that("get_github_by_topic_graphql() returns a data frame", {
  skip_on_cran()
  skip_if_offline()
  skip_on_ci()

  result <- get_github_by_topic_graphql(c("rstats"), token = gitcreds_get()$password, limit = 5)
  expect_s3_class(result, "data.frame")
})

test_that("Returned data frame contains expected columns", {
  skip_on_cran()
  skip_if_offline()
  skip_on_ci()

  result <- get_github_by_topic_graphql(c("bioinformatics"), token = gitcreds_get()$password, limit = 3)
  expected_cols <- c(
     "name", "owner", "description", "stars", "watchers", "forks", "open_issues", "open_prs", 
     "closed_issues", "closed_prs", "commits", "contributors", "tags", "language", "license", 
     "created_at", "pushed_at", "updated_at", "html_url"
  )
  expect_true(all(expected_cols %in% names(result)))
})

test_that("get_github_by_topic_graphql() returns no results for nonsense topic", {
  skip_on_cran()
  skip_if_offline()
  skip_on_ci()

  result <- get_github_by_topic_graphql(c("thisisaveryunlikelytopicname1234567890"), token = gitcreds_get()$password)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})
