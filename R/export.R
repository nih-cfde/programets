export_project <- function(core_project_numbers, export = c("csv", "json", "excel")) {
  
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
export_excel <- function(core_project_numbers, token = gitcreds::gitcreds_get()$password) {

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
  json_file <- gargle::secret_decrypt_json(
    path = system.file(
      "secret",
      "cfde-access-keyfile.json",
      package = "programets"
    ),
    key = "CFDE_ENCRYPTION_KEY"
  )
  googleAnalyticsR::ga_auth(
    json_file = json_file
  )
  account_list <- ga_account_list("ga4") |> 
    mutate(
      property_meta = map(propertyId, get_ga_meta_by_id),
      core_project_num = map_chr(
        property_meta,
        ~{
          res <- .x |>
            filter(str_detect(apiName, core_project_numbers)) |>
            tidyr::separate(apiName, into = c("api", "value"), sep = ":", remove = FALSE) |>
            pull(value)

          if (length(res) == 0) {
            NA_character_
          } else {
            res |>
              str_remove("^cfde_") |>
              unique() |>
              paste(collapse = ",")
          }
        }
      )
    ) |> 
    filter(!is.na(core_project_num)) |> 
    select(-property_meta)
  writeData(wb = wb, sheet = "ga_info", x = account_list, na.string = "")

  ga_info <- get_ga_meta_by_id(core_project_numbers)
  writeData(wb = wb, sheet = "ga_info", x = ga_info, na.string = "")

  ## Save Workbook
  saveWorkbook(wb, paste0("programets_", Sys.Date(), ".xlsx", sep = ""))
}