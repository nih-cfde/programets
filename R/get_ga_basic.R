#' Get Basic Google Analytics Info
#'
#' This function takes a character vector of NIH Core Project Numbers and 
#' returns a data frame containing the any Google Analytics properties associated
#' with the Core Project Numbers.
#'
#' @param core_project_numbers A character vector of NIH Core Project Numbers
#' 
#' @importFrom googleAnalyticsR ga_account_list
#' @importFrom purrr map map_chr
#' @importFrom stringr str_remove
#' 
#' @return A data frame containing the associated Google Analytics data
#' @export
get_ga_basic <- function(core_project_numbers, service_account_json = 'cfde-access-keyfile.json') {
  ## This function requires authentication, check for existing creds
  if(file.exists(system.file("secret", service_account_json, package = "programets"))){
    json_file <- gargle::secret_decrypt_json(
      path = system.file(
        "secret",
        service_account_json,
        package = "programets"
      ),
      key = "CFDE_ENCRYPTION_KEY"
    )
    googleAnalyticsR::ga_auth(
      json_file = json_file
    )
  } else {
    ga_auth()
  }
  
  ## Get All Analytics Properties
  account_list <- ga_account_list("ga4") |> 
    mutate(
      property_meta = suppressMessages(map(propertyId, get_ga_meta_by_id)),
      core_project_num = map_chr(
        property_meta,
        ~{
          res <- .x |>
            filter(str_detect(apiName, regex(core_project_numbers, ignore_case = TRUE))) |>
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
    ## Filter to those with the requested Core Project Numbers
    filter(!is.na(core_project_num)) |> 
    select(-property_meta)
  if(nrow(account_list) == 0) {
    rlang::inform(rlang::format_error_bullets(c(i = "No Google Analytics properties found for the requested Core Project Numbers")))
  }
  return(account_list)
  }
