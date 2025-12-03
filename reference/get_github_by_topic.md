# Get GitHub Repositories by Topic

Get GitHub Repositories by Topic

## Usage

``` r
get_github_by_topic(topics, token = NULL, limit = 30)
```

## Arguments

- topics:

  A vector of GitHub topics to search for.

- token:

  A GitHub personal access token. If not provided, the function will run
  without authentication.

- limit:

  The maximum number of results to return. Defaults to 30.

## Value

A data frame containing the results of the search query.

## Examples

``` r
topics <- c("u24ca289073")
df <- get_github_by_topic(topics, limit = 5)
#> ! No GitHub token provided. Running without authentication
#> ℹ Use of a Personal Access Token (PAT)is recommended for increased rate limits. Create a token with: usethis::create_github_token()
#> This message is displayed once every 8 hours.
head(df)
#> # A tibble: 5 × 19
#>   name               owner description stars watchers forks open_issues open_prs
#>   <chr>              <chr> <chr>       <dbl>    <dbl> <dbl>       <dbl>    <dbl>
#> 1 awesome-cancer-va… sean… A communit…   318       30    74           1        0
#> 2 GEOquery           sean… The bridge…   100        4    39          17        0
#> 3 MultiAssayExperim… wald… Bioconduct…    73       14    34           1        0
#> 4 SpatialExperiment  drig… NA             71        7    21          30        5
#> 5 BiocParallel       Bioc… Bioconduct…    69       16    31          29        1
#> # ℹ 11 more variables: closed_issues <dbl>, closed_prs <dbl>, commits <dbl>,
#> #   contributors <dbl>, tags <chr>, language <chr>, license <chr>,
#> #   created_at <chr>, pushed_at <chr>, updated_at <chr>, html_url <chr>
dplyr::glimpse(df)
#> Rows: 5
#> Columns: 19
#> $ name          <chr> "awesome-cancer-variant-resources", "GEOquery", "MultiAs…
#> $ owner         <chr> "seandavi", "seandavi", "waldronlab", "drighelli", "Bioc…
#> $ description   <chr> "A community-maintained repository of cancer clinical kn…
#> $ stars         <dbl> 318, 100, 73, 71, 69
#> $ watchers      <dbl> 30, 4, 14, 7, 16
#> $ forks         <dbl> 74, 39, 34, 21, 31
#> $ open_issues   <dbl> 1, 17, 1, 30, 29
#> $ open_prs      <dbl> 0, 0, 0, 5, 1
#> $ closed_issues <dbl> 2, 114, 269, 69, 150
#> $ closed_prs    <dbl> 5, 32, 64, 70, 102
#> $ commits       <dbl> 45, 951, 1814, 484, 796
#> $ contributors  <dbl> 4, 20, 19, 15, 21
#> $ tags          <chr> "awesome-list, bioinformatics, cancer, cancer-genomics, …
#> $ language      <chr> NA, "R", "R", "R", "R"
#> $ license       <chr> "MIT License", "Other", NA, NA, "Other"
#> $ created_at    <chr> "2016-07-07T13:16:14Z", "2013-07-19T06:44:10Z", "2013-07…
#> $ pushed_at     <chr> "2025-03-06T23:04:53Z", "2025-11-24T22:31:17Z", "2025-11…
#> $ updated_at    <chr> "2025-09-03T15:24:31Z", "2025-11-24T22:23:45Z", "2025-11…
#> $ html_url      <chr> "https://github.com/seandavi/awesome-cancer-variant-reso…
```
