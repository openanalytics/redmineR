## 

redmine_list_projects <- function(include = NULL, ...) {
  
  # TODO: describe these in the doc
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (include == "all")
    include <- includeChoices
  if (!is.null(include))
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  
  
  extraArgs <- removeNULL(list(...))
  if (length(extraArgs) > 0) {
    query <- paste0(names(extraArgs), "=", extraArgs, collapse = "&")
  } else
    query <- NULL
  
  if (length(include) > 0)
    query <- paste0("include=", paste0(include, collapse = ","), "&", query)
  
  res <- redmine_get(endpoint = "projects", query = query)
  
  res
  
}


redmine_projects_df <- function(include = NULL) {
  
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (include == "all")
    include <- includeChoices
  if (!is.null(include))
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  
  query <- NULL
  if (length(include) > 0)
    query <- paste0("include=", paste0(include, collapse = ","))

  projects_df <- redmine_get_all_pages(endpoint = "projects", query = query)
  
  projects_df
  
}

redmine_get_project <- redmine_show_project <- function(project_id, include = NULL) {
  
  # TODO: describe these in the doc
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (include == "all")
    include <- includeChoices
  if (!is.null(include))
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  
  endpoint <- paste0("projects/", project_id, ".json")
  query <- NULL
  if (length(include) > 0)
    
    query <- paste0("include=", paste0(include, collapse = ","))
  
  res <- redmine_get(endpoint = endpoint, query = query)
  
  res
  
}

redmine_create_project <- function(name, identifier, description = NULL,
    homepage = NULL, is_public = TRUE, parent_id = NULL, inherit_members = TRUE,
    tracker_ids = NULL, enabled_module_names = c("boards", "calendar", 
        "documents", "files", "gantt", "issue_tracking", "news", "repository", 
        "time_tracking", "wiki"), ...) {
  
  enabled_module_names <- match.arg(enabled_module_names, several.ok = TRUE)
  
  projectList <- list(
      name = name,
      identifier = identifier,
      description = description,
      homepage = homepage,
      is_public = is_public,
      parent_id = parent_id,
      inherit_members = inherit_members,
      tracker_ids = tracker_ids,
      enabled_module_names = enabled_module_names
  )
  
  # remove NULL elements
  projectList <- removeNULL(projectList)
  
  # add extra arguments
  projectList <- modifyList(projectList, list(...))
  
  body <- list(project = projectList) 
  
  res <- redmine_post("projects.json", body = body, encode = "json")
  
  res$content$project$id
  
}

redmine_update_project <- function(project_id, name = NULL, identifier = NULL, 
    description = NULL, homepage = NULL, is_public = NULL, parent_id = NULL, 
    inherit_members = NULL, tracker_ids = NULL, enabled_module_names = NULL, 
    ...) {
  
  moduleChoices <- c("boards", "calendar", "documents", "files", "gantt", 
      "issue_tracking", "news", "repository", "time_tracking", "wiki")
  if (!is.null(enabled_module_names))
    enabled_module_names <- match.arg(enabled_module_names, moduleChoices, 
        several.ok = TRUE)
  
  projectList <- list(
      project_id = project_id,
      name = name,
      identifier = identifier,
      description = description,
      homepage = homepage,
      is_public = is_public,
      parent_id = parent_id,
      inherit_members = inherit_members,
      tracker_ids = tracker_ids,
      enabled_module_names = enabled_module_names
  )
  
  # remove NULL elements
  projectList <- removeNULL(projectList)
  
  # add extra arguments
  projectList <- modifyList(projectList, list(...))
  
  body <- list(project = projectList) 
  
  res <- redmine_request("PUT", paste0("projects/", project_id, ".json"), 
      body = body, encode = "json")
  
  invisible(res)
  
}

redmine_delete_project <- function(project_id) {
  res <- redmine_request("DELETE", paste0("projects/", project_id, ".json"))
  invisible(res)
}
