# Simulation Framework for Mills Ratio Analysis

Functions to generate and compare Mills ratio curves across
distributions, supporting the interactive dashboard and analysis
vignettes.

## Usage

``` r
simulate_mills_curves(
  x_range = c(0.5, 5),
  n_points = 100,
  distributions = c("normal", "t30", "exponential"),
  log_scale = FALSE,
  include_asymptotic = FALSE
)
```

## Arguments

- x_range:

  Numeric vector of two elements: c(min, max)

- n_points:

  Number of points to evaluate (default = 100)

- distributions:

  Character vector of distributions to include

- log_scale:

  Logical; if TRUE, uses log-spaced x values

- include_asymptotic:

  Logical; if TRUE, includes asymptotic approximations

## Value

Data frame in long format suitable for plotting

## Author

John Gavin <john.b.gavin@gmail.com> Generate Mills Ratio Curves

## Examples

``` r
# Generate curves for comparison
curves <- simulate_mills_curves(
  x_range = c(0.5, 5),
  distributions = c("normal", "t3", "t30", "exponential")
)
```
