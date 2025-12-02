#' Get GitHub Repositories by Topic (GraphQL API)
#'
#' @param topics A vector of GitHub topics to search for.
#' @param token A GitHub personal access token. Required for GraphQL API.
#' @param limit The maximum number of repositories to return per topic (max 1000 by GitHub).
#' 
#' @importFrom ghql GraphqlClient
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @importFrom purrr map_dfr
#' @importFrom dplyr relocate
#' @importFrom stats setNames
#'
#' @return A data frame with repository metadata.
#'
#' @examples
#' \dontrun{
#' df <- get_github_by_topic_graphql(c("u24ca289073"), token = "ghp_yourPAT")
#' dplyr::glimpse(df)
#' }
#'
#' @export
get_github_by_topic_graphql <- function(topics, token, limit = 30) {
  if (missing(token) || is.null(token)) {
    stop("A GitHub personal access token is required for GraphQL API.")
  }

  if (length(topics) == 0) {
    stop("At least one topic must be provided.")
  }

  topics <- tolower(topics)
  
  # Set up client
  cli <- ghql::GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("bearer ", token))
  )
  
  # GraphQL query template
  # Fetches up to `limit` repos per topic, along with key metadata
  query_template <- '
    query($queryString: String!, $limit: Int!) {
      search(query: $queryString, type: REPOSITORY, first: $limit) {
        repositoryCount
        nodes {
          ... on Repository {
            name
            description
            url
            createdAt
            pushedAt
            updatedAt
            primaryLanguage { name }
            licenseInfo { name }
            owner { login }
            stargazerCount
            forkCount
            watchers { totalCount }
            issues(states: OPEN) { totalCount }
            closedIssues: issues(states: CLOSED) { totalCount }
            openPRs: pullRequests(states: OPEN) { totalCount }
            closedPRs: pullRequests(states: CLOSED) { totalCount }
            defaultBranchRef {
              target {
                ... on Commit {
                  history {
                    totalCount
                  }
                }
              }
            }
            mentionableUsers {
              totalCount
            }
            repositoryTopics(first: 20) {
              nodes {
                topic { name }
              }
            }
          }
        }
      }
    }'
  
  # Compile query once
  qry <- ghql::Query$new()
  qry$query("repoQuery", query_template)
  
  # Helper: fetch repos for one topic
  fetch_topic <- function(topic) {
    res <- cli$exec(qry$queries$repoQuery, 
                    variables = list(queryString = paste0("topic:", topic),
                                     limit = limit))
    dat <- jsonlite::fromJSON(res, flatten = TRUE)
    repos <- dat$data$search$nodes
    if (length(repos) == 0) return(NULL)
    # browser()
    tibble::tibble(
      name         = repos$name,
      owner        = repos$owner.login,
      description  = repos$description,
      stars        = repos$stargazerCount,
      watchers     = repos$watchers.totalCount,
      forks        = repos$forkCount,
      open_issues  = repos$issues.totalCount,
      closed_issues = repos$closedIssues.totalCount,
      open_prs     = repos$openPRs.totalCount,
      closed_prs   = repos$closedPRs.totalCount,
      commits      = purrr::map_dbl(
                      repos$defaultBranchRef.target.history.totalCount,
                      ~ if (is.null(.x)) NA_real_ else .x
                    ),
      contributors = repos$mentionableUsers.totalCount %||% 0,
      tags         = purrr::map_chr(
                      repos$repositoryTopics.nodes,
                      ~ if (length(.x$topic.name) == 0) NA_character_
                        else paste(.x$topic.name, collapse = ", ")
                    ),
      language     = repos$primaryLanguage.name,
      license      = repos$licenseInfo.name,
      created_at   = repos$createdAt,
      pushed_at    = repos$pushedAt,
      updated_at   = repos$updatedAt,
      html_url     = repos$url,
      queried_topic = topic
    )

  }
  
  # Fetch across all topics and combine
  df <- purrr::map_dfr(topics, fetch_topic)

  if (nrow(df) == 0) {
    expected_cols <- c(
      "name", "owner", "description", "stars", "watchers", "forks", "open_issues", "open_prs",
      "closed_issues", "closed_prs", "commits", "contributors", "tags", "language", "license",
      "created_at", "pushed_at", "updated_at", "html_url", "queried_topic"
    )
    df <- tibble::tibble(
        !!!setNames(rep(list(NA), length(expected_cols)), expected_cols)
      ) %>% 
       filter(!is.na(.data$name))
  }
  # Organize columns like before
  df <- df |>
    dplyr::relocate('open_prs', .after = 'open_issues') |>
    dplyr::relocate('closed_issues', .after = 'open_prs') |>
    dplyr::relocate('closed_prs', .after = 'closed_issues') |>
    dplyr::relocate('commits', .after = 'closed_prs') |>
    dplyr::relocate('contributors', .after = 'commits')
  
  return(df)
}
