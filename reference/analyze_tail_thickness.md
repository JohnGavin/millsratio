# Analyze Tail Thickness at Specific Points

Analyze Tail Thickness at Specific Points

## Usage

``` r
analyze_tail_thickness(
  x_points,
  distributions = c("normal", "t30", "exponential"),
  compute_ratios = FALSE
)
```

## Arguments

- x_points:

  Numeric vector of x values to analyze

- distributions:

  Character vector of distributions

- compute_ratios:

  Logical; if TRUE, computes ratios relative to normal

## Value

Data frame with Mills ratios and optional comparison metrics

## Examples

``` r
# Analyze at key points
tail_analysis <- analyze_tail_thickness(
  x_points = c(2, 3, 4, 5),
  distributions = c("normal", "t30", "exponential"),
  compute_ratios = TRUE
)
```
