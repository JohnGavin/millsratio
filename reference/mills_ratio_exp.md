# Compute Mills Ratio for Exponential Distribution

Compute Mills Ratio for Exponential Distribution

## Usage

``` r
mills_ratio_exp(x, rate = 1, log = FALSE)
```

## Arguments

- x:

  Numeric vector of quantiles

- rate:

  Rate parameter (\> 0)

- log:

  Logical; if TRUE, returns log(Mills ratio)

## Value

Numeric vector of Mills ratios

## Examples

``` r
# Exponential with rate = 1 at x = 2
mills_ratio_exp(2, rate = 1)
#> [1] 1

# Mills ratio is constant for exponential!
mills_ratio_exp(c(1, 2, 3, 4), rate = 1)
#> [1] 1 1 1 1
```
