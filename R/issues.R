## 
redmine_upload <- function(filepath, ...) {
  uploadRes <- redmine_post("uploads.json", 
      body = upload_file(filepath, type = "application/octet-stream"))
  stop_for_status(uploadRes)
  content(uploadRes)$upload$token
} 

#' create new issue
redmine_create_issue <- function(projectId = "", subject = "", 
    description = "", files = NULL, ...) {
  # 1. upload file(s) and get token(s)
  
  fileTokens <- sapply(files, redmine_upload)
  
  stopifnot(length(fileTokens) == length(files))
  
  issueList <- list(
      "project_id" = as.character(projectId),
      "subject" = subject,
      "description" = description,
      "uploads" = 
          lapply(seq_along(files), function(i) {
                list(
                    "token" = fileTokens[i],
                    "filename" = files[i],
                    "content_type" = mime::guess_type(files[i])
                )}
          )
  )
  
  issueList <- modifyList(issueList, list(...))
  
  # 2. create issue
  body <- list(issue = issueList) 
  
  issueRes <- redmine_post("issues.json", body = body, encode = "json")
  
  issueRes
}

#redmine_create_issue(493, "test simple issue", "I *am* a _description_", 
#    files = "../files/abstract_template.md", "assigned_to_id" = 27)

redmine_update_issue <- function(issueId, notes = NULL, ...) {
  
  issueList <- list()
  if (!is.null(notes)) 
    issueList <- modifyList(issueList, list("notes" = notes))
  issueList <- modifyList(issueList, list(...))
  
  body <- list(issue = issueList) 
  
  issueRes <- redmine_request("PUT", paste0("issues/", issueId, ".json"), body = body, encode = "json")
  stop_for_status(issueRes)
  content(issueRes)
}

#' wrapper on top of generic update_issue
redmine_move_issue <- function(issueId, newProjectId, notes = NULL) {
  redmine_update_issue(issueId = issueId, notes = notes, project_id = newProjectId)
}