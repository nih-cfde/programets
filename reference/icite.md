# Retrieve icite data including Relative Citation Ratio (RCR) for PubMed IDs.

Retrieve icite data including Relative Citation Ratio (RCR) for PubMed
IDs.

## Usage

``` r
icite(pmids)
```

## Arguments

- pmids:

  vector of PubMed IDs to retrieve (max of 1000 at a time)

## Value

a tibble including the following variables:

- `pmid`:

  PubMed ID

- `authors`:

  publication authors

- `citation_count`:

  total citations

- `citations_per_year`:

  mean citations per year

- `expected_citations_per_year`:

  estimated

- `field_citation_rate`:

  rate relative to field

- `is_research_article`:

  boolean

- `journal`:

  journal name abbr.

- `nih_percentile`:

  percentile

- `relative_citation_ratio`:

  RCR

- `title`:

  article title

- `year`:

  publication year

See URL for full details.

## See also

<https://icite.od.nih.gov/api>

## Author

Sean Davis <seandavi@gmail.com>

## Examples

``` r
pmids <- c(26001965, 25015380)
icite_records <- icite(pmids)
dplyr::glimpse(icite_records)
#> Rows: 2
#> Columns: 27
#> $ `_id`                       <chr> "25015380", "26001965"
#> $ authors                     <list> [<data.frame[5 x 3]>], [<data.frame[3 x 3]…
#> $ doi                         <chr> "10.1101/gr.174052.114", "10.1093/nar/gkv…
#> $ pmid                        <int> 25015380, 26001965
#> $ title                       <chr> "High resolution mapping of modified DNA n…
#> $ animal                      <dbl> 0.25, 0.25
#> $ apt                         <dbl> 0.25, 0.05
#> $ human                       <dbl> 0, 0
#> $ citedByPmidsByYear          <list> [<data.frame[76 x 76]>], [<data.frame[40 x…
#> $ citedByClinicalArticle      <lgl> FALSE, FALSE
#> $ year                        <int> 2014, 2015
#> $ journal                     <chr> "Genome Res", "Nucleic Acids Res"
#> $ is_research_article         <lgl> TRUE, TRUE
#> $ citation_count              <int> 76, 40
#> $ field_citation_rate         <dbl> 8.437074, 10.030701
#> $ expected_citations_per_year <dbl> 3.439081, 4.103674
#> $ citations_per_year          <dbl> 6.909091, 4.000000
#> $ relative_citation_ratio     <dbl> 2.0089931, 0.9747362
#> $ nih_percentile              <dbl> 74.6, 49.3
#> $ molecular_cellular          <dbl> 0.75, 0.75
#> $ x_coord                     <dbl> -0.4330127, -0.4330127
#> $ y_coord                     <dbl> -0.5, -0.5
#> $ is_clinical                 <lgl> FALSE, FALSE
#> $ cited_by_clin               <lgl> NA, NA
#> $ cited_by                    <list> <29785056, 26519467, 30919497, 26411877, 3…
#> $ references                  <list> <8223452, 19448611, 21062813, 8092694, 115…
#> $ provisional                 <lgl> FALSE, FALSE

```
