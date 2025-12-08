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
            languages(first: 20) {
              edges { size node { name } }
            }
          }
        }
      }
    }'

  qry <- ghql::Query$new()
  qry$query("repoQuery", query_template)

  fetch_topic <- function(topic) {
    res <- cli$exec(
      qry$queries$repoQuery,
      variables = list(queryString = paste0("topic:", topic),
                       limit = limit)
    )
    dat <- jsonlite::fromJSON(res, flatten = TRUE)
    repos <- dat$data$search$nodes
    if (length(repos) == 0) return(NULL)
    # browser()
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
                                 repos$coc,
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

  # Fetch across all topics and combine
  df <- purrr::map_dfr(topics, fetch_topic)

    if (nrow(df) == 0) {
    expected_cols <- c(
      "name", "owner", "description", "stars", "watchers", "forks", "open_issues", "open_prs",
      "closed_issues", "closed_prs", "commits", "mentionable_users", "contributors","has_readme", "code_of_conduct", 
      "tags", "language", "language_loc", "license", "created_at", "pushed_at", "updated_at", "html_url",
      "queried_topic"
    )
    df <- tibble::tibble(
        !!!setNames(rep(list(NA), length(expected_cols)), expected_cols)
      ) %>% 
       filter(!is.na(.data$name))
    } else {
      df <- df |> 
        mutate(contributors = map2_dbl(.data$owner, .data$name, ~ get_contributor_count(.x, .y, token = token)))
    }
  
  # Organize columns like before
  df <- df |>
    dplyr::relocate('open_prs', .after = 'open_issues') |>
    dplyr::relocate('closed_issues', .after = 'open_prs') |>
    dplyr::relocate('closed_prs', .after = 'closed_issues') |>
    dplyr::relocate('commits', .after = 'closed_prs') |>
    dplyr::relocate('mentionable_users', .after = 'commits') |> 
    dplyr::relocate('contributors', .after = 'mentionable_users')
  return(df)
}

  # Helper to count contributors
  get_contributor_count <- function(owner, repo, token = NULL) {
    base_url <- glue("https://api.github.com/repos/{owner}/{repo}/contributors")
    req <- request(base_url) |>
      req_url_query(per_page = 1, anon = "false") |>  # anon=TRUE counts contributors without accounts
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
      return(length(body))  # if only a few contributors
    }
  }

