#' All CFDE Funding Opportunity Numbers
#' 
#' This function retrieves all CFDE funding
#' opportunity numbers from the CFDE funding
#' website, \url{https://commonfund.nih.gov/dataecosystem/FundingOpportunities}.
#' 
#' Note that this function is specific to the CFDE
#' program and is not a general-purpose web scraping
#' function. 
#' 
#' @importFrom rvest read_html html_nodes html_attr
#' 
#' 
#' @param url The URL of the CFDE API endpoint.
#' Default is set to the CFDE funding opportunities page.
#' @return a character vector of funding opportunity numbers.
#' 
#' @examples 
#' 
#' \dontrun{
#' browseURL("https://commonfund.nih.gov/dataecosystem/FundingOpportunities")
#' }
#' 
#' cfde_opportunity_numbers()
#' 
#' @export
cfde_opportunity_numbers <- function(
  url = "https://commonfund.nih.gov/dataecosystem/FundingOpportunities"
) {

  hrefs <- rvest::read_html(url) |>
    rvest::html_nodes("a") |>
    rvest::html_attr("href")
  hrefs_filtered <- grep('NOT|RFA|OTA', hrefs, value = TRUE)

  pattern <- "(RFA|OTA|NOT)-[A-Z]{2}-\\d{2}-\\d{3}"

  regmatches(hrefs_filtered, regexpr(pattern, hrefs_filtered, perl=TRUE))
}