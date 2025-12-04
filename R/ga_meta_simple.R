#' Google analytics metadata dataframe
#'
#' This function retrieves Google Analytics metadata
#' and returns it as a dataframe. The metadata includes
#' information about metrics, dimensions, and other
#' attributes available in Google Analytics.
#'
#' This function is a wrapper around the
#' `googleAnalyticsR::ga_meta()` function. It retrieves
#' metadata for the Google Analytics API version 4.
#'
#' @note This function requires first authenticating to 
#' Google Analytics using the `ga_auth()` function.
#'
#' @family Google Analytics
#'
#' @examples
#' \dontrun{
#' res = ga_meta_simple()
#' head(res)
#' dplyr::glimpse(res)
#' }
#'
#' @return A tibble containing Google Analytics metadata.
#'
#' @export
ga_meta_simple <- function() {
  tibble::as_tibble(googleAnalyticsR::ga_meta(version = "data"))
}

#' Google Analytics metadata dataframe by property ID
#'
#' This function retrieves Google Analytics metadata by property ID
#' and returns it as a dataframe. The metadata includes
#' information about metrics, dimensions, and other
#' attributes available in Google Analytics.
#'
#' This function is a wrapper around the
#' `googleAnalyticsR::ga_meta()` function. It retrieves
#' metadata for the Google Analytics API version 4.
#'
#' @param property_id The property ID for which to retrieve
#' metadata.
#'
#' @note This function requires first authenticating to
#' Google Analytics using the `ga_auth()` function.
#'
#' @family Google Analytics
#'
#' @examples
#' \dontrun{
#' res = get_ga_meta_by_id("123456789")
#' head(res)
#' dplyr::glimpse(res)
#' }
#'
#' @return A tibble containing Google Analytics metadata.
#'
#' @export
get_ga_meta_by_id <- function(property_id) {
  tibble::as_tibble(googleAnalyticsR::ga_meta(version = "data", propertyId = property_id))
}