# Mills Ratio and Hazard Function Connection

Show code

``` r
devtools::load_all()  # Load development version
library(tidyverse)
library(plotly)
# library(gt)  # Replaced with knitr::kable()
```

## Mathematical Relationship

The Mills ratio and hazard function are reciprocals of each other:

``` math
h(x) = \frac{f(x)}{1 - F(x)} = \frac{1}{m(x)}
```

This fundamental relationship connects two important concepts:

- **Mills ratio** $`m(x)`$: Used in statistics and economics to measure
  tail thickness
- **Hazard function** $`h(x)`$: Used in survival analysis and
  reliability engineering

## Tidyverse Implementation

### Calculate Both Functions

Show code

``` r
# Create data frame with both functions
df <- tibble(x = seq(0.1, 5, by = 0.1)) %>%
  mutate(
    # Mills ratio calculation
    mills_ratio = mills_ratio_normal(x),

    # Hazard function - two equivalent methods
    hazard_method1 = 1 / mills_ratio,
    hazard_method2 = dnorm(x) / pnorm(x, lower.tail = FALSE)
  ) %>%
  mutate(
    # Verify they're equal
    methods_equal = near(hazard_method1, hazard_method2)
  )

# Display first few rows
df %>%
  head(10) %>%
  knitr::kable(
    digits = 4,
    caption = "Mills Ratio vs Hazard Function"
  )
```

|   x | mills_ratio | hazard_method1 | hazard_method2 | methods_equal |
|----:|------------:|---------------:|---------------:|:--------------|
| 0.1 |      1.1593 |         0.8626 |         0.8626 | TRUE          |
| 0.2 |      1.0759 |         0.9294 |         0.9294 | TRUE          |
| 0.3 |      1.0018 |         0.9982 |         0.9982 | TRUE          |
| 0.4 |      0.9357 |         1.0688 |         1.0688 | TRUE          |
| 0.5 |      0.8764 |         1.1411 |         1.1411 | TRUE          |
| 0.6 |      0.8230 |         1.2150 |         1.2150 | TRUE          |
| 0.7 |      0.7749 |         1.2905 |         1.2905 | TRUE          |
| 0.8 |      0.7313 |         1.3674 |         1.3674 | TRUE          |
| 0.9 |      0.6917 |         1.4456 |         1.4456 | TRUE          |
| 1.0 |      0.6557 |         1.5251 |         1.5251 | TRUE          |

Mills Ratio vs Hazard Function

### Visualize the Relationship

Show code

``` r
# Prepare data for plotting
plot_data <- df %>%
  select(x, mills_ratio, hazard = hazard_method1) %>%
  pivot_longer(-x, names_to = "function_type", values_to = "value")

# Create interactive plot
p <- plot_data %>%
  ggplot(aes(x, value, color = function_type)) +
  geom_line(size = 1.2) +
  scale_y_log10() +
  labs(
    title = "Mills Ratio and Hazard Function for Normal Distribution",
    subtitle = "Note: h(x) = 1/m(x)",
    x = "x",
    y = "Value (log scale)",
    color = "Function"
  ) +
  theme_minimal() +
  scale_color_manual(
    values = c("mills_ratio" = "#2c3e50", "hazard" = "#e74c3c"),
    labels = c("mills_ratio" = "Mills Ratio m(x)", "hazard" = "Hazard h(x)")
  )
```

    Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
    ℹ Please use `linewidth` instead.

Show code

``` r
 ggplotly(p)
```

## Compare Across Distributions

Show code

``` r
# Calculate for multiple distributions
comparison <- expand_grid(
  x = seq(0.1, 5, by = 0.2),
  distribution = c("Normal", "t(3)", "t(30)", "Exponential")
) %>%
  mutate(
    mills_ratio = case_when(
      distribution == "Normal" ~ mills_ratio_normal(x),
      distribution == "t(3)" ~ mills_ratio_t(x, df = 3),
      distribution == "t(30)" ~ mills_ratio_t(x, df = 30),
      distribution == "Exponential" ~ mills_ratio_exp(x)
    ),
    hazard = 1 / mills_ratio
  )

# Plot comparison
p_compare <- comparison %>%
  ggplot(aes(x, hazard, color = distribution)) +
  geom_line(size = 1) +
  scale_y_log10() +
  facet_wrap(~distribution, scales = "free_y") +
  labs(
    title = "Hazard Functions Across Distributions",
    x = "x",
    y = "Hazard h(x) (log scale)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggplotly(p_compare)
```

## Hazard Function Properties

Show code

``` r
# Analyze hazard behavior for each distribution
hazard_analysis <- comparison %>%
  group_by(distribution) %>%
  arrange(x) %>%
  mutate(
    hazard_diff = hazard - lag(hazard),
    is_increasing = hazard_diff > 0
  ) %>%
  summarize(
    min_hazard = min(hazard),
    max_hazard = max(hazard),
    all_increasing = all(is_increasing, na.rm = TRUE),
    all_decreasing = all(!is_increasing, na.rm = TRUE),
    behavior = case_when(
      all_increasing ~ "Increasing (IFR)",
      all_decreasing ~ "Decreasing (DFR)",
      abs(max_hazard - min_hazard) < 0.001 ~ "Constant (CFR)",
      TRUE ~ "Non-monotonic"
    )
  )

hazard_analysis %>%
  knitr::kable(
    digits = 4,
    caption = "Hazard Function Properties by Distribution (IFR = Increasing Failure Rate, DFR = Decreasing, CFR = Constant)"
  )
```

