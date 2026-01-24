#' Simulation Framework for Mills Ratio Analysis
#'
#' @description
#' Functions to generate and compare Mills ratio curves across distributions,
#' supporting the interactive dashboard and analysis vignettes.
#'
#' @author John Gavin <john.b.gavin@gmail.com>

#' Generate Mills Ratio Curves
#'
#' @param x_range Numeric vector of two elements: c(min, max)
#' @param n_points Number of points to evaluate (default = 100)
#' @param distributions Character vector of distributions to include
#' @param log_scale Logical; if TRUE, uses log-spaced x values
#' @param include_asymptotic Logical; if TRUE, includes asymptotic approximations
#'
#' @return Data frame in long format suitable for plotting
#' @export
#'
#' @examples
#' # Generate curves for comparison
#' curves <- simulate_mills_curves(
#'   x_range = c(0.5, 5),
#'   distributions = c("normal", "t3", "t30", "exponential")
#' )
simulate_mills_curves <- function(x_range = c(0.5, 5),
                                  n_points = 100,
                                  distributions = c("normal", "t30", "exponential"),
                                  log_scale = FALSE,
                                  include_asymptotic = FALSE) {

  # Generate x values
  if (log_scale) {
    x_vals <- exp(seq(log(x_range[1]), log(x_range[2]), length.out = n_points))
  } else {
    x_vals <- seq(x_range[1], x_range[2], length.out = n_points)
  }

  # Initialize results list
  results_list <- list()

  # Process each distribution
  for (dist in distributions) {
    if (dist == "normal") {
      mills_vals <- mills_ratio_normal(x_vals)
      dist_label <- "Normal"

      if (include_asymptotic) {
        asymp_vals <- mills_asymptotic(x_vals, "normal")
        results_list[[paste0(dist, "_asymptotic")]] <- data.frame(
          x = x_vals,
          mills_ratio = asymp_vals,
          distribution = "Normal (asymptotic)",
          type = "asymptotic"
        )
      }
    } else if (dist == "exponential") {
      mills_vals <- mills_ratio_exp(x_vals)
      dist_label <- "Exponential"

      if (include_asymptotic) {
        asymp_vals <- mills_asymptotic(x_vals, "exponential")
        results_list[[paste0(dist, "_asymptotic")]] <- data.frame(
          x = x_vals,
          mills_ratio = asymp_vals,
          distribution = "Exponential (asymptotic)",
          type = "asymptotic"
        )
      }
    } else if (grepl("^t\\d+$", dist)) {
      df <- as.numeric(sub("^t", "", dist))
      mills_vals <- mills_ratio_t(x_vals, df = df)
      dist_label <- paste0("t(", df, ")")

      if (include_asymptotic) {
        asymp_vals <- mills_asymptotic(x_vals, "t", df = df)
        results_list[[paste0(dist, "_asymptotic")]] <- data.frame(
          x = x_vals,
          mills_ratio = asymp_vals,
          distribution = paste0("t(", df, ") (asymptotic)"),
          type = "asymptotic"
        )
      }
    } else {
      warning(paste("Unknown distribution:", dist))
      next
    }

    # Add exact values
    results_list[[dist]] <- data.frame(
      x = x_vals,
      mills_ratio = mills_vals,
      distribution = dist_label,
      type = "exact"
    )
  }

  # Combine all results
  results <- dplyr::bind_rows(results_list)
  return(results)
}

