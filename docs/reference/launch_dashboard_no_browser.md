# Launch Dashboard Without Browser

Convenience function to launch dashboard without attempting to open
browser. Useful when browser settings are not configured.

## Usage

``` r
launch_dashboard_no_browser(port = NULL, host = "127.0.0.1")
```

## Arguments

- port:

  Port number for the Shiny app (default = NULL for auto-selection)

- host:

  Host address (default = "127.0.0.1" for local access)

## Value

Runs the Shiny application

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch without browser
launch_dashboard_no_browser()
# Then manually open the displayed URL in your browser
} # }
```
