## 

redmine_getProjectId <- function(projectName, ...) {
  projectRes <- redmine_get("projects", query = "limit=100", simplify = TRUE, ...)
  # TODO pages
  projDF <- projectRes$content$projects
  
  res <- projDF[grepl(projectName, projDF$name, ignore.case = TRUE), ]
  if (nrow(res) == 0)
    stop("No project found")
  print(res)
  invisible(res)
}



#' get id from (partial) name
redmine_getIdFromName <- function(name = NULL, endpoint = "projects", ...) {
  res <- redmine_get(endpoint, query = "limit=100", simplify = TRUE, ...)
  
  contentsDF <- res$content[[1]] # NB: not robust
  
  #contentsDT <- rbindlist(lapply(contents, as.data.table), fill = T)
#  cName <- name
  colSearch <- if (endpoint == "issues") "subject" else "name"
  ans <- if (!is.null(name)) contentsDF[grepl(name, contentsDF[[colSearch]], ignore.case = TRUE), ] else contentsDF
  if (nrow(ans) == 0)
    stop("No id found")
  print(ans)
  invisible(ans[["id"]])
}

# TODO
##' use pages, experimental
#redmine_getIdFromName2 <- function(name = NULL, endpoint = "projects", 
#    query = "", print = TRUE, ...) {
#  res <- redmine_get(endpoint, query = query)
#  N <- content(res)$total_count
#  limit <- 100
#  pages <- seq(from = 0, to = N, by = limit)
#  contents <- list()
#  for (iPage in seq_along(pages)) {
#    pageQuery <- paste0(c(paste0("offset=", pages[iPage]), "limit=100", query), collapse = "&")
#    res <- redmine_get(endpoint, query = pageQuery, ...)
#    stop_for_status(res)
#    contents[[iPage]] <- rbindlist(lapply(content(res)[[1]], as.data.table), fill = TRUE) # NB: [[1]] not robust? endpoint better?
#  }
#  contentsDT <- rbindlist(contents, fill = TRUE)
#  cName <- name
#  colSearch <- if (endpoint == "issues") "subject" else "name"
#  ans <- if (!is.null(name)) contentsDT[get(colSearch) %like% cName] else contentsDT
#  if (nrow(ans) == 0)
#    stop("No id found")
#  if (print)
#    print(ans[, unique(id)])
#  invisible(list(id = ans[, unique(id)], info = ans, full = contentsDT))
#}
