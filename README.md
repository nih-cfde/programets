
<!-- README.md is generated from README.Rmd. Please edit that file -->

# programets

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

**programets** is an R package for collecting and analyzing academic
impact metrics for NIH-funded research projects. It aggregates data from
multiple public sources to help researchers, program managers, and
evaluators understand how their projects engage with the broader
research community over time.

## What Does It Do?

The package provides unified access to:

- **NIH RePORTER** - Project metadata, funding details, and associated
  publications
- **iCite** - Citation metrics including Relative Citation Ratio (RCR)
  for PubMed publications
- **GitHub** - Repository metrics (stars, forks, commits, contributors,
  issues, PRs) for projects tagged with NIH Core Project Numbers
- **Google Analytics** - Web traffic and engagement data for project
  websites
- **Europe PMC** - Literature search across millions of publications

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("nih-cfde/programets")
```

**Requirements:** - R \>= 4.1.0 - For GitHub data: A Personal Access
Token is recommended for higher rate limits

## Quick Start

### 1. Query NIH RePORTER for Project Information

Retrieve comprehensive project metadata including publications, funding
details, and principal investigators:

``` r
library(programets)

# Get project info for one or more NIH Core Project Numbers
proj_info <- get_core_project_info(c("u24ca289073"))
proj_info |> colnames()
#>  [1] "core_project_num"         "found_publication"       
#>  [3] "appl_id"                  "subproject_id"           
#>  [5] "fiscal_year"              "project_num"             
#>  [7] "project_serial_num"       "organization"            
#>  [9] "award_type"               "activity_code"           
#> [11] "is_active"                "project_num_split"       
#> [13] "principal_investigators"  "contact_pi_name"         
#> [15] "program_officers"         "agency_ic_admin"         
#> [17] "agency_ic_fundings"       "cong_dist"               
#> [19] "spending_categories"      "project_start_date"      
#> [21] "project_end_date"         "organization_type"       
#> [23] "geo_lat_lon"              "opportunity_number"      
#> [25] "full_study_section"       "award_notice_date"       
#> [27] "is_new"                   "mechanism_code_dc"       
#> [29] "terms"                    "pref_terms"              
#> [31] "abstract_text"            "project_title"           
#> [33] "phr_text"                 "spending_categories_desc"
#> [35] "agency_code"              "covid_response"          
#> [37] "arra_funded"              "budget_start"            
#> [39] "budget_end"               "cfda_code"               
#> [41] "funding_mechanism"        "direct_cost_amt"         
#> [43] "indirect_cost_amt"        "project_detail_url"      
#> [45] "date_added"               "pmid"                    
#> [47] "pubmed_url"
```

Available fields include: project title, abstract, funding amounts,
dates, PIs, publications (PMIDs), and more.

### 2. Get GitHub Repository Metrics

If your project repositories are tagged with NIH Core Project Numbers as
topics, you can collect engagement metrics:

``` r
# Fetch GitHub metrics for repos tagged with your project number
df <- get_github_by_topic(c("u24ca289073"))
#> ! No GitHub token provided. Running without authentication
#> ℹ Use of a Personal Access Token (PAT)is recommended for increased rate limits. Create a token with: usethis::create_github_token()
#> This message is displayed once every 8 hours.
df |> colnames()
#>  [1] "name"          "owner"         "description"   "stars"        
#>  [5] "watchers"      "forks"         "open_issues"   "open_prs"     
#>  [9] "closed_issues" "closed_prs"    "commits"       "contributors" 
#> [13] "tags"          "language"      "license"       "created_at"   
#> [17] "pushed_at"     "updated_at"    "html_url"
```

Metrics include: stars, watchers, forks, open/closed issues, open/closed
PRs, commit count, contributor count, and more.

**Tip:** Tag your GitHub repositories with your NIH Core Project Number
(e.g., `u24ca289073`) to enable discovery.

### 3. Get Citation Metrics from iCite

Calculate impact metrics including the Relative Citation Ratio (RCR) for
your publications:

``` r
# Get citation metrics for PubMed IDs
pmids <- c(26001965, 25015380)
citation_data <- icite(pmids)

# View RCR and other metrics
dplyr::select(citation_data, pmid, title, year, 
              relative_citation_ratio, citation_count)
```

### 4. Search Europe PMC for Publications

Query millions of publications with flexible search syntax:

``` r
# Search for publications related to CRISPR
crispr_pubs <- epmc_search(query = "crispr", page_limit = 2)

# Search by author
author_pubs <- epmc_search(query = 'AUTH:"Smith J"', page_limit = 1)
```

### 5. Access Google Analytics Data

Retrieve web traffic data for project websites (requires
authentication):

``` r
# Authenticate with Google (first time only)
googleAnalyticsR::ga_auth()

# Get traffic data
traffic <- ga_dataframe(
  property_id = "123456789",
  start_date = "2024-01-01",
  end_date = "2024-12-31",
  metrics = c("activeUsers", "sessions"),
  dimensions = c("date", "country")
)
```

## Authentication

### GitHub

For increased API rate limits, set up a Personal Access Token:

``` r
# Create a token with: usethis::create_github_token()
# Then use it in your calls:
df <- get_github_by_topic(c("u24ca289073"), token = "your_token_here")
```

### Google Analytics

First-time setup requires authentication:

``` r
# Opens browser for Google account authorization
googleAnalyticsR::ga_auth()

# For non-interactive use, see DEVELOPER.md for service account setup
```

## Use Cases

- **Impact Reporting**: Generate comprehensive reports combining
  publication citations, web traffic, and GitHub engagement
- **Trend Analysis**: Track how metrics evolve over time in response to
  publications, presentations, or events
- **Portfolio Management**: Compare metrics across multiple projects or
  funding opportunities
- **Compliance**: Document project outputs and community engagement for
  progress reports

## Documentation

- **Function Reference**: See `?get_core_project_info`, `?icite`,
  `?get_github_by_topic`, etc.
- **Vignettes**: Browse vignettes for detailed workflows
- **Developer Notes**: See `DEVELOPER.md` for advanced setup (service
  accounts, encryption)

## Getting Help

- File issues at: <https://github.com/nih-cfde/programets/issues>
- Review examples in the vignettes
- Check function documentation with `?function_name`

## Authors

- Sean Davis (<seandavi@gmail.com>)
- David Mayer (<david.mayer@cuanschutz.edu>)

## License

MIT
