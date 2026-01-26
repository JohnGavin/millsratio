# Plot t(30) Paradox Visualization

Plot t(30) Paradox Visualization

## Usage

``` r
plot_t30_paradox(data, focus = "mills", interactive = FALSE)
```

## Arguments

- data:

  Data frame from analyze_t30_paradox()

- focus:

  Character: "mills", "pdf", "cdf", or "all"

- interactive:

  Logical; if TRUE, returns plotly object

## Value

ggplot2 or plotly object

## Examples

``` r
paradox_data <- analyze_t30_paradox()
plot_t30_paradox(paradox_data, focus = "mills")
```
