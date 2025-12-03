# Search Europe PMC for publications

This function queries the Europe PMC REST API using a provided search
string. It handles pagination using a cursor and returns a tibble of
search results.

## Usage

``` r
epmc_search(query, page_limit = 10, delay = 1)
```

## Arguments

- query:

  A character string representing the search query for Europe PMC. See
  <https://europepmc.org/Help> for query syntax.

- page_limit:

  An integer specifying the maximum number of pages to retrieve.
  Defaults to 10. Set to `Inf` to retrieve all pages (use with caution).

- delay:

  An integer delay for API calls. Defaults to 1.

## Value

A tibble where each row represents a publication. Columns include:

- `id`:

  Publication ID

- `source`:

  Source of the publication (e.g., "MED", "PMC")

- `pmid`:

  PubMed ID

- `pmcid`:

  PubMed Central ID

- `doi`:

  Digital Object Identifier

- `title`:

  Title of the publication

- `authorString`:

  String of authors

- `journalTitle`:

  Title of the journal

- `issue`:

  Journal issue

- `journalVolume`:

  Journal volume

- `pubYear`:

  Year of publication

- `journalIssn`:

  Journal ISSN

- `pageInfo`:

  Page information

- `pubType`:

  Type of publication (e.g., "journal article", "review")

- `isOpenAccess`:

  Whether the publication is open access ("OA" or "N/A")

- `inEPMC`:

  Whether the publication is in EPMC ("Y" or "N/A")

- `inPMC`:

  Whether the publication is in PMC ("Y" or "N/A")

- `hasPDF`:

  Whether a PDF is available ("Y" or "N/A")

- `hasBook`:

  Whether it is a book ("Y" or "N/A")

- `citedByCount`:

  Number of citations

- `hasReferences`:

  Whether references are available ("Y" or "N/A")

- `hasTextMinedTerms`:

  Whether text-mined terms are available ("Y" or "N/A")

- `hasDbCrossReferences`:

  Whether database cross-references are available ("Y" or "N/A")

- `hasLabsLinks`:

  Whether Labs links are available ("Y" or "N/A")

- `hasTMAccessionNumbers`:

  Whether TM accession numbers are available ("Y" or "N/A")

- `firstPublicationDate`:

  Date of first publication

## Examples

``` r
if (FALSE) { # \dontrun{
  # Search for publications related to "crispr"
  crispr_results <- epmc_search(query = "crispr")
  dplyr::glimpse(crispr_results)

  # Search for publications by a specific author
  author_results <- epmc_search(query = "AUTH:\"Smith J\"")
  dplyr::glimpse(author_results)
} # }
```
