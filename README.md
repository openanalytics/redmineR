<!-- README.md is generated from README.Rmd. Please edit that file -->
redmineR
========

`redmineR` is an R API client for the [Redmine](http://www.redmine.org) project management system.

Installation
------------

To install the package from GitHub, you can use devtools:

``` r
# install.packages("devtools")
devtools::install_github("openanalytics/redmineR")
```

To get a quick package overview, run:

``` r
library(redmineR)
?redmineR
```

Authentication
--------------

Authentication is performed using API key, which can be obtained by accessing `[redmine_server_URL]/my/account`. Note that REST API should be enabled by the server administrator.

The easiest way to provide the API key to `redmineR` is to define environment variables `REDMINE_URL` and `REDMINE_TOKEN` inside your `.Renviron` file. If these variables are not defined, you will be prompted to enter url/token with the first `redmineR` request (this would be saved for the current session only).

Example
-------

You can quickly get a working Redmine demo environment to try `redmineR` by filling a simple form at <http://m.redmine.org>. After that log-in to the administration panel, and click "Load default configuration". Then make sure "Enable REST web service" is checked in the "Settings".

As mentioned on the website,

> Please, remember that this demo environment is provided with absolutely NO WARRANTY and for TESTING PURPOSE ONLY. The access to this environment can be disabled and your data deleted at any time, so don't store sensitive information here.

The following example shows an interaction with such a demo environment. Feel free to use authentication details provided, but there is no guarantee they will remain functional.

### Set authentication for the current session

``` r
Sys.setenv("REDMINE_URL" = "http://rredmine.m.redmine.org")
Sys.setenv("REDMINE_TOKEN" = "b91fe6803b09b27b068ee02157db2a8100d52f81")
```

### See what is already there

``` r
redmine_projects()
#> redmineR listing for 'projects':
#> data frame with 0 columns and 0 rows

redmine_users()
#> redmineR listing for 'users':
#>   id          login firstname lastname             mail
#> 1  2 redmineR-admin   Redmine    Admin demo@example.net
#>             created_on        last_login_on
#> 1 2017-07-04T23:43:05Z 2017-07-04T23:43:34Z
```

### Create a new project

``` r
(newProjectId <- redmine_create_project(name = "testProject",
    identifier = "test-project", description = "project to testthings",
    enabled_module_names = c("files", "issue_tracking", "repository", 
        "time_tracking", "wiki")))
#> [1] 10

# trivial update
redmine_update_project(newProjectId, description = "project to test things")
```

### List projects again

``` r
redmine_projects()
#> redmineR listing for 'projects':
#>   id        name   identifier              description status
#> 1 10 testProject test-project project to test thin ...      1
#>             created_on           updated_on
#> 1 2017-07-05T01:27:15Z 2017-07-05T01:27:15Z
```

or:

``` r
redmine_list_projects()
#> redmineR API call: http://rredmine.m.redmine.org/projects.json 
#> List of 4
#>  $ projects   :List of 1
#>   ..$ :List of 7
#>   .. ..$ id         : int 10
#>   .. ..$ name       : chr "testProject"
#>   .. ..$ identifier : chr "test-project"
#>   .. ..$ description: chr "project to test things"
#>   .. ..$ status     : int 1
#>   .. ..$ created_on : chr "2017-07-05T01:27:15Z"
#>   .. ..$ updated_on : chr "2017-07-05T01:27:15Z"
#>  $ total_count: int 1
#>  $ offset     : int 0
#>  $ limit      : int 25
```

### Create an issue

``` r
projectID <- redmine_search_id("testProject", 
    endpoint = "projects")
#> redmineR listing for 'projects':
#>   id        name   identifier              description status
#> 1 10 testProject test-project project to test thin ...      1
#>             created_on           updated_on
#> 1 2017-07-05T01:27:15Z 2017-07-05T01:27:15Z

# now create issue
issueID <- redmine_create_issue(
    project_id = projectID, 
    subject = "test task", 
    description = "test description"
)
```

### See its details

``` r
redmine_show_issue(issueID, include = "all")
#> redmineR API call: http://rredmine.m.redmine.org/issues/7.json?include=children,attachments,relations,changesets,journals,watchers 
#> List of 1
#>  $ issue:List of 17
#>   ..$ id         : int 7
#>   ..$ project    :List of 2
#>   .. ..$ id  : int 10
#>   .. ..$ name: chr "testProject"
#>   ..$ tracker    :List of 2
#>   .. ..$ id  : int 1
#>   .. ..$ name: chr "Bug"
#>   ..$ status     :List of 2
#>   .. ..$ id  : int 1
#>   .. ..$ name: chr "New"
#>   ..$ priority   :List of 2
#>   .. ..$ id  : int 2
#>   .. ..$ name: chr "Normal"
#>   ..$ author     :List of 2
#>   .. ..$ id  : int 2
#>   .. ..$ name: chr "Redmine Admin"
#>   ..$ subject    : chr "test task"
#>   ..$ description: chr "test description"
#>   ..$ start_date : chr "2017-07-05"
#>   ..$ done_ratio : int 0
#>   ..$ spent_hours: num 0
#>   ..$ created_on : chr "2017-07-05T01:27:15Z"
#>   ..$ updated_on : chr "2017-07-05T01:27:15Z"
#>   ..$ attachments: list()
#>   ..$ changesets : list()
#>   ..$ journals   : list()
#>   ..$ watchers   : list()
```

### Clean up

``` r
redmine_delete_issue(issueID)
redmine_delete_project(projectID)
```
