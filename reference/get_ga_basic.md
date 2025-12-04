# Get Basic Google Analytics Info

This function takes a character vector of NIH Core Project Numbers and
returns a data frame containing the any Google Analytics properties
associated with the Core Project Numbers.

## Usage

``` r
get_ga_basic(
  core_project_numbers,
  service_account_json = "cfde-access-keyfile.json"
)
```

## Arguments

- core_project_numbers:

  A character vector of NIH Core Project Numbers

- service_account_json:

  A character string containing the path to a JSON file containing the
  Google service account credentials. If no file is provided,
  interactive authentication is used. Defaults to
  "cfde-access-keyfile.json"

## Value

A data frame containing the associated Google Analytics data
