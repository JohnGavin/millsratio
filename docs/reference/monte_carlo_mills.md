# Monte Carlo Simulation for Mills Ratio Estimation

Monte Carlo Simulation for Mills Ratio Estimation

## Usage

``` r
monte_carlo_mills(
  n_sim = 10000,
  x_val = 2,
  distribution = "normal",
  df = NULL,
  seed = NULL
)
```

## Arguments

- n_sim:

  Number of simulations

- x_val:

  Value at which to estimate Mills ratio

- distribution:

  Distribution to sample from

- df:

  Degrees of freedom (for t-distribution)

- seed:

  Random seed for reproducibility

## Value

List with empirical Mills ratio estimate and confidence interval

## Examples

``` r
# Empirically verify Mills ratio for normal at x=2
mc_result <- monte_carlo_mills(n_sim = 10000, x_val = 2, distribution = "normal")
```
