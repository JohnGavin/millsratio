# Launch Simplified Dashboard

Launch the simplified, content-focused version of the Mills ratio
dashboard. This version emphasizes clarity and substance over visual
effects.

## Usage

``` r
launch_dashboard_simple(
  port = 4628,
  launch_browser = FALSE,
  host = "127.0.0.1"
)
```

## Arguments

- port:

  Port number for the Shiny app (default = 4628)

- launch_browser:

  Launch browser? (default = FALSE)

- host:

  Host address (default = "127.0.0.1" for local access)

## Value

Runs the simplified Shiny application

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch simplified dashboard
launch_dashboard_simple()
} # }
```
