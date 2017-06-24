## 
redmine_upload <- function(filepath, ...) {
  uploadRes <- redmine_post("uploads.json", 
      body = upload_file(filepath, type = "application/octet-stream"))
  uploadRes$content$upload$token
} 

makeUploadList <- function(files) {
  
  lapply(files, function(file) {
        fileToken <- redmine_upload(file)
        list(
            "token" = fileToken,
            "filename" = file,
            "content_type" = mime::guess_type(file)
        )}
  )
}

#' create new issue
redmine_create_issue <- function(project_id, subject, 
    description = NULL, files = NULL, ...) {
  
#  fileTokens <- sapply(files, redmine_upload)
#  stopifnot(length(fileTokens) == length(files))
  
  issueList <- list(
      "project_id" = project_id,
      "subject" = subject,
      "description" = description,
      "uploads" = makeUploadList(files)
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

#redmine_create_issue(493, "test simple issue", "I *am* a _description_", 
#    files = "../files/abstract_template.md", "assigned_to_id" = 27)

redmine_update_issue <- function(issue_id, notes = NULL, project_id = NULL,
    tracker_id = NULL, status_id = NULL, subject = NULL, private_notes = FALSE,
    files = NULL, ...) {
  
  issueList <- list(
      "notes" = notes, 
      "project_id" = project_id, 
      "tracker_id" = tracker_id, 
      "status_id" = status_id, 
      "subject" = subject, 
      "private_notes" = private_notes, 
      "uploads" = makeUploadList(files)
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

#' wrapper on top of generic update_issue
redmine_move_issue <- function(issue_id, new_project_id, notes = NULL, ...) {
  redmine_update_issue(issue_id = issue_id, notes = notes, 
      project_id = new_project_id, ...)
}

redmine_delete_issue <- function(issue_id) {
  res <- redmine_request("DELETE", paste0("issues/", issue_id, ".json"))
  invisible(res)
}


redmine_add_watcher <- function(issue_id, user_id) {
  res <- redmine_post(paste0("issues/", issue_id, "/watchers/", user_id, ".json"))
  invisible(res)
}

redmine_delete_watcher <- function(issue_id, user_id) {
  res <- redmine_request("DELETE", 
      paste0("issues/", issue_id, "/watchers/", user_id, ".json"))
  invisible(res)
}

redmine_get_issue <- redmine_show_issue <- function(issue_id, 
    include = NULL) {
  # TODO: describe these in the doc
  includeChoices <- c("children", "attachments", "relations", "changesets", 
      "journals", "watchers")
  if (!is.null(include))
    include <- match.arg(include, includeChoices, several.ok = TRUE)
  
  endpoint <- paste0("issues/", issue_id, ".json")
  query <- NULL
  if (length(include) > 0)
    query <- paste0("include=", paste0(include, collapse = ","))
  
  res <- redmine_get(endpoint = endpoint, query = query)
  
  res
    
}


redmine_download_attachments <- function(issue_id, path = ".", mode = "wb",
    token = redmine_token()) {
  
  issue <- redmine_get_issue(issue_id, include = "attachments")
  attachments <- issue$content$issue$attachments
  
  for (attachment in attachments) {
    savePath <- file.path(path, attachment$filename)
    
    res <- GET(url = attachment$content_url, 
        add_headers("X-Redmine-API-Key" = token),
        write_disk(savePath))
    
    message("Downloaded: ", savePath)
  }
  
}