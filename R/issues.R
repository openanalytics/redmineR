## 
redmine_upload <- function(filepath, ...) {
  uploadRes <- redmine_post("uploads.json", 
      body = upload_file(filepath, type = "application/octet-stream"))
  uploadRes$content$upload$token
} 

#' @importFrom mime guess_type
makeUploadList <- function(files) {
  
  lapply(files, function(file) {
        fileToken <- redmine_upload(file)
        list(
            token = fileToken,
            filename = file,
            content_type = mime::guess_type(file)
        )}
  )
}

#' Create/update/delete issue
#' 
#' These functions implement Redmine API calls to work with issues.
#' @param project_id Project id to add issue to 
#' @param subject Issue subject (title)
#' @param description Issue description
#' @param files List of filenames to add (upload) to the issue
#' @param tracker_id Tracker id(s)
#' @param status_id Status id
#' @param priority_id Priority id
#' @param category_id Issue category id
#' @param fixed_version_id Target Version id
#' @param assigned_to_id User id to assign to
#' @param parent_issue_id Parent issue id
#' @param custom_fields Custom fields, as list, see examples
#' @param watcher_user_ids User id(s) to add as watchers
#' @param is_private Whether the issue is private
#' @param estimated_hours Estimated number of hours
#' @param ... Further parameters 
#' @return id of the created issue for \code{redmine_create_issue}
#' @seealso \url{http://www.redmine.org/projects/redmine/wiki/Rest_Issues}
#' @author Maxim Nazarov
#' @examples \dontrun{
#' # first get necessary ids
#' projectID <- redmine_search_id("testProject", 
#'     endpoint = "projects")
#' 
#' urgentID <- redmine_search_id("Urgent", 
#'     endpoint = "issue_priorities")
#' 
#' # now create issue
#' issueID <- redmine_create_issue(
#'     project_id = projectID, 
#'     subject = "Urgent task", 
#'     description = "Do it quick!", 
#'     priority_id = urgentID,
#'     files = "details.txt")
#' 
#' # modify using custom fields
#' redmine_update_issue(issueID, 
#'     custom_fields = list(
#'         list(id = 1, name = "myField", value = 100),
#'         list(id = 2, name = "myField2", value = 200)
#'     )
#' )   
#' }
#' @export
redmine_create_issue <- function(project_id, subject, description = NULL, 
    files = NULL, tracker_id = NULL, status_id = NULL, priority_id = NULL, 
    category_id = NULL, fixed_version_id = NULL, assigned_to_id = NULL, 
    parent_issue_id = NULL, custom_fields = NULL, watcher_user_ids = NULL, 
    is_private = NULL, estimated_hours = NULL, ...) {
  
#  fileTokens <- sapply(files, redmine_upload)
#  stopifnot(length(fileTokens) == length(files))
  
  issueList <- list(
      project_id = project_id,
      subject = subject,
      description = description,
      uploads = makeUploadList(files),
      tracker_id = tracker_id,
      status_id = status_id,
      priority_id = priority_id,
      category_id = category_id,
      fixed_version_id = fixed_version_id,
      assigned_to_id = assigned_to_id,
      parent_issue_id = parent_issue_id,
      custom_fields = custom_fields,
      watcher_user_ids = watcher_user_ids,
      is_private = is_private,
      estimated_hours = estimated_hours 
  )
  
  # remove NULL elements
  issueList <- removeNULL(issueList)
  
  # add extra arguments
  issueList <- modifyList(issueList, list(...))
  
  # create issue
  body <- list(issue = issueList) 
  
  issueRes <- redmine_post("issues.json", body = body, encode = "json")
  
  issueRes$content$issue$id
}

#' @param issue_id Issue id
#' @param notes Notes (comments) to add
#' @param private_notes Private notes to add 
#' @rdname redmine_create_issue
#' @export
redmine_update_issue <- function(issue_id, notes = NULL, project_id = NULL,
    tracker_id = NULL, status_id = NULL, subject = NULL, private_notes = FALSE,
    files = NULL, ...) {
  
  issueList <- list(
      notes = notes, 
      project_id = project_id, 
      tracker_id = tracker_id, 
      status_id = status_id, 
      subject = subject, 
      private_notes = private_notes, 
      uploads = makeUploadList(files)
  )
  
  # remove NULL elements
  issueList <- removeNULL(issueList)
  
  # add extra arguments
  issueList <- modifyList(issueList, list(...))
  
  # create issue
  body <- list(issue = issueList) 
  
  issueRes <- redmine_request("PUT", paste0("issues/", issue_id, ".json"), 
      body = body, encode = "json")
  
  invisible(issueRes)
}

#' @rdname redmine_create_issue
#' @export
redmine_delete_issue <- function(issue_id) {
  res <- redmine_request("DELETE", paste0("issues/", issue_id, ".json"))
  invisible(res)
}

#' Move issue to another project
#' 
#' A wrapper on top of the generic \code{\link{redmine_update_issue}}
#' 
#' @param issue_id Issue id 
#' @param new_project_id id of the project to move issue to
#' @param notes notes (comments) to add
#' @param ... extra arguments to passed to \code{\link{redmine_update_issue}}
#' @author Maxim Nazarov
#' @export
redmine_move_issue <- function(issue_id, new_project_id, notes = NULL, ...) {
  redmine_update_issue(issue_id = issue_id, notes = notes, 
      project_id = new_project_id, ...)
}

