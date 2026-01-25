# Targets plan for Mills ratio simulations
# This plan creates a comprehensive simulation dataset comparing Mills ratios
# across multiple distributions

plan_mills_simulation <- list(
  # Define simulation parameters
  tar_target(
    simulation_params,
    list(
      x_range = seq(0.1, 10, by = 0.1),
      distributions = c('normal', 't3', 't30', 'exponential'),
      n_sim = 1000,
      seed = 42
    )
  ),
  
  # Generate Mills ratio data across distributions
  tar_target(
    mills_data,
    {
      library(dplyr)
      library(tidyr)
      
      expand_grid(
        x = simulation_params$x_range,
        distribution = simulation_params$distributions
      ) %>%
        mutate(
          mills_ratio = case_when(
            distribution == 'normal' ~ mills_ratio_normal(x),
            distribution == 't3' ~ mills_ratio_t(x, df = 3),
            distribution == 't30' ~ mills_ratio_t(x, df = 30),
            distribution == 'exponential' ~ mills_ratio_exp(x)
          )
        )
    }
  ),
  
  # Calculate summary statistics by distribution
  tar_target(
    mills_summary,
    {
      library(dplyr)
      
      mills_data %>%
        group_by(distribution) %>%
        summarize(
          mean_mills = mean(mills_ratio, na.rm = TRUE),
          sd_mills = sd(mills_ratio, na.rm = TRUE),
          min_mills = min(mills_ratio, na.rm = TRUE),
          max_mills = max(mills_ratio, na.rm = TRUE),
          median_mills = median(mills_ratio, na.rm = TRUE),
          .groups = 'drop'
        )
    }
  ),
  
  # Analyze Mills ratio behavior (increasing/decreasing)
  tar_target(
    mills_behavior,
    {
      library(dplyr)
      
      mills_data %>%
        group_by(distribution) %>%
        arrange(x) %>%
        mutate(
          mills_diff = mills_ratio - lag(mills_ratio),
          is_decreasing = mills_diff < 0
        ) %>%
        summarize(
          all_decreasing = all(is_decreasing, na.rm = TRUE),
          all_increasing = all(!is_decreasing, na.rm = TRUE),
          behavior = case_when(
            all_decreasing ~ 'Decreasing',
            all_increasing ~ 'Increasing',
            TRUE ~ 'Non-monotonic'
          ),
          .groups = 'drop'
        )
    }
  ),
  
  # Compare Mills ratios: ratio of t(30) to normal
  tar_target(
    t30_paradox_analysis,
    {
      library(dplyr)
      
      mills_data %>%
        filter(distribution %in% c('normal', 't30')) %>%
        select(x, distribution, mills_ratio) %>%
        pivot_wider(names_from = distribution, values_from = mills_ratio) %>%
        mutate(
          ratio_t30_to_normal = t30 / normal,
          asymptotic_approx = x * 30  # Theoretical approximation
        )
    }
  )
)
