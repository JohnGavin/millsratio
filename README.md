# millsratio: Interactive Analysis of Mills Ratios and Tail Thickness


## Overview

The `millsratio` package provides tools for computing and visualizing
Mills ratios across different probability distributions. It includes an
interactive dashboard for exploring how Mills ratios reveal fundamental
differences between distribution tails, particularly highlighting the
t(30) paradox where distributions appear similar centrally but diverge
substantially in the tails.

This package implements and extends concepts from [John D. Cook’s blog
post on Mills
ratios](https://www.johndcook.com/blog/2026/01/21/mills-ratio/).

## Key Concepts

The Mills ratio is defined as:

    m(x) = [1 - F(x)] / f(x)

where F(x) is the CDF and f(x) is the PDF.

### What Mills Ratios Reveal:

- **Decreasing Mills ratio** → Thin tails (e.g., Normal: m(x) ~ 1/x)
- **Increasing Mills ratio** → Fat tails (e.g., t-distribution: m(x) ~
  x/df)
- **Constant Mills ratio** → Exponential tails (e.g., Exponential: m(x)
  = 1/rate)

## Installation

### From GitHub (Standard R)

``` r
# Install development version from GitHub
remotes::install_github("JohnGavin/millsratio")

# Load the package
library(millsratio)
```

### From Nix (Reproducible Environment)

For a fully reproducible environment with all dependencies:

``` bash
# Clone and use the project's Nix shell
git clone https://github.com/JohnGavin/millsratio.git
cd millsratio

# Enter Nix shell with GC root (creates default.nix automatically)
chmod +x default.sh
./default.sh  # First run: builds environment, subsequent runs: fast

# Now in Nix shell, R has all dependencies
R
> library(millsratio)
```

### Using with rix

For integration with existing R projects:

``` r
library(rix)
rix(
  r_ver = "4.5.0",
  r_pkgs = c("tidyverse", "plotly", "shiny"),
  git_pkgs = list(
    millsratio = "JohnGavin/millsratio"
  ),
  ide = "code",
  project_path = "."
)
# Then: nix-shell
```

## Quick Start

### Launch Interactive Dashboard

``` r
# Launch the interactive dashboard
launch_dashboard()
```

The dashboard provides: - 12 interactive pages organized into Analysis,
Theory, and Playground sections - Real-time visualization of Mills
ratios - Comparison tools for multiple distributions - The t(30) paradox
demonstration - Custom code playground for experiments

### Basic Usage

``` r
# Calculate Mills ratio for normal distribution
x <- seq(1, 5, by = 0.5)
m_normal <- mills_ratio_normal(x)
print(round(m_normal, 3))

# Calculate for t-distribution
m_t30 <- mills_ratio_t(x, df = 30)
print(round(m_t30, 3))

# Compare distributions
x_compare <- c(1, 2, 3, 4)
comparison <- compare_mills_ratios(x_compare, c("normal", "t30", "exponential"))
print(comparison)
```

### Visualize the Comparison

``` r
# Generate curves for visualization
curves <- simulate_mills_curves(
  x_range = c(0.5, 5),
  distributions = c("normal", "t30", "exponential")
)

# Create plot
plot_mills_curves(curves, log_y = TRUE)
```

### The t(30) Paradox

``` r
# Analyze the t(30) paradox
paradox_data <- analyze_t30_paradox(x_range = c(0, 5), n_points = 100)

# Show how t(30) diverges from normal in the tails
x_vals <- c(1, 2, 3, 4, 5)
ratio <- mills_ratio_t(x_vals, df = 30) / mills_ratio_normal(x_vals)
cat("t(30)/Normal Mills ratio divergence:\n")
for (i in seq_along(x_vals)) {
  cat(sprintf("x = %d: ratio = %.3f\n", x_vals[i], ratio[i]))
}
```

``` r
# Visualize the paradox
plot_t30_paradox(paradox_data, focus = "mills")
```

## Main Functions

### Core Mills Ratio Functions

- `mills_ratio_normal()` - Mills ratio for normal distribution
- `mills_ratio_t()` - Mills ratio for Student’s t distribution
- `mills_ratio_exp()` - Mills ratio for exponential distribution
- `mills_ratio_generic()` - Generic Mills ratio for any distribution

### Analysis Functions

- `compare_mills_ratios()` - Compare Mills ratios across distributions
- `mills_asymptotic()` - Calculate asymptotic approximations
- `mills_ratio_comparison()` - Compute ratios between distributions
- `find_crossover_point()` - Find where two Mills ratios intersect

### Simulation Functions

- `simulate_mills_curves()` - Generate Mills ratio curves for plotting
- `analyze_tail_thickness()` - Analyze tail thickness at specific points
- `analyze_t30_paradox()` - Comprehensive t(30) vs normal comparison
- `monte_carlo_mills()` - Monte Carlo verification of Mills ratios

### Visualization Functions

- `plot_mills_curves()` - Plot Mills ratio curves
- `plot_tail_thickness_heatmap()` - Create heatmap of tail thickness
- `plot_t30_paradox()` - Visualize the t(30) paradox
- `plot_mills_comparison()` - Compare two distributions

### Dashboard

- `launch_dashboard()` - Launch interactive Shiny dashboard

## Mathematical Background

### Asymptotic Behavior

| Distribution  | Mills Ratio Behavior     | Tail Type |
|---------------|--------------------------|-----------|
| Normal        | m(x) ~ 1/x as x→∞        | Thin      |
| Student t(df) | m(x) ~ x/df as x→∞       | Fat       |
| Exponential   | m(x) = 1/rate (constant) | Medium    |

### The t(30) Paradox

The t(30) distribution is often considered “practically normal” for many
applications. However: - **Central region**: Nearly indistinguishable
from normal - **Tail region**: Substantially different Mills ratios -
**Implication**: Risk models based on normality assumptions may severely
underestimate tail probabilities

## Examples

### Example 1: Verify Mills Ratio Properties

``` r
# Verify that normal has decreasing Mills ratio (thin tails)
x <- seq(1, 5, by = 0.5)
m <- mills_ratio_normal(x)
cat("Normal Mills ratio decreasing:", all(diff(m) < 0), "\n")

# Verify that t(3) has increasing Mills ratio (fat tails)
m_t <- mills_ratio_t(x, df = 3)
cat("t(3) Mills ratio increasing:", all(diff(m_t) > 0), "\n")

# Verify exponential has constant Mills ratio
m_exp <- mills_ratio_exp(x)
cat("Exponential Mills ratio constant:", all(abs(diff(m_exp)) < 1e-10), "\n")
```

### Example 2: Interactive Exploration

``` r
# Generate interactive plot
library(plotly)
curves <- simulate_mills_curves(
  x_range = c(0.1, 10),
  distributions = c("normal", "t3", "t10", "t30"),
  log_scale = TRUE
)

p <- plot_mills_curves(curves, log_y = TRUE, interactive = TRUE)
p  # Opens interactive plotly visualization
```

### Example 3: Monte Carlo Verification

``` r
# Verify Mills ratio empirically
set.seed(123)
mc_result <- monte_carlo_mills(
  n_sim = 10000,
  x_val = 2,
  distribution = "normal"
)

cat("Empirical Mills ratio:", round(mc_result$empirical_mills, 4), "\n")
cat("True Mills ratio:", round(mc_result$true_mills, 4), "\n")
cat("Relative error:", round(mc_result$relative_error, 4), "\n")
```

## Testing

Run the test suite:

``` r
devtools::test()
```

Check package:

``` r
devtools::check()
```

## Reproducible Pipeline

This package uses `targets` to ensure all examples are tested:

``` r
# Run the pipeline to test all examples
targets::tar_make()

# View the pipeline
targets::tar_visnetwork()
```

## License

MIT License

## Author

John Gavin <john.b.gavin@gmail.com>

Implementation support: Claude Assistant

## References

- Cook, J. D. (2026). “Mills Ratio and Tail Thickness.” [Blog
  post](https://www.johndcook.com/blog/2026/01/21/mills-ratio/)
- Mills, J. P. (1926). “Table of the ratio: Area to bounding ordinate,
  for any portion of normal curve.” Biometrika, 18(3/4), 395-400.

## Project Structure

## Citation

If you use this package in your research, please cite:

    @software{millsratio2026,
      author = {Gavin, John},
      title = {millsratio: Interactive Analysis of Mills Ratios and Tail Thickness},
      year = {2026},
      url = {https://github.com/yourusername/millsratio}
    }
