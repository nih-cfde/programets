
<!-- README.md is generated from README.Rmd. Please edit that file -->

# programets

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

The goal of programets is to gather metrics from iCite, Google
Analytics, GitHub, and other sources to help assess the impact of your
NIH Project on the broader research community.

## Installation

You can install the development version of programets from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("nih-cfde/programets")
```

## Example Usage

Query the NIH RePORTER:

``` r
library(programets)

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

Tag your GitHub repositories with NIH Core Project Numbers to download
common metrics:

``` r
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
