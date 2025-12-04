# Google Analytics metadata dataframe by property ID

This function retrieves Google Analytics metadata by property ID and
returns it as a dataframe. The metadata includes information about
metrics, dimensions, and other attributes available in Google Analytics.

## Usage

``` r
get_ga_meta_by_id(property_id)
```

## Arguments

- property_id:

  The property ID for which to retrieve metadata.

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

Other Google Analytics: [`ga_meta_simple()`](ga_meta_simple.md),
[`ga_query_explorer()`](ga_query_explorer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
res = get_ga_meta_by_id("123456789")
head(res)
dplyr::glimpse(res)
} # }
```
