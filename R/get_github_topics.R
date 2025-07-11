#' Get GitHub Repositories by Topic
#'
#' @param topics A vector of GitHub topics to search for.
#' @param token A GitHub personal access token. If not provided, the function
#'   will run without authentication.
#' @param limit The maximum number of results to return. Defaults to 30.
#' 
#' @importFrom httr2 request req_url_query req_perform resp_status resp_body_json req_auth_bearer_token
#' @importFrom glue glue_collapse
#' @importFrom tibble tibble
#' @importFrom purrr discard map_chr map_dbl
#' @importFrom rlang %||%
#'
#' @return A data frame containing the results of the search query.
#'
#' @examples
#' topics <- c("u24ca289073")
#' df = get_github_by_topic(topics, limit = 50)
#' head(df)
#' dplyr::glimpse(df)
#' 
#' @export

get_github_by_topic <- function(topics, token = NULL, limit = 30) {
  if (length(topics) == 0) {
    stop("At least one topic must be provided.")
  }

  # Construct GitHub search query
  q_topic <- paste(sprintf("topic:%s", topics), collapse = " ")

  # Build Topic Search Request
  req_topic <- request("https://api.github.com/search/repositories") |>
    req_url_query(q = q_topic, per_page = limit)

  if (!is.null(token)) {
    req_topic <- req_topic |> 
      req_auth_bearer_token(token)
  }

  resp_topic <- req_perform(req_topic)

  # Check Response
  if (resp_status(resp_topic) != 200) {
    stop("GitHub API request failed: ", resp_status(resp_topic))
  }

  # Parse JSON response
  content <- resp_body_json(resp_topic, simplifyVector = FALSE)

  # Extract relevant fields
  results <- content$items

  if (length(results) == 0) return(data.frame())

  df <- tibble(
    name = map_chr(results, ~ .x$name),
    owner = map_chr(results, ~ .x$owner$login),
    description = map_chr(results, ~ .x$description %||% NA_character_),
    stars = map_dbl(results, ~ .x$stargazers_count),
    watchers = map_dbl(results, ~ .x$watchers_count),
    forks = map_dbl(results, ~ .x$forks_count),
    open_issues = map_dbl(results, ~ .x$open_issues_count),
    tags = map_chr(results, ~ glue_collapse(discard(unlist(.x$topics), ~ .x == topics), sep = ", ")), 
    language = map_chr(results, ~ .x$language %||% NA_character_),
    license = map_chr(results, ~ .x$license$name %||% NA_character_),
    created_at = map_chr(results, ~ .x$created_at),
    pushed_at = map_chr(results, ~ .x$pushed_at),
    updated_at = map_chr(results, ~ .x$updated_at),
    html_url = map_chr(results, ~ .x$html_url)
  )

  return(df)
}

