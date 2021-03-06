% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{redmine_search_id}
\alias{redmine_search_id}
\title{Search id by name}
\usage{
redmine_search_id(name = NULL, endpoint = "projects", query = NULL)
}
\arguments{
\item{name}{string to search for}

\item{endpoint}{endpoint where to search ("projects", "issues", ...)}

\item{query}{extra query arguments}
}
\value{
id(s) found invisibly, in addition summary of search results is 
printed
}
\description{
Search happens inside the 'subject' field for issues and 'name' for other 
endpoints.
}
\author{
Maxim Nazarov
}
