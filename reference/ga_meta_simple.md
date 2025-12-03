# Google analytics metadata dataframe

This function retrieves Google Analytics metadata and returns it as a
dataframe. The metadata includes information about metrics, dimensions,
and other attributes available in Google Analytics.

## Usage

``` r
ga_meta_simple()
```

## Value

A tibble containing Google Analytics metadata.

## Details

This function is a wrapper around the
[`googleAnalyticsR::ga_meta()`](https://rdrr.io/pkg/googleAnalyticsR/man/ga_meta.html)
function. It retrieves metadata for the Google Analytics API version 4.

## Note

This function requires first authenticating to Google Analytics using
the `ga_auth()` function.

## See also

Other Google Analytics: [`ga_query_explorer()`](ga_query_explorer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
res = ga_meta_simple()
head(res)
dplyr::glimpse(res)
} # }
```
