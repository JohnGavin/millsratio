# millsratio: Interactive Analysis of Mills Ratios and Tail Thickness

## Overview

The `millsratio` package provides tools for computing and visualizing Mills ratios across different probability distributions. It includes an interactive dashboard for exploring how Mills ratios reveal fundamental differences between distribution tails, particularly highlighting the t(30) paradox where distributions appear similar centrally but diverge substantially in the tails.

This package implements and extends concepts from [John D. Cook's blog post on Mills ratios](https://www.johndcook.com/blog/2026/01/21/mills-ratio/).

## Key Concepts

The Mills ratio is defined as:
```
m(x) = [1 - F(x)] / f(x)
```
where F(x) is the CDF and f(x) is the PDF.

### What Mills Ratios Reveal:
- **Decreasing Mills ratio** → Thin tails (e.g., Normal: m(x) ~ 1/x)
- **Increasing Mills ratio** → Fat tails (e.g., t-distribution: m(x) ~ x/df)
- **Constant Mills ratio** → Exponential tails (e.g., Exponential: m(x) = 1/rate)

## Installation

```r
# Install from local directory (development)
devtools::install("path/to/millsratio")

# Load the package
library(millsratio)
```

## Quick Start

### Launch Interactive Dashboard

```r
# Launch the interactive dashboard
launch_dashboard()
```

The dashboard provides:
- 12 interactive pages organized into Analysis, Theory, and Playground sections
- Real-time visualization of Mills ratios
- Comparison tools for multiple distributions
- The t(30) paradox demonstration
- Custom code playground for experiments

### Basic Usage

```r
# Calculate Mills ratio for normal distribution
x <- seq(1, 5, by = 0.5)
m_normal <- mills_ratio_normal(x)

# Calculate for t-distribution
m_t30 <- mills_ratio_t(x, df = 30)

# Compare distributions
comparison <- compare_mills_ratios(x, c("normal", "t30", "exponential"))
print(comparison)

# Visualize the comparison
library(ggplot2)
curves <- simulate_mills_curves(
  x_range = c(0.5, 5),
  distributions = c("normal", "t30", "exponential")
)
plot_mills_curves(curves, log_y = TRUE)
```

### The t(30) Paradox

```r
# Analyze the t(30) paradox
paradox_data <- analyze_t30_paradox()

# Visualize the paradox
plot_t30_paradox(paradox_data, focus = "mills")

# Show how t(30) diverges from normal in the tails
x_vals <- c(1, 2, 3, 4, 5)
ratio <- mills_ratio_t(x_vals, df = 30) / mills_ratio_normal(x_vals)
print(ratio)  # Shows increasing divergence
```

## Main Functions

### Core Mills Ratio Functions
- `mills_ratio_normal()` - Mills ratio for normal distribution
- `mills_ratio_t()` - Mills ratio for Student's t distribution
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

## Dashboard Features

### Analysis Section
1. **Normal Distribution Explorer** - Interactive exploration with asymptotic approximations
2. **Student's t Comparison** - Animate through different degrees of freedom
3. **Distribution Battle Arena** - Side-by-side comparisons
4. **Tail Thickness Analyzer** - Heatmap visualization of tail behavior
5. **t(30) Paradox** - Deep dive into the paradox

### Theory Section
6. **Living Definitions** - Interactive mathematical concepts
7. **Asymptotic Playground** - Explore approximation accuracy

### Playground Section
8. **Custom Analysis** - Write and run your own R code
9. **Quick Reference** - Function reference and code templates

## Mathematical Background

### Asymptotic Behavior

| Distribution | Mills Ratio Behavior | Tail Type |
|-------------|---------------------|-----------|
| Normal | m(x) ~ 1/x as x→∞ | Thin |
| Student t(df) | m(x) ~ x/df as x→∞ | Fat |
| Exponential | m(x) = 1/rate (constant) | Medium |

### The t(30) Paradox

The t(30) distribution is often considered "practically normal" for many applications. However:
- **Central region**: Nearly indistinguishable from normal
- **Tail region**: Substantially different Mills ratios
- **Implication**: Risk models based on normality assumptions may severely underestimate tail probabilities

## Examples

### Example 1: Verify Mills Ratio Properties

```r
# Verify that normal has decreasing Mills ratio (thin tails)
x <- seq(1, 5, by = 0.5)
m <- mills_ratio_normal(x)
all(diff(m) < 0)  # TRUE

# Verify that t(3) has increasing Mills ratio (fat tails)
m_t <- mills_ratio_t(x, df = 3)
all(diff(m_t) > 0)  # TRUE

# Verify exponential has constant Mills ratio
m_exp <- mills_ratio_exp(x)
all(abs(diff(m_exp)) < 1e-10)  # TRUE
```

### Example 2: Interactive Exploration

```r
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

```r
# Verify Mills ratio empirically
set.seed(123)
mc_result <- monte_carlo_mills(
  n_sim = 10000,
  x_val = 2,
  distribution = "normal"
)

cat("Empirical Mills ratio:", mc_result$empirical_mills, "\n")
cat("True Mills ratio:", mc_result$true_mills, "\n")
cat("Relative error:", mc_result$relative_error, "\n")
```

## Testing

Run the test suite:

```r
devtools::test()
```

Check package:

```r
devtools::check()
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License

## Author

John Gavin <john.b.gavin@gmail.com>

Implementation support: Claude Assistant

## References

- Cook, J. D. (2026). "Mills Ratio and Tail Thickness." [Blog post](https://www.johndcook.com/blog/2026/01/21/mills-ratio/)
- Mills, J. P. (1926). "Table of the ratio: Area to bounding ordinate, for any portion of normal curve." Biometrika, 18(3/4), 395-400.

## Citation

If you use this package in your research, please cite:

```
@software{millsratio2026,
  author = {Gavin, John},
  title = {millsratio: Interactive Analysis of Mills Ratios and Tail Thickness},
  year = {2026},
  url = {https://github.com/yourusername/millsratio}
}
```