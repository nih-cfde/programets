#' Get GitHub Repositories by Topic (GraphQL API)
#'
#' @param topics A vector of GitHub topics to search for.
#' @param token A GitHub personal access token. Required for GraphQL API.
#' @param limit The maximum number of repositories to return per topic (max 1000 by GitHub).
#' 
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
#' @importFrom dplyr bind_rows
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
  if (limit > 30) {
    stop("limit must be 30 or less") ## results are good. more than this and GitHub will nope out
  }

  topics <- tolower(topics)

  # Setup client
  cli <- ghql::GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("bearer ", token))
  )

  # GraphQL query template with pagination
  query_template <- '
    query($queryString: String!, $limit: Int!, $cursor: String) {
      search(query: $queryString, type: REPOSITORY, first: $limit, after: $cursor) {
        repositoryCount
        pageInfo {
          hasNextPage
          endCursor
        }
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
                  history { totalCount }
                }
              }
            }
            mentionableUsers { totalCount }
            repositoryTopics(first: 20) {
              nodes { topic { name } }
            }
            readme: object(expression: "HEAD:README.md") { id }
            coc: object(expression: "HEAD:CODE_OF_CONDUCT.md") { id }
            contributing: object(expression: "HEAD:CONTRIBUTING.md") { id }
            languages(first: 20) {
              edges { size node { name } }
            }
          }
        }
      }
    }'

  qry <- ghql::Query$new()
  qry$query("repoQuery", query_template)

  # Pagination-enabled requester
  fetch_topic <- function(topic) {
    cursor <- NULL
    all_repos <- list()

    repeat {
      res <- cli$exec(
        qry$queries$repoQuery,
        variables = list(
          queryString = paste0("topic:", topic),
          limit = limit,
          cursor = cursor
        )
      )

      dat <- jsonlite::fromJSON(res, flatten = TRUE)
      search <- dat$data$search
      repos <- search$nodes

      if (length(repos) > 0) {
        all_repos <- append(all_repos, list(repos))
      }

      if (!isTRUE(search$pageInfo$hasNextPage)) break
      cursor <- search$pageInfo$endCursor
    }

    if (length(all_repos) == 0) return(NULL)

    repos <- dplyr::bind_rows(all_repos)

    tibble::tibble(
      name                 = repos$name,
      owner                = repos$owner.login,
      description          = repos$description,
      stars                = repos$stargazerCount,
      watchers             = repos$watchers.totalCount,
      forks                = repos$forkCount,
      open_issues          = repos$issues.totalCount,
      closed_issues        = repos$closedIssues.totalCount,
      open_prs             = repos$openPRs.totalCount,
      closed_prs           = repos$closedPRs.totalCount,
      commits              = purrr::map_dbl(
                               repos$defaultBranchRef.target.history.totalCount,
                               ~ if (is.null(.x)) NA_real_ else .x
                             ),
      mentionable_users    = repos$mentionableUsers.totalCount %||% 0,
      has_readme           = if( 'readme.id' %in% names(repos)) {
                               purrr::map_lgl(
                                 repos$readme.id,
                                 ~ if (is.na(.x) || is.null(.x) || length(.x) == 0) FALSE else TRUE
                              ) } else {
                                FALSE
                              },
      code_of_conduct      = if( 'coc.id' %in% names(repos)) {
                               purrr::map_lgl(
                                 repos$coc.id,
                                 ~ if (is.na(.x) || is.null(.x) || length(.x) == 0) FALSE else TRUE
                               ) } else {
                                FALSE
                               },
      contributing         = if( 'contributing.id' %in% names(repos)) {
                               purrr::map_lgl(
                                 repos$contributing.id,
                                 ~ if (is.na(.x) || is.null(.x) || length(.x) == 0) FALSE else TRUE
                               ) } else {
                                FALSE
                               },
      tags                 = purrr::map_chr(
                               repos$repositoryTopics.nodes,
                               ~ if (is.null(.x) || length(.x$topic.name) == 0) NA_character_
                                 else paste(.x$topic.name, collapse = ", ")
                             ),
      language             = repos$primaryLanguage.name,
      language_loc         = purrr::map(
                               repos$languages.edges,
                               ~ if (is.null(.x)) {
                                   tibble::tibble(language = NA_character_, bytes = NA_real_, loc = NA_real_)
                                 } else {
                                   tibble::tibble(
                                     language = .x$node.name,
                                     bytes = .x$size,
                                     loc = round(.x$size / 50)
                                   )
                                 }
                             ),
      license              = repos$licenseInfo.name %||% NA_character_,
      created_at           = repos$createdAt,
      pushed_at            = repos$pushedAt,
      updated_at           = repos$updatedAt,
      html_url             = repos$url,
      queried_topic        = topic
    )
  }

  results_list <- vector("list", length(topics)) ## initialize results
  cli::cli_progress_bar("Requesting repositories by topic", total = length(topics))
  
  for (i in seq_along(topics)) {
    results_list[[i]] <- fetch_topic(topics[i])
    cli::cli_progress_update()
  }
  
  cli::cli_progress_done()
  results <- dplyr::bind_rows(results_list)

  # If nothing is found
  if (nrow(results) == 0) {
    expected_cols <- c(
      "name", "owner", "description", "stars", "watchers", "forks", "open_issues", "open_prs",
      "closed_issues", "closed_prs", "commits", "mentionable_users", "contributors",
      "has_readme", "code_of_conduct", "tags", "language", "language_loc",
      "license", "created_at", "pushed_at", "updated_at", "html_url", "queried_topic"
    )

    return(
      tibble::tibble(
        !!!setNames(rep(list(NA), length(expected_cols)), expected_cols)
      ) |> filter(!is.na(.data$name))
    )
  }

  # Contributor count
  results <- results |>
    dplyr::mutate(contributors = map2_dbl(.data$owner, .data$name, ~
      get_contributor_count(.x, .y, token = token)
    ))

  # Organize columns like before
  results |>
    dplyr::relocate('open_prs', .after = 'open_issues') |>
    dplyr::relocate('closed_issues', .after = 'open_prs') |>
    dplyr::relocate('closed_prs', .after = 'closed_issues') |>
    dplyr::relocate('commits', .after = 'closed_prs') |>
    dplyr::relocate('mentionable_users', .after = 'commits') |>
    dplyr::relocate('contributors', .after = 'mentionable_users')
}
