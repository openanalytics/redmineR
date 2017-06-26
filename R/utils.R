## 

removeNULL <- function(x) {
  x[!sapply(x, is.null)]
}

redmine_get_all_pages <- function(endpoint, query = NULL, maxLimit = 100) {
  
  limit  <- maxLimit
  offset <- 0
  pageQuery <- paste0("limit=", limit, "&offset=", offset, "&", query)
  
  res <- redmine_get(endpoint = endpoint, query = pageQuery)
  resList <- res$content[[endpoint]]
  
  N <- res$content$total_count
  
  if (!is.null(N) && N > limit) {
    
    offsets <- seq(from = limit, to = N, by = limit)
    
    for (iPage in seq_along(offsets)) {
      pageQuery <- paste0("limit=", limit, "&offset=", offsets[iPage], "&", query)
      res <- redmine_get(endpoint = endpoint, query = pageQuery)
      resList <- c(resList, res$content[[endpoint]])
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

# instead of getIdFromName
redmine_search_id <- function(name = NULL, endpoint = "projects", query = NULL, ...) {
  res <- redmine_get_all_pages(endpoint = endpoint, query = query)
  
#  cName <- name
  colSearch <- if (endpoint == "issues") "subject" else "name"
  ans <- if (!is.null(name)) 
        res[grepl(name, res[[colSearch]], ignore.case = TRUE), ] else res
  
  if (nrow(ans) == 0)
    stop("No id found")
  print(ans)
  invisible(ans[, "id"])
}
