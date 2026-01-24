# Compare Mills Ratios Across Distributions

Compare Mills Ratios Across Distributions

## Usage

``` r
compare_mills_ratios(x, distributions = c("normal", "t30", "exponential"))
```

## Arguments

- x:

  Numeric vector of quantiles

- distributions:

  Character vector of distribution names ("normal", "t3", "t10", "t30",
  "exponential")

## Value

Data frame with Mills ratios for each distribution

## Examples

``` r
x_vals <- c(1, 2, 3, 4)
compare_mills_ratios(x_vals, c("normal", "t30", "exponential"))
#>   x    normal    t_df30 exponential
#> 1 1 0.6556795 0.6834406           1
#> 2 2 0.4213692 0.4804121           1
#> 3 3 0.3045903 0.3975449           1
#> 4 4 0.2366524 0.3638590           1
```
