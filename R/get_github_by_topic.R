# REST API Helper Functions
#' Get the number of contributors for a GitHub repository
#'
#' @param owner The owner of the GitHub repository
#' @param repo The name of the GitHub repository
#' @param token A GitHub personal access token (optional)
#' 
#' @importFrom httr2 req_throttle
#'
#' @return The number of contributors to the repository
get_contributor_count <- function(owner, repo, token = NULL) {
    base_url <- glue("https://api.github.com/repos/{owner}/{repo}/contributors")
    req <- request(base_url) |>
      req_url_query(per_page = 1, anon = "false") |>  # anon=TRUE counts contributors without accounts
      req_headers("User-Agent" = "httr2")
    if (!is.null(token)) {
      req <- req |> 
        req_auth_bearer_token(token) |> 
        req_throttle(capacity = 5000, fill_time_s = 3600)
    } else {
      req <- req |> 
      req_throttle(capacity = 60, fill_time_s = 3600)
    }

    resp <- tryCatch(req_perform(req), error = function(e) NULL)
    if (is.null(resp) || resp_status(resp) != 200) return(NA_real_)

    link <- resp_headers(resp)[["link"]]
    if (!is.null(link) && grepl("rel=\"last\"", link)) {
      matches <- regmatches(link, regexpr("page=\\d+>; rel=\\\"last\\\"", link))
      count <- as.numeric(sub("page=", "", sub(">; rel=\"last\"", "", matches)))
      return(count)
    } else {
      body <- resp_body_json(resp)
      return(length(body))  # if only a few contributors
    }
  }

# REST Functions
#' Get GitHub Repositories by Topic
#'
#' @param topics A vector of GitHub topics to search for.
#' @param token A GitHub personal access token. If not provided, the function
#'   will run without authentication.
#' @param limit The maximum number of results to return. Defaults to 30.
#' 
#' @importFrom dplyr relocate
#' @importFrom httr2 request req_url_query req_perform req_perform_parallel resp_status resp_body_json req_auth_bearer_token
#' @importFrom glue glue glue_collapse
#' @importFrom tibble tibble
#' @importFrom purrr discard map_chr map_dbl map2_dbl pmap
#' @importFrom rlang %||% .data
#'
#' @return A data frame containing the results of the search query.
#'
#' @examples
#' topics <- c("u24ca289073")
#' df <- get_github_by_topic(topics, limit = 5)
#' head(df)
#' dplyr::glimpse(df)
#' 
#' @export

