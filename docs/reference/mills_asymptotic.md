# Calculate Asymptotic Approximation of Mills Ratio

Calculate Asymptotic Approximation of Mills Ratio

## Usage

``` r
mills_asymptotic(x, distribution, df = NULL)
```

## Arguments

- x:

  Numeric vector of quantiles

- distribution:

  Character string: "normal", "t", or "exponential"

- df:

  Degrees of freedom for t-distribution

## Value

Numeric vector of asymptotic approximations

## Examples

``` r
# Normal asymptotic approximation (1/x for large x)
mills_asymptotic(10, "normal")
#> [1] 0.1

# Student's t asymptotic approximation (x/df for large x)
mills_asymptotic(10, "t", df = 30)
#> [1] 0.3333333
```
