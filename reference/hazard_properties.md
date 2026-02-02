# Hazard Function Properties

Analyze properties of the hazard function for different distributions.

## Usage

``` r
hazard_properties(distribution = "normal", df = NULL)
```

## Arguments

- distribution:

  Character string: "normal", "t", or "exponential"

- df:

  Degrees of freedom for t-distribution

## Value

List with hazard function properties

## Examples

``` r
# Analyze normal distribution hazard
hazard_properties("normal")
#> $distribution
#> [1] "normal"
#> 
#> $behavior
#> [1] "Increasing (IFR - Increasing Failure Rate)"
#> 
#> $asymptotic_behavior
#> [1] "h(x) ~ x as x -> Inf"
#> 
#> $interpretation
#> [1] "Aging effect - failure rate increases with x"
#> 

# Compare properties across distributions
library(purrr)
list(
  normal = hazard_properties("normal"),
  t30 = hazard_properties("t", df = 30),
  exponential = hazard_properties("exponential")
) %>%
  map_df(~ as.data.frame(.x), .id = "distribution")
#>   distribution                                   behavior
#> 1       normal Increasing (IFR - Increasing Failure Rate)
#> 2          t30                              Non-monotonic
#> 3  exponential     Constant (CFR - Constant Failure Rate)
#>          asymptotic_behavior                                  interpretation
#> 1       h(x) ~ x as x -> Inf    Aging effect - failure rate increases with x
#> 2 h(x) ~ 31/30/x as x -> Inf Heavy tails - lower hazard than normal in tails
#> 3            h(x) = constant              Memoryless - constant failure rate
```
