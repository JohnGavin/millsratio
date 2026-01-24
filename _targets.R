# Mills Ratio Package - Targets Pipeline
# This pipeline ensures all examples are tested and documentation is generated

library(targets)
library(tarchetypes)

# Set options
tar_option_set(
  packages = c("millsratio", "ggplot2", "dplyr", "tidyr", "plotly"),
  format = "rds"
)

# Source functions if needed
# tar_source()

list(
  # Track raw source files
  tar_target(
    name = mills_ratio_source,
    command = readLines("R/mills_ratio.R"),
    format = "file"
  ),

  tar_target(
    name = simulation_source,
    command = readLines("R/simulation.R"),
    format = "file"
  ),

  tar_target(
    name = visualization_source,
    command = readLines("R/visualization.R"),
    format = "file"
  ),

  # Example 1: Basic Mills ratio calculations
  tar_target(
    name = example_basic,
    command = {
      x <- seq(1, 5, by = 0.5)
      list(
        x = x,
        m_normal = mills_ratio_normal(x),
        m_t30 = mills_ratio_t(x, df = 30),
        m_exp = mills_ratio_exp(x)
      )
    }
  ),

  # Example 2: Compare distributions
  tar_target(
    name = example_comparison,
    command = {
      x <- c(1, 2, 3, 4)
      compare_mills_ratios(x, c("normal", "t30", "exponential"))
    }
  ),

  # Example 3: t(30) paradox analysis
  tar_target(
    name = example_paradox,
    command = {
      paradox_data <- analyze_t30_paradox()
      list(
        data = paradox_data,
        x_vals = c(1, 2, 3, 4, 5),
        ratio = mills_ratio_t(c(1, 2, 3, 4, 5), df = 30) /
                mills_ratio_normal(c(1, 2, 3, 4, 5))
      )
    }
  ),

  # Example 4: Simulation curves
  tar_target(
    name = example_curves,
    command = {
      simulate_mills_curves(
        x_range = c(0.5, 5),
        n_points = 100,
        distributions = c("normal", "t30", "exponential")
      )
    }
  ),

  # Example 5: Visualization (create but don't display)
  tar_target(
    name = example_plot,
    command = {
      curves <- simulate_mills_curves(
        distributions = c("normal", "t30", "exponential")
      )
      p <- plot_mills_curves(curves, log_y = TRUE)
      # Return plot object for validation
      p
    }
  ),

  # Example 6: Interactive plot
  tar_target(
    name = example_interactive,
    command = {
      curves <- simulate_mills_curves(
        x_range = c(0.1, 10),
        distributions = c("normal", "t3", "t10", "t30"),
        log_scale = TRUE,
        n_points = 50
      )
      p <- plot_mills_curves(curves, log_y = TRUE, interactive = TRUE)
      # Validate it's a plotly object
      inherits(p, "plotly")
    }
  ),

  # Example 7: Monte Carlo verification
  tar_target(
    name = example_monte_carlo,
    command = {
      set.seed(123)
      monte_carlo_mills(
        n_sim = 1000,  # Reduced for speed
        x_val = 2,
        distribution = "normal"
      )
    }
  ),

  # Example 8: Property verification
  tar_target(
    name = example_properties,
    command = {
      x <- seq(1, 5, by = 0.5)
      list(
        normal_decreasing = all(diff(mills_ratio_normal(x)) < 0),
        t3_increasing = all(diff(mills_ratio_t(x, df = 3)) > 0),
        exp_constant = all(abs(diff(mills_ratio_exp(x))) < 1e-10)
      )
    }
  ),

  # Example 9: Dashboard function exists
  tar_target(
    name = example_dashboard,
    command = {
      # Check dashboard can be called (without launching)
      exists("launch_dashboard") && is.function(launch_dashboard)
    }
  ),

  # Test that all examples succeeded
  tar_target(
    name = all_examples_passed,
    command = {
      results <- list(
        basic = !is.null(example_basic),
        comparison = nrow(example_comparison) == 4,
        paradox = !is.null(example_paradox$data),
        curves = nrow(example_curves) > 0,
        plot = inherits(example_plot, "gg"),
        interactive = example_interactive,
        monte_carlo = abs(example_monte_carlo$relative_error) < 0.5,
        properties = all(unlist(example_properties)),
        dashboard = example_dashboard
      )

      if (!all(unlist(results))) {
        failed <- names(results)[!unlist(results)]
        stop("Examples failed: ", paste(failed, collapse = ", "))
      }

      message("All examples passed successfully!")
      TRUE
    }
  ),

  # Generate README from Quarto
  tar_quarto(
    name = readme,
    path = "README.qmd",
    quiet = FALSE
  ),

  # Run package tests
  tar_target(
    name = test_results,
    command = {
      devtools::test(quiet = FALSE)
    }
  ),

  # Run package check
  tar_target(
    name = check_results,
    command = {
      devtools::check(quiet = FALSE, error_on = "never")
    }
  )
)