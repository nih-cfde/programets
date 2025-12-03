# Get Core Project Info

Given NIH Core Project Number(s), this function retrieves project
metadata including any assosciated publications from the NIH RePORTER
API.

## Usage

``` r
get_core_project_info(core_project_numbers)
```

## Arguments

- core_project_numbers:

  A character vector of core project numbers.

## Value

A tibble containing the following columns:

- core_project_num:

  The core project number.

- found_publication:

  A logical indicating whether any publications were found for this core
  project number.

- appl_id:

  The application ID associated with the publication.

- pmid:

  The PubMed ID associated with the publication.

- pubmed_url:

  The URL of the PubMed page for the publication.

- subproject_id:

  The subproject ID associated with the publication.

- fiscal_year:

  The fiscal year associated with the publication.

- project_num:

  The project number associated with the publication.

- project_serial_num:

  The project serial number associated with the publication.

- organization:

  The organization associated with the publication.

- award_type:

  The award type associated with the publication.

- activity_code:

  The activity code associated with the publication.

- is_active:

  A logical indicating whether the project is active.

- project_num_split:

  The project number split associated with the publication.

- principal_investigators:

  The principal investigators associated with the publication.

- contact_pi_name:

  The contact PI name associated with the publication.

- program_officers:

  The program officers associated with the publication.

- agency_ic_admin:

  The agency IC admin associated with the publication.

- agency_ic_fundings:

  The agency IC fundings associated with the publication.

- cong_dist:

  The congressional district associated with the publication.

- spending_categories:

  The spending categories associated with the publication.

- project_start_date:

  The project start date associated with the publication.

- project_end_date:

  The project end date associated with the publication.

- organization_type:

  The organization type associated with the publication.

- geo_lat_lon:

  The geographic latitude and longitude associated with the publication.

- opportunity_number:

  The opportunity number associated with the publication.

- full_study_section:

  The full study section associated with the publication.

- award_notice_date:

  The award notice date associated with the publication.

- is_new:

  A logical indicating whether the project is new.

- mechanism_code_dc:

  The mechanism code DC associated with the publication.

- terms:

  The terms associated with the publication.

- pref_terms:

  The preferred terms associated with the publication.

- abstract_text:

  The abstract text associated with the publication.

- project_title:

  The project title associated with the publication.

- phr_text:

  The PHR text associated with the publication.

- spending_categories_desc:

  The spending categories description associated with the publication.

- agency_code:

  The agency code associated with the publication.

- covid_response:

  The COVID response associated with the publication.

- arra_funded:

  The ARRA funded associated with the publication.

- budget_start:

  The budget start associated with the publication.

- budget_end:

  The budget end associated with the publication.

- cfda_code:

  The CFDA code associated with the publication.

- funding_mechanism:

  The funding mechanism associated with the publication.

- direct_cost_amt:

  The direct cost amount associated with the publication.

- indirect_cost_amt:

  The indirect cost amount associated with the publication.

- project_detail_url:

  The project detail URL associated with the publication.

- date_added:

  The date added associated with the publication.

## Examples

``` r
# Get publications for a set of core project numbers
proj_info <- get_core_project_info(c("OT2OD030545", "99999999"))
# View the results
proj_info
#> # A tibble: 16 × 47
#>    core_project_num found_publication appl_id  subproject_id fiscal_year
#>    <chr>            <lgl>             <chr>    <chr>               <int>
#>  1 OT2OD030545      TRUE              10907962 NA                   2023
#>  2 OT2OD030545      TRUE              10907962 NA                   2023
#>  3 OT2OD030545      TRUE              10907962 NA                   2023
#>  4 OT2OD030545      TRUE              10907962 NA                   2023
#>  5 OT2OD030545      TRUE              10907962 NA                   2023
#>  6 OT2OD030545      TRUE              10907962 NA                   2023
#>  7 OT2OD030545      TRUE              10907962 NA                   2023
#>  8 OT2OD030545      TRUE              10907962 NA                   2023
#>  9 OT2OD030545      TRUE              10907962 NA                   2023
#> 10 OT2OD030545      TRUE              10907962 NA                   2023
#> 11 OT2OD030545      NA                10683509 NA                   2022
#> 12 OT2OD030545      NA                10707603 NA                   2022
#> 13 OT2OD030545      NA                10468526 NA                   2021
#> 14 OT2OD030545      NA                10444351 NA                   2021
#> 15 OT2OD030545      NA                10217839 NA                   2020
#> 16 99999999         FALSE             NA       NA                     NA
#> # ℹ 42 more variables: project_num <chr>, project_serial_num <chr>,
#> #   organization <list>, award_type <chr>, activity_code <chr>,
#> #   is_active <lgl>, project_num_split <list>, principal_investigators <list>,
#> #   contact_pi_name <chr>, program_officers <list>, agency_ic_admin <list>,
#> #   agency_ic_fundings <list>, cong_dist <chr>, spending_categories <chr>,
#> #   project_start_date <chr>, project_end_date <chr>, organization_type <list>,
#> #   geo_lat_lon <list>, opportunity_number <chr>, full_study_section <list>, …
```
