#' Get summary metrics from Google Analytics
#'
#' This function retrieves summary metrics from Google Analytics,
#' including total users, new users, engaged sessions, engagement rate,
#' event count, and screen page views.
#'
#' @param propertyId The Google Analytics property ID
#' @param start_date The start date for the data retrieval (e.g., "30daysAgo")
#' @param end_date The end date for the data retrieval (e.g., "yesterday")
#'
#' @importFrom googleAnalyticsR ga_data
#' @importFrom dplyr mutate
#' 
#' @return A tibble containing the summary metrics
#' @export
get_ga_summary <- function(propertyId, start_date = "30daysAgo", end_date = "yesterday") {
  ga_data(
    propertyId,
    metrics = c(
      "totalUsers",
      "newUsers",
      "engagedSessions",
      "engagementRate",
      "eventCount",
      "screenPageViews"
    ),
    dimensions = "date",
    date_range = c(start_date, end_date)
  ) |> 
    mutate(propertyId = propertyId)
}
