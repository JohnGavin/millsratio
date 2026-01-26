# Visualization Functions for Mills Ratio Analysis

Functions to create static and interactive visualizations of Mills
ratios, supporting both ggplot2 and plotly outputs.

## Usage

``` r
plot_mills_curves(
  data,
  log_y = FALSE,
  log_x = FALSE,
  interactive = FALSE,
  title = "Mills Ratio Comparison",
  show_asymptotic = TRUE
)
```

## Arguments

- data:

  Data frame from simulate_mills_curves()

- log_y:

  Logical; if TRUE, uses log scale for y-axis

- log_x:

  Logical; if TRUE, uses log scale for x-axis

- interactive:

  Logical; if TRUE, returns plotly object

- title:

  Plot title

- show_asymptotic:

  Logical; if TRUE, shows asymptotic approximations

## Value

ggplot2 or plotly object

## Author

John Gavin <john.b.gavin@gmail.com> Plot Mills Ratio Curves

## Examples

``` r
# Generate and plot Mills ratio curves
curves <- simulate_mills_curves(distributions = c("normal", "t30", "exponential"))
plot_mills_curves(curves, log_y = TRUE)
```
