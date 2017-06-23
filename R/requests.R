## 
#' do a general API request
redmine_request <- function(type = c("GET", "POST", "PUT", "DELETE"), 
    endpoint = "issues.json", query = NULL, simplify = FALSE,
    url = redmine_url(), token = redmine_token(), ...) {
  
  type <- match.arg(type)
  
  endpoint <- gsub("\\.xml$", ".json", endpoint)
  if (!grepl("\\.json$", endpoint))
    endpoint <- paste0(endpoint, ".json")
  
  fullpath <- modify_url(url = url, path = endpoint, query = query)
  
  res <- VERB(type, url = fullpath, add_headers("X-Redmine-API-Key" = token), 
      ...)
  
  if (http_type(res) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(res, "text"), simplifyVector = simplify)
  
#  stop_for_status(res)
  if (http_error(res)) {
    stop(
        paste0("Redmine API request failed [", status_code(res), "]:\n - ",
            paste(parsed$errors, collapse = "\n - ")),
        call. = FALSE
    )
  }
  
  
  structure(
      list(
          content = parsed,
          url = fullpath,
          response = res
      ), 
      class = "redminer"
  )
  
}

redmine_get <- function(...) {
  redmine_request("GET", ...)
}
redmine_post <- function(...) {
  redmine_request("POST", ...)
}

print.redminer <- function(x, ...) {
  cat("Redmine ", x$url, "\n")
  str(x$content)
  invisible(x)
}
