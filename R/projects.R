## 

#' List projects
#' 
#' Implements Redmine API call to list projects. Note that the output will be 
#' limited to one page, but \code{offset} or \code{page} can be specified.
#' @param include Which extra info to include, either NULL (no, default), "all" 
#' or a subset of \code{c("trackers", "issue_categories", "enabled_modules")}
#' @param ... further query arguments, such as \code{offset}, \code{limit} or 
#' \code{page}
#' @return a \code{redminer} object
#' @examples \dontrun{
#'  redmine_list_projects(include = "all")
#'  redmine_list_projects(offset = 50)
#'  redmine_list_projects(limit = 20, page = 3)
#' }
#' @author Maxim Nazarov
#' @seealso \code{\link{redmine_projects}} to show all projects as a data frame 
#' @export
redmine_list_projects <- function(include = NULL, ...) {
  
  # TODO: describe these in the doc
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (!is.null(include)) {
    if (include == "all")
      include <- includeChoices
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  }  
  
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


#' Show all projects as a data frame
#' 
#' @param include Which extra info to include, either NULL (no, default), "all" 
#' or a subset of \code{c("trackers", "issue_categories", "enabled_modules")}
#' @return a data frame
#' @author Maxim Nazarov
#' @examples \dontrun{
#'  redmine_projects()
#'  redmine_projects(include = "all")
#' }
#' @export
redmine_projects <- function(include = NULL) {
  
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (!is.null(include)) {
    if (include == "all")
      include <- includeChoices
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  }
  
  query <- NULL
  if (length(include) > 0)
    query <- paste0("include=", paste0(include, collapse = ","))

  projects_df <- redmine_get_all_pages(endpoint = "projects", query = query)
  
  projects_df
  
}

#' Show project information
#' 
#' @param project_id Project ID
#' @param include Which extra info to include, either NULL (no, default), "all" 
#' or a subset of \code{c("trackers", "issue_categories", "enabled_modules")}
#' @return Project information 
#' @author Maxim Nazarov
#' @seealso \code{\link{redmine_search_id}} to search for id by name
#' @examples \dontrun{
#'  projectId <- redmine_search_id("testProject", endpoint = "projects")
#'  redmine_show_project(project_id = projectId, include = "all")
#' }
#' @export
redmine_show_project <- function(project_id, include = NULL) {
  
  # TODO: describe these in the doc
  includeChoices <- c("trackers", "issue_categories", "enabled_modules")
  if (!is.null(include)) {
    if (include == "all")
      include <- includeChoices
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  }    
  
  endpoint <- paste0("projects/", project_id, ".json")
  query <- NULL
  if (length(include) > 0)
    
    query <- paste0("include=", paste0(include, collapse = ","))
  
  res <- redmine_get(endpoint = endpoint, query = query)
  
  res
  
}

#' @export
#' @rdname redmine_show_project
redmine_get_project <- redmine_show_project

#' Create/update/delete project
#' 
#' Implement Redmine API calls to work with projects.
#' @param name Project name
#' @param identifier Project identifier (no spaces)
#' @param description Project description
#' @param homepage Project homepage
#' @param is_public Whether project should be made public (TRUE by default)
#' @param parent_id Project's parent id
#' @param inherit_members Whether to inherit members from parent
#' @param tracker_ids Trackers id's 
#' @param enabled_module_names Enabled modules, a subset of \code{c("boards", 
#' "calendar", "documents", "files", "gantt", "issue_tracking", "news", 
#' "repository", "time_tracking", "wiki")} 
#' @param ... Further parameters
#' @return ID of the created project for \code{redmine_create_project}
#' @seealso \url{http://www.redmine.org/projects/redmine/wiki/Rest_Projects}
#' @author Maxim Nazarov
#' @examples \dontrun{
#'   newProjectId <- redmine_create_project(name = "testProject",
#'       identifier = "test-project", description = "project to testthings",
#'       enabled_module_names = c("files", "issue_tracking", "repository", 
#'           "time_tracking", "wiki"))
#'   
#'   redmine_update_project(newProjectId, description = "project to test things")
#'   redmine_delete_project(newProjectId)
#' }
#' @export
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

#' @param project_id Project id 
#' @rdname redmine_create_project
#' @export
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

#' @rdname redmine_create_project
#' @seealso \code{\link{redmine_search_id}} to search id by name
#' @export
redmine_delete_project <- function(project_id) {
  res <- redmine_request("DELETE", paste0("projects/", project_id, ".json"))
  invisible(res)
}
