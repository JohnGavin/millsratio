# Compute Mills Ratio for Student's t Distribution

Compute Mills Ratio for Student's t Distribution

## Usage

``` r
mills_ratio_t(x, df, log = FALSE)
```

## Arguments

- x:

  Numeric vector of quantiles

- df:

  Degrees of freedom (\> 0)

- log:

  Logical; if TRUE, returns log(Mills ratio)

## Value

Numeric vector of Mills ratios

## Examples

``` r
# t-distribution with df = 30 at x = 2
mills_ratio_t(2, df = 30)
#> [1] 0.4804121

# Compare different degrees of freedom
x_vals <- seq(0, 5, by = 0.5)
m_t3 <- mills_ratio_t(x_vals, df = 3)
m_t30 <- mills_ratio_t(x_vals, df = 30)
```
