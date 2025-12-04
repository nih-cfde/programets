# Export to Tabular

Export to Tabular

## Usage

``` r
export_tabular(
  core_project_numbers,
  token = gitcreds::gitcreds_get()$password,
  service_account_json = "cfde-access-keyfile.json",
  dir,
  csv = FALSE
)
```

## Arguments

- core_project_numbers:

  A character vector of NIH Core Project Numbers

- token:

  The token required for authentication with the GitHub API

- service_account_json:

  A character string containing the path to a JSON file containing a
  Google service account

- dir:

  A character string containing the path to directory where the Excel
  file will be written

- csv:

  A logical indicating whether to write a CSV file

## Examples

``` r
if (FALSE) { # \dontrun{
test_projects <-c("OT2OD030545")
} # }
```
