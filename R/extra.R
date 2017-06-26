## 

redmine_trackers <- function() {
  redmine_get_all_pages("trackers")
}

redmine_issue_statuses <- function() {
  redmine_get_all_pages("issue_statuses")
}

redmine_users <- function() {
  redmine_get_all_pages("users")
}

redmine_time_entries <- function() {
  redmine_get_all_pages("time_entries")
}

# enumerations
redmine_issue_priorities <- function() {
  redmine_get_all_pages("enumerations/issue_priorities")
}

redmine_time_entry_activities <- function() {
  redmine_get_all_pages("enumerations/time_entry_activities")
}

redmine_document_categories <- function() {
  redmine_get_all_pages("enumerations/document_categories")
}