#' Analyze Tail Thickness at Specific Points
#'
#' @param x_points Numeric vector of x values to analyze
#' @param distributions Character vector of distributions
#' @param compute_ratios Logical; if TRUE, computes ratios relative to normal
#'
#' @return Data frame with Mills ratios and optional comparison metrics
#' @export
#'
#' @examples
#' # Analyze at key points
#' tail_analysis <- analyze_tail_thickness(
#'   x_points = c(2, 3, 4, 5),
#'   distributions = c("normal", "t30", "exponential"),
#'   compute_ratios = TRUE
#' )
analyze_tail_thickness <- function(x_points,
                                   distributions = c("normal", "t30", "exponential"),
                                   compute_ratios = FALSE) {

  # Get Mills ratios for all distributions
  results <- compare_mills_ratios(x_points, distributions)

  # Reshape to long format
  results_long <- tidyr::pivot_longer(
    results,
    cols = -x,
    names_to = "distribution",
    values_to = "mills_ratio"
  )

  # Add classifications
  results_long <- results_long |>
    dplyr::mutate(
      tail_type = dplyr::case_when(
        distribution == "normal" ~ "thin",
        distribution == "exponential" ~ "medium",
        grepl("^t_df", distribution) ~ "fat",
        TRUE ~ "unknown"
      )
    )

  if (compute_ratios && "normal" %in% names(results)) {
    # Compute ratios relative to normal
    normal_vals <- results$normal

    # Drop tail_type before pivoting to avoid multiple rows per x
    results_wide <- tidyr::pivot_wider(
      results_long |> dplyr::select(-tail_type),
      names_from = distribution,
      values_from = mills_ratio
    )

    # Add ratio columns
    for (col in setdiff(names(results_wide), c("x", "normal"))) {
      ratio_col <- paste0(col, "_to_normal_ratio")
      results_wide[[ratio_col]] <- results_wide[[col]] / results_wide$normal
    }

    return(results_wide)
  }

  return(results_long)
}

#' Find Crossover Points Between Distributions
#'
#' @param dist1 First distribution
#' @param dist2 Second distribution
#' @param df1 Degrees of freedom for first distribution (if t)
#' @param df2 Degrees of freedom for second distribution (if t)
#' @param x_range Search range for crossover
#' @param tolerance Numerical tolerance for finding crossover
#'
#' @return Numeric value of x where Mills ratios are equal (NA if no crossover)
#' @export
#'
#' @examples
#' # Find where t(30) and normal Mills ratios cross
#' crossover <- find_crossover_point("t", "normal", df1 = 30)
find_crossover_point <- function(dist1, dist2,
                                df1 = NULL, df2 = NULL,
                                x_range = c(0.01, 10),
                                tolerance = 1e-6) {

  # Define difference function
  diff_fun <- function(x) {
    if (dist1 == "normal") {
      m1 <- mills_ratio_normal(x)
    } else if (dist1 == "t") {
      m1 <- mills_ratio_t(x, df = df1)
    } else if (dist1 == "exponential") {
      m1 <- mills_ratio_exp(x)
    }

    if (dist2 == "normal") {
      m2 <- mills_ratio_normal(x)
    } else if (dist2 == "t") {
      m2 <- mills_ratio_t(x, df = df2)
    } else if (dist2 == "exponential") {
      m2 <- mills_ratio_exp(x)
    }

    return(m1 - m2)
  }

  # Check if there's a sign change in the range
  diff_start <- diff_fun(x_range[1])
  diff_end <- diff_fun(x_range[2])

  if (sign(diff_start) == sign(diff_end)) {
    return(NA)  # No crossover in range
  }

  # Use uniroot to find crossover
  result <- tryCatch({
    stats::uniroot(diff_fun, interval = x_range, tol = tolerance)$root
  }, error = function(e) {
    NA
  })

  return(result)
}

