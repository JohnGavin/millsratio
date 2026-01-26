# Generic Mills Ratio Function

Generic Mills Ratio Function

## Usage

``` r
mills_ratio_generic(x, cdf_fun, pdf_fun, log = FALSE, ...)
```

## Arguments

- x:

  Numeric vector of quantiles

- cdf_fun:

  CDF function (must accept lower.tail and log.p arguments)

- pdf_fun:

  PDF function (must accept log argument)

- log:

  Logical; if TRUE, returns log(Mills ratio)

- ...:

  Additional arguments passed to cdf_fun and pdf_fun

## Value

Numeric vector of Mills ratios

## Examples

``` r
# Using generic function for normal distribution
mills_ratio_generic(2, cdf_fun = pnorm, pdf_fun = dnorm)
#> [1] 0.4213692

# Using for custom distribution
# mills_ratio_generic(x, cdf_fun = my_cdf, pdf_fun = my_pdf, param1 = value1)
```
