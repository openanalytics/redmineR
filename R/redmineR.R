#' R client for Redmine API
#' 
#' @description R API client for the 'Redmine' project management system.
#' 
#' @details The package provides:
#' \itemize{
#'  \item API functions that follow API description from 
#' \url{http://www.redmine.org/projects/redmine/wiki/Rest_api}:
#'  \item convenience functions that wrap around API functions for some useful 
#' tasks:
#' }
#' Requests are performed using \code{httr} package, and if they fail, HTTP 
#' errors are reported.
#' 
#' @section Authentication:
#' Authentication is performed using API key, which can be obtained by accessing 
#' '[you_redmine_server]/my/account'. Note that REST API should be enabled by 
#' the server administrator.
#' 
#' The easiest way to provide the key to \code{redmineR} is to define 
#' environment variables REDMINE_URL and REDMINE_TOKEN inside your .Renviron 
#' file. If this is not done, you will be prompted to enter url/token with the 
#' first \code{redmineR} request (this would be saved for the current session 
#' only). 
#' 
#' @seealso The Redmine API is described at
#' \url{http://www.redmine.org/projects/redmine/wiki/Rest_api}
#'
#' @import httr 
#' @docType package
#' @name redmineR

NULL