| distribution | min_hazard | max_hazard | all_increasing | all_decreasing | behavior |
|:---|---:|---:|:---|:---|:---|
| Exponential | 1.0000 | 1.0000 | FALSE | TRUE | Decreasing (DFR) |
| Normal | 0.8626 | 5.0898 | TRUE | FALSE | Increasing (IFR) |
| t(3) | 0.5575 | 1.0614 | FALSE | FALSE | Non-monotonic |
| t(30) | 0.8547 | 2.8215 | TRUE | FALSE | Increasing (IFR) |

Hazard Function Properties by Distribution (IFR = Increasing Failure
Rate, DFR = Decreasing, CFR = Constant)

## Applications

### Survival Analysis Example

Show code

``` r
# Simulate survival times
set.seed(123)
survival_data <- tibble(
  time = seq(0.1, 10, by = 0.1)
) %>%
  mutate(
    # Different hazard patterns
    constant_hazard = hazard_function(time, "exponential", rate = 0.5),
    increasing_hazard = hazard_function(time, "normal", mean = 5, sd = 2),

    # Convert to survival probabilities
    # S(t) = exp(-integral of hazard)
    survival_constant = exp(-cumsum(constant_hazard * 0.1)),
    survival_increasing = exp(-cumsum(increasing_hazard * 0.1))
  )

# Plot survival curves
p_survival <- survival_data %>%
  select(time, starts_with("survival")) %>%
  pivot_longer(-time, names_to = "type", values_to = "probability") %>%
  mutate(type = str_remove(type, "survival_")) %>%
  ggplot(aes(time, probability, color = type)) +
  geom_line(size = 1.2) +
  labs(
    title = "Survival Curves from Different Hazard Functions",
    x = "Time",
    y = "Survival Probability",
    color = "Hazard Type"
  ) +
  theme_minimal()

ggplotly(p_survival)
```

### Reliability Engineering

Show code

``` r
# Component lifetime analysis
reliability_data <- tibble(
  hours = seq(100, 10000, by = 100)
) %>%
  mutate(
    # Normal wear-out (increasing hazard)
    wear_out_hazard = hazard_function(hours/1000, "normal", mean = 5, sd = 1.5),

    # Random failure (constant hazard)
    random_hazard = rep(0.0001, n()),

    # Combined hazard (competing risks)
    total_hazard = wear_out_hazard + random_hazard,

    # Reliability function R(t) = exp(-integral of hazard)
    reliability = exp(-cumsum(total_hazard * 100))
  )

# Display summary statistics
reliability_summary <- reliability_data %>%
  summarize(
    median_life = hours[which.min(abs(reliability - 0.5))],
    `10%_life` = hours[which.min(abs(reliability - 0.9))],
    `1%_life` = hours[which.min(abs(reliability - 0.99))]
  )

reliability_summary %>%
  knitr::kable(
    caption = "Component Life Estimates from Hazard Model"
  )
```

| median_life | 10%\_life | 1%\_life |
|------------:|----------:|---------:|
|         400 |       100 |      100 |

Component Life Estimates from Hazard Model

## Key Insights

1.  **Reciprocal Relationship**: The hazard function is always the
    reciprocal of the Mills ratio: $`h(x) = 1/m(x)`$

2.  **Distribution Classification**:

    - **Normal**: Increasing hazard (aging effect)
    - **Exponential**: Constant hazard (memoryless)
    - **t-distribution**: Eventually decreasing hazard (heavy tails)

3.  **Practical Applications**:

    - Use Mills ratio for tail probability calculations
    - Use hazard function for time-to-event modeling
    - Both provide insights into extreme event behavior

## Code Examples

### Pipeline for Analysis

Show code

``` r
# Complete analysis pipeline
analysis_pipeline <- function(x_range, distributions) {
  expand_grid(
    x = x_range,
    distribution = distributions
  ) %>%
    mutate(
      mills = case_when(
        distribution == "Normal" ~ mills_ratio_normal(x),
        distribution == "t(30)" ~ mills_ratio_t(x, df = 30),
        distribution == "Exponential" ~ mills_ratio_exp(x),
        TRUE ~ NA_real_
      ),
      hazard = 1 / mills
    ) %>%
    group_by(distribution) %>%
    summarize(
      avg_mills = mean(mills),
      avg_hazard = mean(hazard),
      mills_cv = sd(mills) / mean(mills),
      hazard_trend = cor(x, hazard)
    )
}

# Run analysis
results <- analysis_pipeline(
  x_range = seq(0.5, 5, by = 0.1),
  distributions = c("Normal", "t(30)", "Exponential")
)
```

    Warning: There was 1 warning in `summarize()`.
    ℹ In argument: `hazard_trend = cor(x, hazard)`.
    ℹ In group 1: `distribution = "Exponential"`.
    Caused by warning in `cor()`:
    ! the standard deviation is zero

Show code

``` r
results %>%
  knitr::kable(
    digits = 3,
    caption = "Distribution Comparison Summary"
  )
```

| distribution | avg_mills | avg_hazard | mills_cv | hazard_trend |
|:-------------|----------:|-----------:|---------:|-------------:|
| Exponential  |     1.000 |      1.000 |    0.000 |           NA |
| Normal       |     0.390 |      3.088 |    0.475 |        1.000 |
| t(30)        |     0.475 |      2.258 |    0.306 |        0.962 |

Distribution Comparison Summary

## Conclusion

The Mills ratio and hazard function provide complementary views of the
same underlying phenomenon. Understanding their relationship enables:

- Better interpretation of tail behavior
- Appropriate choice of distribution for modeling
- Cross-disciplinary insights between statistics and survival analysis

The `millsratio` package makes it easy to explore these relationships
using tidyverse-style workflows.
