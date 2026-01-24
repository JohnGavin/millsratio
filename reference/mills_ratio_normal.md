# Mills Ratio Functions for Various Distributions

Functions to compute Mills ratios for different probability
distributions. The Mills ratio m(x) is defined as the ratio of the
complementary cumulative distribution function (CCDF) to the probability
density function (PDF): m(x) = 1 - F(x) / f(x)

## Usage

``` r
mills_ratio_normal(x, mean = 0, sd = 1, log = FALSE)
```

## Arguments

- x:

  Numeric vector of quantiles

- mean:

  Mean of the distribution (default = 0)

- sd:

  Standard deviation (default = 1)

- log:

  Logical; if TRUE, returns log(Mills ratio) for numerical stability

## Value

Numeric vector of Mills ratios

## Author

John Gavin <john.b.gavin@gmail.com> Compute Mills Ratio for Normal
Distribution

## Examples

``` r
# Standard normal Mills ratio at x = 2
mills_ratio_normal(2)
#> [1] 0.4213692

# Multiple values
mills_ratio_normal(c(1, 2, 3, 4))
#> [1] 0.6556795 0.4213692 0.3045903 0.2366524

# Log Mills ratio for extreme values
mills_ratio_normal(10, log = TRUE)
#> [1] -2.312347
```