#' Generate Data for t(30) Paradox Analysis
#'
#' @param x_range Range of x values
#' @param n_points Number of points
#'
#' @return Data frame comparing t(30) and normal distributions
#' @export
#'
#' @examples
#' paradox_data <- analyze_t30_paradox()
analyze_t30_paradox <- function(x_range = c(0, 5), n_points = 200) {

  x_vals <- seq(x_range[1], x_range[2], length.out = n_points)

  # Calculate Mills ratios
  m_normal <- mills_ratio_normal(x_vals)
  m_t30 <- mills_ratio_t(x_vals, df = 30)

  # Calculate PDFs for comparison
  pdf_normal <- stats::dnorm(x_vals)
  pdf_t30 <- stats::dt(x_vals, df = 30)

  # Calculate CDFs
  cdf_normal <- stats::pnorm(x_vals)
  cdf_t30 <- stats::pt(x_vals, df = 30)

  # Create comprehensive comparison
  paradox_data <- data.frame(
    x = x_vals,
    mills_normal = m_normal,
    mills_t30 = m_t30,
    mills_ratio = m_t30 / m_normal,
    pdf_normal = pdf_normal,
    pdf_t30 = pdf_t30,
    pdf_ratio = pdf_t30 / pdf_normal,
    cdf_normal = cdf_normal,
    cdf_t30 = cdf_t30,
    cdf_difference = abs(cdf_normal - cdf_t30),
    similarity_zone = ifelse(abs(cdf_normal - cdf_t30) < 0.01, "similar", "different")
  )

  return(paradox_data)
}

#' Monte Carlo Simulation for Mills Ratio Estimation
#'
#' @param n_sim Number of simulations
#' @param x_val Value at which to estimate Mills ratio
#' @param distribution Distribution to sample from
#' @param df Degrees of freedom (for t-distribution)
#' @param seed Random seed for reproducibility
#'
#' @return List with empirical Mills ratio estimate and confidence interval
#' @export
#'
#' @examples
#' # Empirically verify Mills ratio for normal at x=2
#' mc_result <- monte_carlo_mills(n_sim = 10000, x_val = 2, distribution = "normal")
monte_carlo_mills <- function(n_sim = 10000,
                             x_val = 2,
                             distribution = "normal",
                             df = NULL,
                             seed = NULL) {

  if (!is.null(seed)) {
    set.seed(seed)
  }

  # Generate samples
  if (distribution == "normal") {
    samples <- stats::rnorm(n_sim)
  } else if (distribution == "t") {
    if (is.null(df)) stop("df required for t-distribution")
    samples <- stats::rt(n_sim, df = df)
  } else if (distribution == "exponential") {
    samples <- stats::rexp(n_sim)
  } else {
    stop("Unknown distribution")
  }

  # Empirical CCDF: proportion of samples > x_val
  empirical_ccdf <- mean(samples > x_val)

  # Empirical PDF: kernel density estimate at x_val
  kde <- stats::density(samples)
  empirical_pdf <- stats::approx(kde$x, kde$y, xout = x_val)$y

  # Empirical Mills ratio
  empirical_mills <- if (empirical_pdf > 0) {
    empirical_ccdf / empirical_pdf
  } else {
    NA
  }

  # Bootstrap confidence interval
  boot_mills <- numeric(100)
  for (i in 1:100) {
    boot_samples <- sample(samples, n_sim, replace = TRUE)
    boot_ccdf <- mean(boot_samples > x_val)
    boot_kde <- stats::density(boot_samples)
    boot_pdf <- stats::approx(boot_kde$x, boot_kde$y, xout = x_val)$y
    boot_mills[i] <- if (boot_pdf > 0) boot_ccdf / boot_pdf else NA
  }

  ci <- stats::quantile(boot_mills, c(0.025, 0.975), na.rm = TRUE)

  # True Mills ratio for comparison
  if (distribution == "normal") {
    true_mills <- mills_ratio_normal(x_val)
  } else if (distribution == "t") {
    true_mills <- mills_ratio_t(x_val, df = df)
  } else if (distribution == "exponential") {
    true_mills <- mills_ratio_exp(x_val)
  }

  return(list(
    x = x_val,
    distribution = distribution,
    empirical_mills = empirical_mills,
    true_mills = true_mills,
    error = abs(empirical_mills - true_mills),
    relative_error = abs(empirical_mills - true_mills) / true_mills,
    ci_lower = ci[1],
    ci_upper = ci[2],
    n_sim = n_sim
  ))
}