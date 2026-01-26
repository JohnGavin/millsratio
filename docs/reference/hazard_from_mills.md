# Convert Mills Ratio to Hazard Function

Convert Mills Ratio to Hazard Function

## Usage

``` r
hazard_from_mills(mills_ratio)
```

## Arguments

- mills_ratio:

  Numeric vector of Mills ratio values

## Value

Numeric vector of hazard function values

## Examples

``` r
# Normal distribution example
x <- seq(0, 5, by = 0.5)
m <- mills_ratio_normal(x)
h <- hazard_from_mills(m)

# Tidyverse example
library(dplyr)
data.frame(x = x) %>%
  mutate(
    mills = mills_ratio_normal(x),
    hazard = hazard_from_mills(mills)
  )
#>      x     mills    hazard
#> 1  0.0 1.2533141 0.7978846
#> 2  0.5 0.8763645 1.1410778
#> 3  1.0 0.6556795 1.5251353
#> 4  1.5 0.5158156 1.9386772
#> 5  2.0 0.4213692 2.3732155
#> 6  2.5 0.3542651 2.8227448
#> 7  3.0 0.3045903 3.2830987
#> 8  3.5 0.2665678 3.7513913
#> 9  4.0 0.2366524 4.2256071
#> 10 4.5 0.2125706 4.7043198
#> 11 5.0 0.1928081 5.1865040
```
