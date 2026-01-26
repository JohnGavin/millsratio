# Launch Mills Ratio Interactive Dashboard

Launches an interactive Shiny dashboard for exploring Mills ratios and
tail thickness behavior across different distributions.

## Usage

``` r
launch_dashboard(port = NULL, launch_browser = TRUE, host = "127.0.0.1")
```

## Arguments

- port:

  Port number for the Shiny app (default = NULL for auto-selection)

- launch_browser:

  Logical; if TRUE, opens dashboard in browser

- host:

  Host address (default = "127.0.0.1" for local access)

## Value

Runs the Shiny application

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch the dashboard
launch_dashboard()

# Launch on specific port
launch_dashboard(port = 8080)
} # }
```
