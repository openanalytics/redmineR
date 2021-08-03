## 

#' Show info on extra endpoints
#' 
#' Convenience functions to list endpoints, in particular to get ids to be 
#' used in creating/updating or listing issues or projects.
#' @return a data frame
#' @seealso \code{\link{redmine_search_id}} to search id by name
#' @seealso \code{\link{redmine_issues}}, \code{\link{redmine_projects}} to 
#' show info on issues and projects
#' @export
redmine_trackers <- function() {
  redmine_get_all_pages("trackers")
}

#' @rdname redmine_trackers
#' @export
redmine_issue_statuses <- function() {
  redmine_get_all_pages("issue_statuses")
}

#' @rdname redmine_trackers
#' @export
redmine_users <- function() {
  redmine_get_all_pages("users")
}

#' @rdname redmine_trackers
#' @export
redmine_time_entries <- function(
  from = NULL,
  to   = NULL,
  project = NULL
) {
  
  if ( !is.null(from) ) {
    from <- paste0("from=", from)
  }
  
  if ( !is.null(to) ) {
    to <- paste0("to=", to)
  }
  
  if ( !is.null(project) ) {
    project <- paste0("project=", project)
  }
  
  query <- paste0(c(from, to, project), collapse = "&")
  
  redmine_get_all_pages("time_entries", query = query)
}

#' @rdname redmine_trackers
#' @export
redmine_custom_fields <- function() {
  redmine_get_all_pages("custom_fields")
}


# enumerations

#' @rdname redmine_trackers
#' @export
redmine_issue_priorities <- function() {
  redmine_get_all_pages("enumerations/issue_priorities")
}

#' @rdname redmine_trackers
#' @export
redmine_time_entry_activities <- function() {
  redmine_get_all_pages("enumerations/time_entry_activities")
}

#' @rdname redmine_trackers
#' @export
redmine_document_categories <- function() {
  redmine_get_all_pages("enumerations/document_categories")
}
