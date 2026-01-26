# Find Crossover Points Between Distributions

Find Crossover Points Between Distributions

## Usage

``` r
find_crossover_point(
  dist1,
  dist2,
  df1 = NULL,
  df2 = NULL,
  x_range = c(0.01, 10),
  tolerance = 1e-06
)
```

## Arguments

- dist1:

  First distribution

- dist2:

  Second distribution

- df1:

  Degrees of freedom for first distribution (if t)

- df2:

  Degrees of freedom for second distribution (if t)

- x_range:

  Search range for crossover

- tolerance:

  Numerical tolerance for finding crossover

## Value

Numeric value of x where Mills ratios are equal (NA if no crossover)

## Examples

``` r
# Find where t(30) and normal Mills ratios cross
crossover <- find_crossover_point("t", "normal", df1 = 30)
```
