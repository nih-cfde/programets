export_project <- function(
  core_project_numbers, export = c("csv", "json", "excel"), 
  token = gitcreds::gitcreds_get()$password, 
  service_account_json = 'cfde-access-keyfile.json', file) {
  
  export <- match.arg(export)
  
  if(export == "csv") {
    export_csv(core_project_numbers)
  }
  
  if(export == "json") {
    export_json(core_project_numbers)
  }
  
  if(export == "excel") {
    export_excel(core_project_numbers)
  }

}

export_csv <- function(core_project_numbers) {

}

export_js <- function(core_project_numbers) {

}

#' Export to Excel
#' 
#' @importFrom openxlsx createWorkbook addWorksheet writeData saveWorkbook
#' @export
#' 
#' @examples
#' \dontrun{
#' test_projects <-c("OT2OD030545")
#' }
#' 
export_excel <- function(core_project_numbers, token = gitcreds::gitcreds_get()$password, service_account_json = 'cfde-access-keyfile.json', file) {

  ## Create Excel Workbook
  wb <- createWorkbook()

  ## Add NIH Project Info
  addWorksheet(wb, "project_info")
  proj_info <- get_core_project_info(core_project_numbers)
  writeData(wb = wb, sheet = "project_info", x = proj_info, na.string = "")
  
  ## Add Assosciated Publications
  addWorksheet(wb, "pub_info")
  pmids <- proj_info |> 
    filter(found_publication) |> 
    pull(pmid)
  pub_info <- icite(pmids)
  writeData(wb = wb, sheet = "pub_info", x = pub_info, na.string = "")

  ## Add GitHub
  addWorksheet(wb, "github_info")
  github_info <- get_github_by_topic_graphql(core_project_numbers, token = token)
  writeData(wb = wb, sheet = "github_info", x = github_info, na.string = "")

  ## Add Google Analytics
  addWorksheet(wb, "ga_info")
  ga_info <- get_ga_basic(core_project_numbers = core_project_numbers, service_account_json = service_account_json)
  writeData(wb = wb, sheet = "ga_info", x = ga_info, na.string = "")

  ## Save Workbook
  saveWorkbook(wb, paste0("programets_", Sys.Date(), ".xlsx", sep = ""))
}