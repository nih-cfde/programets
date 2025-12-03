# Get GitHub Repositories by Topic (GraphQL API)

Get GitHub Repositories by Topic (GraphQL API)

## Usage

``` r
get_github_by_topic_graphql(topics, token, limit = 30)
```

## Arguments

- topics:

  A vector of GitHub topics to search for.

- token:

  A GitHub personal access token. Required for GraphQL API.

- limit:

  The maximum number of repositories to return per topic (max 1000 by
  GitHub).

## Value

A data frame with repository metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- get_github_by_topic_graphql(c("u24ca289073"), token = "ghp_yourPAT")
dplyr::glimpse(df)
} # }
```
