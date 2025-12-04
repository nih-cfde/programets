#' Export to Tabular
#' 
#' @param core_project_numbers A character vector of NIH Core Project Numbers
#' @param token The token required for authentication with the GitHub API
#' @param service_account_json A character string containing the path to a JSON file containing a Google service account
#' @param dir A character string containing the path to directory where the Excel file will be written
#' @param csv A logical indicating whether to write a CSV file
#' 
#' @importFrom openxlsx createWorkbook addWorksheet writeData saveWorkbook
#' @importFrom readr write_csv
#' @importFrom rlang .data
#' @export
#' 
#' @examples
#' \dontrun{
#' test_projects <-c("OT2OD030545")
#' }
#' 
export_tabular <- function(core_project_numbers, token = gitcreds::gitcreds_get()$password, service_account_json = 'cfde-access-keyfile.json', dir, csv = FALSE) {

  ## Create Excel Workbook
  wb <- createWorkbook()

  ## Add NIH Project Info
  addWorksheet(wb, "project_info")
  proj_info <- get_core_project_info(core_project_numbers)
  writeData(wb = wb, sheet = "project_info", x = proj_info, na.string = "")
  if (csv) {
    write_csv(proj_info, file.path(dir, paste0("programets_proj_info_", Sys.Date(), ".csv", sep = "")))
  }
  
  ## Add Assosciated Publications
  addWorksheet(wb, "pub_info")
  pmids <- proj_info |> 
    filter(.data$found_publication) |> 
    pull('pmid')
  pub_info <- icite(pmids)
  writeData(wb = wb, sheet = "pub_info", x = pub_info, na.string = "")
  if (csv) {
    write_csv(pub_info, file.path(dir, paste0("programets_pub_info_", Sys.Date(), ".csv", sep = "")))
  }

  ## Add GitHub
  addWorksheet(wb, "github_info")
  github_info <- get_github_by_topic_graphql(core_project_numbers, token = token)
  writeData(wb = wb, sheet = "github_info", x = github_info, na.string = "")
  if (csv) {
    write_csv(github_info, file.path(dir, paste0("programets_github_info_", Sys.Date(), ".csv", sep = "")))
  }

  ## Add Google Analytics
  addWorksheet(wb, "ga_info")
  ga_info <- get_ga_basic(core_project_numbers = core_project_numbers, service_account_json = service_account_json)
  writeData(wb = wb, sheet = "ga_info", x = ga_info, na.string = "")
  if (csv) {
    write_csv(ga_info, file.path(dir, paste0("programets_ga_info_", Sys.Date(), ".csv", sep = "")))
  }

  ## Save Workbook
  saveWorkbook(wb, file.path(dir, paste0("programets_", Sys.Date(), ".xlsx", sep = "")))
}