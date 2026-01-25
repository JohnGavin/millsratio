# Targets plan for hazard function analysis
# This plan analyzes hazard functions (h = 1/m) and their properties

plan_hazard_analysis <- list(
  # Convert Mills ratios to hazard functions
  tar_target(
    hazard_data,
    {
      library(dplyr)
      
      mills_data %>%
        mutate(
          hazard = 1 / mills_ratio,
          log_hazard = log(hazard)
        )
    }
  ),
  
  # Analyze hazard function properties (IFR/DFR/CFR)
  tar_target(
    hazard_properties,
    {
      library(dplyr)
      
      hazard_data %>%
        group_by(distribution) %>%
        arrange(x) %>%
        mutate(
          hazard_diff = hazard - lag(hazard),
          is_increasing = hazard_diff > 0
        ) %>%
        summarize(
          all_increasing = all(is_increasing, na.rm = TRUE),
          all_decreasing = all(!is_increasing, na.rm = TRUE),
          all_constant = all(abs(hazard_diff) < 1e-10, na.rm = TRUE),
          behavior = case_when(
            all_increasing ~ 'IFR (Increasing Failure Rate)',
            all_decreasing ~ 'DFR (Decreasing Failure Rate)',
            all_constant ~ 'CFR (Constant Failure Rate)',
            TRUE ~ 'Non-monotonic'
          ),
          .groups = 'drop'
        )
    }
  ),
  
  # Create hazard function plot
  tar_target(
    hazard_plot,
    {
      library(ggplot2)
      
      ggplot(hazard_data, aes(x, hazard, color = distribution)) +
        geom_line(linewidth = 1) +
        scale_y_log10() +
        theme_minimal() +
        labs(
          title = 'Hazard Functions Comparison',
          subtitle = 'h(x) = 1/m(x) across distributions',
          x = 'x',
          y = 'Hazard h(x) [log scale]',
          color = 'Distribution'
        ) +
        theme(
          plot.title = element_text(size = 14, face = 'bold'),
          legend.position = 'bottom'
        )
    }
  ),
  
  # Create interactive hazard plot with plotly
  tar_target(
    hazard_interactive,
    {
      library(plotly)
      
      p <- ggplot(hazard_data, aes(x, hazard, color = distribution)) +
        geom_line(linewidth = 1) +
        scale_y_log10() +
        theme_minimal() +
        labs(
          title = 'Interactive Hazard Functions',
          x = 'x',
          y = 'Hazard h(x) [log scale]',
          color = 'Distribution'
        )
      
      ggplotly(p) %>%
        layout(
          hovermode = 'x unified',
          hoverlabel = list(bgcolor = 'white')
        )
    }
  ),
  
  # Compare hazard asymptotic behavior
  tar_target(
    hazard_asymptotics,
    {
      library(dplyr)
      
      # Focus on tail behavior (large x)
      hazard_data %>%
        filter(x >= 5) %>%
        group_by(distribution) %>%
        summarize(
          mean_hazard = mean(hazard, na.rm = TRUE),
          hazard_at_5 = hazard[x == 5],
          hazard_at_10 = hazard[x == max(x)],
          hazard_growth = hazard_at_10 / hazard_at_5,
          .groups = 'drop'
        )
    }
  )
)
