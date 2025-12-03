# All CFDE Funding Opportunity Numbers

This function retrieves all CFDE funding opportunity numbers from the
CFDE funding website,
<https://commonfund.nih.gov/dataecosystem/FundingOpportunities>.

## Usage

``` r
cfde_opportunity_numbers(
  url = "https://commonfund.nih.gov/dataecosystem/FundingOpportunities"
)
```

## Arguments

- url:

  The URL of the CFDE funding webpage

## Value

a character vector of funding opportunity numbers.

## Details

Note that this function is specific to the CFDE program and is not a
general-purpose web scraping function.

## Examples

``` r
if (FALSE) { # \dontrun{
browseURL("https://commonfund.nih.gov/dataecosystem/FundingOpportunities")
} # }

cfde_opportunity_numbers()
#>  [1] "RFA-RM-24-006" "NOT-RM-24-006" "NOT-RM-24-003" "RFA-RM-23-014"
#>  [5] "RFA-RM-23-013" "RFA-RM-23-015" "RFA-RM-23-002" "NOT-RM-23-005"
#>  [9] "NOT-RM-23-006" "RFA-RM-23-003" "RFA-RM-22-007" "RFA-RM-21-007"
#> [13] "RFA-RM-19-012" "RFA-RM-19-012"
```
