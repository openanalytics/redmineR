## 

removeNULL <- function(x) {
  x[!sapply(x, is.null)]
}

redmine_get_all_pages <- function(endpoint, query = NULL, maxLimit = 100) {
  
  nameEndpoint <- gsub(".*/([^/.]*).*$", "\\1", endpoint)
  limit  <- maxLimit
  offset <- 0
  pageQuery <- paste0("limit=", limit, "&offset=", offset, "&", query)
  
  res <- redmine_get(endpoint = endpoint, query = pageQuery)
  resList <- res$content[[nameEndpoint]]
  
  N <- res$content$total_count
  
  if (!is.null(N) && N > limit) {
    
    offsets <- seq(from = limit, to = N, by = limit)
    
    for (iPage in seq_along(offsets)) {
      pageQuery <- paste0("limit=", limit, "&offset=", offsets[iPage], "&", query)
      res <- redmine_get(endpoint = endpoint, query = pageQuery)
      resList <- c(resList, res$content[[nameEndpoint]])
    }
  }
  
  # implement 'fill' manually
  allNames <- Reduce(union, lapply(resList, function(x) names(x))) 
  
  vectors <- lapply(resList, function(x) {
        res <- x
        namesToAdd <- setdiff(allNames, names(res))
        res[namesToAdd] <- NA
        res[allNames]
      })
  
  res_df <- as.data.frame(do.call(rbind, vectors), stringsAsFactors = FALSE)
  
  # unlist columns that are actually atomic
  atomicCols <- names(res_df)[vapply(res_df, function(col) all(lengths(col) == 1), logical(1))]
  res_df[atomicCols] <- lapply(res_df[atomicCols], unlist)

  attr(res_df, "endpoint") <- endpoint
  attr(res_df, "query") <- query
  class(res_df) <- append("redminer_df", class(res_df))
  
  res_df
  
}


print.redminer_df <- function(x, cut = 20, ...) {
  if (!is.null(x$description) && is.character(x$description))
    x$description <- ifelse(nchar(x$description) > cut,
        paste0(substr(x$description, 1, cut), " ..."), x$description)
    
  # process list columns
  # TODO
  listCols <- names(x)[vapply(x, is.list, logical(1))]
#  print.data.frame(x[, grep("\\.id$", names(x), value = TRUE, invert = TRUE)])
  cat("redmineR listing",
      if (!is.null(attr(x, "endpoint"))) paste0(" for '", attr(x, "endpoint"), "'"), 
      if (!is.null(attr(x, "query"))) paste0(" [query = ", attr(x, "query"), "]"),
      ":\n", sep = "")
  
  print.data.frame(x)
}


#' Search id by name
#'  
#' @param name string to search for
#' @param endpoint endpoint where to search ("projects", "issues", ...)
#' @param query extra query arguments 
#' @return id(s) found invisibly, in addition summary of search results is 
#' printed 
#' 
#' @author Maxim Nazarov
#' @export
redmine_search_id <- function(name = NULL, endpoint = "projects", query = NULL) {
  
  enumerations <- c("issue_priorities", "time_entry_activities", 
      "document_categories")
  if (endpoint %in% enumerations)
    endpoint <- paste0("enumerations/", endpoint)
  
  res <- redmine_get_all_pages(endpoint = endpoint, query = query)
  
  colSearch <- if (endpoint == "issues") "subject" else "name"
  ans <- if (!is.null(name)) 
        res[grepl(name, res[[colSearch]], ignore.case = TRUE), ] else res
  
  if (nrow(ans) == 0)
    stop("No id found")
  print(ans)
  invisible(ans[, "id"])
}

