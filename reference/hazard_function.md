# Calculate Hazard Function Directly

Calculate Hazard Function Directly

## Usage

``` r
hazard_function(x, distribution = "normal", ...)
```

## Arguments

- x:

  Numeric vector of values

- distribution:

  Character string: "normal", "t", "exponential"

- ...:

  Additional parameters for the distribution

## Value

Numeric vector of hazard function values

## Examples

``` r
# Compare hazard functions across distributions
x <- seq(0.1, 5, by = 0.1)
h_normal <- hazard_function(x, "normal")
h_t30 <- hazard_function(x, "t", df = 30)
h_exp <- hazard_function(x, "exponential", rate = 1)

# Tidyverse comparison
library(dplyr)
library(tidyr)
data.frame(x = x) %>%
  mutate(
    Normal = hazard_function(x, "normal"),
    `t(30)` = hazard_function(x, "t", df = 30),
    Exponential = hazard_function(x, "exponential")
  ) %>%
  pivot_longer(-x, names_to = "distribution", values_to = "hazard")
#> # A tibble: 150 × 3
#>        x distribution hazard
#>    <dbl> <chr>         <dbl>
#>  1   0.1 Normal        0.863
#>  2   0.1 t(30)         0.855
#>  3   0.1 Exponential   1    
#>  4   0.2 Normal        0.929
#>  5   0.2 t(30)         0.920
#>  6   0.2 Exponential   1    
#>  7   0.3 Normal        0.998
#>  8   0.3 t(30)         0.986
#>  9   0.3 Exponential   1    
#> 10   0.4 Normal        1.07 
#> # ℹ 140 more rows
```
