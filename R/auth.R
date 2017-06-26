## 
redmine_url <- function(url = NULL) {
  
  envUrl <- Sys.getenv("REDMINE_URL", "")
  if (identical(envUrl, "")) {
    if (!is.null(url)) {
      envUrl <- url
    } else {
      message("Please set environment variable REDMINE_URL to your Redmine url. ", 
          "You can use .Renviron file to do so globally.")
      if (interactive()) {
        message("You can set it now for the current session:")
        envUrl <- readline("redmine url: ")
      }
    }
    Sys.setenv("REDMINE_URL" = envUrl)
  }
  
  envUrl
  
}

# access at redmineURL/my/api_key
redmine_token <- function(token = NULL) { 
  
  envToken <- Sys.getenv("REDMINE_TOKEN", "")
  if (identical(envToken, "")) {
    if (!is.null(token)) {
      envToken <- token   
    } else {
      message("Please set environment variable REDMINE_URL to your api key. ", 
          "You can use .Renviron file to do so globally.")
      if (interactive()) {
        message("You can set it now for the current session:")
        envToken <- readline("redmine token: ")
        
      }
    }
    Sys.setenv("REDMINE_TOKEN" = envToken)
  }
  
  envToken
  
}
