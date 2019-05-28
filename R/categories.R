#' Create category
#' @param name Category name
#' @inheritParams redmine_create_issue
#' @return id of the created category
#' @author Laure Cougnaud
#' @examples \dontrun{
#' # first get necessary ids
#' projectID <- redmine_search_id("testProject", 
#'     endpoint = "projects")
#' 
#' # now create category
#' issueID <- redmine_create_category(
#'    project_id = projectID, 
#'    name = "Functionality")
#' }
#' @export
redmine_create_category <- function(
	project_id, name, assigned_to_id = NULL,  ...) {
	
	categoryList <- list(name = name, assigned_to_id = assigned_to_id)
	
	# remove NULL elements
	categoryList <- removeNULL(categoryList)
	
	# add extra arguments
	categoryList <- modifyList(categoryList, list(...))
	
	# create issue
	body <- list(issue_category = categoryList) 
	
	endpoint <- paste0("/projects/", project_id, "/issue_categories.json")
	categoryRes <- redmine_post(
		endpoint = endpoint, 
		body = body, 
		encode = "json"
	)
	
	categoryID <- categoryRes$content$issue_category$id
	return(categoryID)
}
