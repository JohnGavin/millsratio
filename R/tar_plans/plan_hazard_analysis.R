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
  ),

  # Numerical verification table: h(x)*m(x) = 1 for all distributions
  tar_target(
    hazard_verification_table,
    {
      library(dplyr)
      x_vals <- c(0.5, 1, 2, 3, 4, 5, 7, 10)
      dists <- list(
        list(name = "Normal", fn = function(x) compare_mills_hazard(x, "normal")),
        list(name = "t(30)", fn = function(x) compare_mills_hazard(x, "t", df = 30)),
        list(name = "t(3)", fn = function(x) compare_mills_hazard(x, "t", df = 3)),
        list(name = "Exponential", fn = function(x) compare_mills_hazard(x, "exponential"))
      )
      do.call(rbind, lapply(dists, function(d) {
        result <- d$fn(x_vals)
        result$distribution <- d$name
        result$product <- result$mills_ratio * result$hazard
        result$abs_error <- abs(result$product - 1)
        result
      }))
    }
  ),

  # Hazard crossover data: t(30) vs normal hazard comparison
  tar_target(
    hazard_crossover_data,
    {
      library(dplyr)
      x_vals <- seq(0.1, 10, by = 0.05)
      tibble(
        x = x_vals,
        h_normal = hazard_function(x_vals, "normal"),
        h_t30 = hazard_function(x_vals, "t", df = 30),
        ratio = h_t30 / h_normal,
        t30_higher = h_t30 > h_normal
      )
    }
  ),

  # Precomputed data for side-by-side mills vs hazard visualization
  tar_target(
    hazard_mills_side_by_side,
    {
      x_vals <- seq(0.1, 5, length.out = 200)
      dists <- list(
        list(name = "Normal", dist = "normal", args = list()),
        list(name = "t(30)", dist = "t", args = list(df = 30)),
        list(name = "Exponential", dist = "exponential", args = list())
      )
      do.call(rbind, lapply(dists, function(d) {
        result <- do.call(compare_mills_hazard, c(list(x = x_vals, distribution = d$dist), d$args))
        result$distribution <- d$name
        result
      }))
    }
  ),

  # Static ggplot2 side-by-side plot
  tar_target(
    hazard_plot_mills_vs_hazard,
    {
      plot_mills_vs_hazard(
        x_range = c(0.1, 5),
        distributions = c("normal", "t30", "exponential"),
        log_y = TRUE
      )
    }
  ),

  # Save all new hazard targets to inst/extdata/
  tar_target(
    save_hazard_extdata,
    {
      dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
      saveRDS(hazard_verification_table, "inst/extdata/hazard_verification_table.rds")
      saveRDS(hazard_crossover_data, "inst/extdata/hazard_crossover_data.rds")
      saveRDS(hazard_mills_side_by_side, "inst/extdata/hazard_mills_side_by_side.rds")
      saveRDS(hazard_plot_mills_vs_hazard, "inst/extdata/hazard_plot_mills_vs_hazard.rds")
      TRUE
    }
  )
)