get_github_by_topic <- function(topics, token = NULL, limit = 30) {
  if (length(topics) == 0) {
    stop("At least one topic must be provided.")
  }

  if(is.null(token)) {
    rlang::inform(
      rlang::format_error_bullets(c(
        "!" = "No GitHub token provided. Running without authentication",
        "i" = "Use of a Personal Access Token (PAT)is recommended for increased rate limits. Create a token with: usethis::create_github_token()")
      ), 
      .frequency = "regularly", 
      .frequency_id = "get_github_by_topic"
    )
  }

  q_topic <- paste(sprintf("topic:%s", topics), collapse = " ")

  # Start with search endpoint
  req_topic <- request("https://api.github.com/search/repositories") |>
    req_url_query(q = q_topic, per_page = limit)

  if (!is.null(token)) {
    req_topic <- req_topic |> 
      req_auth_bearer_token(token) |> 
      req_throttle(capacity = 30, fill_time_s = 60)
  } else {
    req_topic <- req_topic |>
      req_throttle(capacity = 10, fill_time_s = 60)
  }

  resp_topic <- req_perform(req_topic)

  if (resp_status(resp_topic) != 200) {
    stop("GitHub API request failed: ", resp_status(resp_topic))
  }

  content <- resp_body_json(resp_topic, simplifyVector = FALSE)
  results <- content$items
  if (length(results) == 0) return(data.frame())
  
  # True watchers (subscribers) count
  get_watchers_count <- function(owner, repo, token = NULL) {
    url <- glue::glue("https://api.github.com/repos/{owner}/{repo}")
    req <- httr2::request(url) |>
      httr2::req_headers("User-Agent" = "httr2",
                         "X-GitHub-Api-Version" = "2022-11-28")
    if (!is.null(token)) req <- req |> httr2::req_auth_bearer_token(token)

    resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
    if (is.null(resp) || httr2::resp_status(resp) != 200) return(NA_real_)

    body <- httr2::resp_body_json(resp)
    as.numeric(body$subscribers_count %||% NA_real_)
  }

  df <- tibble(
    name = map_chr(results, ~ .x$name),
    owner = map_chr(results, ~ .x$owner$login),
    description = map_chr(results, ~ .x$description %||% NA_character_),
    stars = map_dbl(results, ~ .x$stargazers_count),
    watchers = purrr::map_dbl(results, ~ get_watchers_count(.x$owner$login, .x$name, token = token)),
    forks = map_dbl(results, ~ .x$forks_count),
    open_issues_raw = map_dbl(results, ~ .x$open_issues_count),
    tags = map_chr(results, ~ glue_collapse(discard(unlist(.x$topics), ~ .x == topics), sep = ", ")), 
    language = map_chr(results, ~ .x$language %||% NA_character_),
    license = map_chr(results, ~ .x$license$name %||% NA_character_),
    created_at = map_chr(results, ~ .x$created_at),
    pushed_at = map_chr(results, ~ .x$pushed_at),
    updated_at = map_chr(results, ~ .x$updated_at),
    html_url = map_chr(results, ~ .x$html_url)
  )

  # Helper function to get count using Link header
  get_count_from_link <- function(owner, repo, endpoint, state = "open", token = NULL) {
    base_url <- glue("https://api.github.com/repos/{owner}/{repo}/{endpoint}")
    req <- request(base_url) |>
      req_url_query(state = state, per_page = 1) |>
      req_headers("User-Agent" = "httr2")
    if (!is.null(token)) {
      req <- req |> req_auth_bearer_token(token)
    }

    resp <- tryCatch(req_perform(req), error = function(e) NULL)
    if (is.null(resp) || resp_status(resp) != 200) return(NA_real_)

    link <- resp_headers(resp)[["link"]]
    if (!is.null(link) && grepl("rel=\"last\"", link)) {
      matches <- regmatches(link, regexpr("page=\\d+>; rel=\\\"last\\\"", link))
      count <- as.numeric(sub("page=", "", sub(">; rel=\"last\"", "", matches)))
      return(count)
    } else {
      body <- resp_body_json(resp)
      return(length(body))
    }
  }

  # Helper function to get closed issue count via Search API (excluding PRs)
  get_closed_issue_count <- function(owner, repo, token = NULL) {
    q <- glue("repo:{owner}/{repo} type:issue state:closed")
    req <- request("https://api.github.com/search/issues") |>
      req_url_query(q = q, per_page = 1) |>
      req_headers("User-Agent" = "httr2")
    if (!is.null(token)) {
      req <- req |> req_auth_bearer_token(token)
    }
    resp <- tryCatch(req_perform(req), error = function(e) NULL)
    if (!is.null(resp) && resp_status(resp) == 200) {
      return(resp_body_json(resp)$total_count)
    } else {
      return(NA_real_)
    }
  }

  open_pr_counts <- map2_dbl(df$owner, df$name, ~ get_count_from_link(.x, .y, endpoint = "pulls", state = "open", token = token))
  closed_pr_counts <- map2_dbl(df$owner, df$name, ~ get_count_from_link(.x, .y, endpoint = "pulls", state = "closed", token = token))
  closed_issue_counts <- map2_dbl(df$owner, df$name, ~ get_closed_issue_count(.x, .y, token = token))

  df$open_prs <- open_pr_counts
  df$closed_prs <- closed_pr_counts
  df$closed_issues <- closed_issue_counts
  df$open_issues <- df$open_issues_raw - df$open_prs

  # Other Repo Stats
  # Helper to count commits
  get_commit_count <- function(owner, repo, token = NULL, branch = "HEAD") {
    base_url <- glue("https://api.github.com/repos/{owner}/{repo}/commits")
    req <- request(base_url) |>
      req_url_query(sha = branch, per_page = 1) |>
      req_headers("User-Agent" = "httr2")
    if (!is.null(token)) {
      req <- req |> req_auth_bearer_token(token)
    }

    resp <- tryCatch(req_perform(req), error = function(e) NULL)
    if (is.null(resp) || resp_status(resp) != 200) return(NA_real_)

    link <- resp_headers(resp)[["link"]]
    if (!is.null(link) && grepl("rel=\"last\"", link)) {
      matches <- regmatches(link, regexpr("page=\\d+>; rel=\\\"last\\\"", link))
      count <- as.numeric(sub("page=", "", sub(">; rel=\"last\"", "", matches)))
      return(count)
    } else {
      body <- resp_body_json(resp)
      return(length(body))  # fewer than one page of commits
    }
  }

  commit_counts <- map2_dbl(df$owner, df$name, ~ get_commit_count(.x, .y, token = token))
  df$commits <- commit_counts

  contributor_counts <- map2_dbl(df$owner, df$name, ~ get_contributor_count(.x, .y, token = token))
  df$contributors <- contributor_counts



  df <- df |> 
    relocate("open_issues", .after = "forks") |>
    relocate("open_prs", .after = "open_issues") |>
    relocate("closed_issues", .after = "open_prs") |>
    relocate("closed_prs", .after = "closed_issues") |>
    relocate("commits", .after = "closed_prs") |>
    relocate("contributors", .after = "commits") |>
    select(-"open_issues_raw")

  return(df)
}
