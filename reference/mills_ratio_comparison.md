# Compute Ratio of Mills Ratios

Compute Ratio of Mills Ratios

## Usage

``` r
mills_ratio_comparison(x, dist1, dist2, df1 = NULL, df2 = NULL)
```

## Arguments

- x:

  Numeric vector of quantiles

- dist1:

  First distribution ("normal", "t", "exponential")

- dist2:

  Second distribution ("normal", "t", "exponential")

- df1:

  Degrees of freedom for first distribution (if t)

- df2:

  Degrees of freedom for second distribution (if t)

## Value

Numeric vector of ratios m1(x)/m2(x)

## Examples

``` r
# Ratio of t(30) to normal Mills ratios
x_vals <- seq(1, 5, by = 0.5)
ratio <- mills_ratio_comparison(x_vals, "t", "normal", df1 = 30)
```