#' Add watcher to an issue
#' 
#' @param issue_id Issue id
#' @param user_id User id to add as a watcher 
#' @author Maxim Nazarov
#' @export
redmine_add_watcher <- function(issue_id, user_id) {
  res <- redmine_post(paste0("issues/", issue_id, "/watchers/", user_id, ".json"))
  invisible(res)
}

#' Remove watcher from an issue
#' 
#' @param issue_id Issue id
#' @param user_id User id to remove as a watcher 
#' @author Maxim Nazarov
#' @export
redmine_delete_watcher <- function(issue_id, user_id) {
  res <- redmine_request("DELETE", 
      paste0("issues/", issue_id, "/watchers/", user_id, ".json"))
  invisible(res)
}

#' Show issue information
#' 
#' @param issue_id Issue id 
#' @param include Which extra info to include, either NULL (no, default), "all" 
#' or a subset of \code{c("children", "attachments", "relations", "changesets", 
#'       "journals", "watchers")}
#' @return a \code{redminer} object with issue information
#' @author Maxim Nazarov
#' @seealso \code{\link{redmine_search_id}} to search for id by subject
#' @examples \dontrun{
#'  issueId <- redmine_search_id("Urgent task", endpoint = "issues")
#'  redmine_show_issue(issue_id = issueId, include = "all")
#' }
#' @export
redmine_show_issue <- function(issue_id, 
    include = NULL) {
  # TODO: describe these in the doc
  includeChoices <- c("children", "attachments", "relations", "changesets", 
      "journals", "watchers")
  if (!is.null(include)) {
    if (include == "all")
      include <- includeChoices
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  }
    
  
  endpoint <- paste0("issues/", issue_id, ".json")
  query <- NULL
  if (length(include) > 0)
    query <- paste0("include=", paste0(include, collapse = ","))
  
  res <- redmine_get(endpoint = endpoint, query = query)
  
  res
    
}

#' @export
#' @rdname redmine_show_issue
redmine_get_issue <- redmine_show_issue

#' Download attachments from an issue
#'  
#' @param issue_id Issue id 
#' @param path Path to save files to
#' @author Maxim Nazarov
#' @export
redmine_download_attachments <- function(issue_id, path = ".") {
  
  issue <- redmine_get_issue(issue_id, include = "attachments")
  attachments <- issue$content$issue$attachments
  
  for (attachment in attachments) {
    savePath <- file.path(path, attachment$filename)
    
    res <- GET(url = attachment$content_url, 
        add_headers("X-Redmine-API-Key" = redmine_token()),
        write_disk(savePath))
    
    message("Downloaded: ", savePath)
  }
  
}

#' List issues
#' 
#' Implements Redmine API call to list issues. Note that the output will be 
#' limited to one page, but \code{offset} or \code{page} can be specified.
#' @param offset Number of issues to skip 
#' @param limit Limit number of issues returned
#' @param sort Sorting columns
#' @param issue_id Issue id(s) to filter by
#' @param project_id Project id to filter by
#' @param subproject_id Sub-project id to filter by
#' @param tracker_id Tracker id
#' @param status_id Status id
#' @param assigned_to_id user id issues are assigned to
#' @param parent_id Parent issue id
#' @param query_id Custom query id
#' @param ... Further arguments
#' @return a \code{redminer} object
#' @examples \dontrun{
#'  redmine_list_issues(project_id = 1, issue_id="123,124")
#'  redmine_list_issues(assigned_to_id = 27, limit = 5, offset = 200)
#'  redmine_list_issues(project_id = 2, created_on = ">=2017-06-02T08:12:32Z")
#' }
#' @author Maxim Nazarov
#' @seealso \code{\link{redmine_issues}} to show all issues as a data frame 
#' @export
redmine_list_issues <- function(offset = NULL, limit = NULL, sort = NULL,
    issue_id = NULL, project_id = NULL, subproject_id = NULL, tracker_id = NULL, 
    status_id = NULL, assigned_to_id = NULL, parent_id = NULL, query_id, ...) {

  funArgs <- removeNULL(c(as.list(environment()), list(...)))
  if (length(funArgs) > 0) {
    query <- paste0(names(funArgs), "=", funArgs, collapse = "&")
  } else
    query <- NULL
  
  res <- redmine_get("issues", query = query)
  res

}


## merge all pages together

#' Show all issues as a data frame
#' 
#' @inheritParams redmine_list_issues
#' @return a data frame 
#' @author Maxim Nazarov
#' @examples \dontrun{
#'  redmine_issues()
#'  redmine_issues(project_id = 1)
#'  redmine_issues(assigned_to_id = 27)
#' }
#' @export
redmine_issues <- function(sort = NULL,
    issue_id = NULL, project_id = NULL, subproject_id = NULL, tracker_id = NULL, 
    status_id = NULL, assigned_to_id = NULL, parent_id = NULL, query_id, ...) {
  
  funArgs <- removeNULL(c(as.list(environment()), list(...)))
  
  if (length(funArgs) > 0) {
    query <- paste0(names(funArgs), "=", funArgs, collapse = "&")
  } else
    query <- NULL
  
  issues_df <- redmine_get_all_pages(endpoint = "issues", query = query)
  
  issues_df
  
}
