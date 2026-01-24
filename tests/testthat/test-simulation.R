# Tests for Simulation Functions

test_that("simulate_mills_curves works correctly", {
  # Basic test
  curves <- simulate_mills_curves(
    x_range = c(1, 5),
    n_points = 10,
    distributions = c("normal", "t30", "exponential")
  )

  # Check structure
  expect_s3_class(curves, "data.frame")
  expect_equal(nrow(curves), 10 * 3)  # 10 points × 3 distributions
  expect_true(all(c("x", "mills_ratio", "distribution", "type") %in% names(curves)))

  # Check distributions present
  expect_true("Normal" %in% curves$distribution)
  expect_true("t(30)" %in% curves$distribution)
  expect_true("Exponential" %in% curves$distribution)

  # Test with asymptotic approximations
  curves_asymp <- simulate_mills_curves(
    x_range = c(1, 5),
    n_points = 10,
    distributions = c("normal"),
    include_asymptotic = TRUE
  )
  expect_true("Normal (asymptotic)" %in% curves_asymp$distribution)
  expect_true("asymptotic" %in% curves_asymp$type)

  # Test log scale
  curves_log <- simulate_mills_curves(
    x_range = c(0.1, 10),
    n_points = 5,
    log_scale = TRUE
  )
  x_vals <- unique(curves_log$x)
  # Check that values are log-spaced (ratios should be constant)
  ratios <- x_vals[-1] / x_vals[-length(x_vals)]
  expect_true(sd(ratios) < 0.01)  # Small standard deviation
})

test_that("analyze_tail_thickness works correctly", {
  # Basic test without ratios
  result <- analyze_tail_thickness(
    x_points = c(2, 3, 4),
    distributions = c("normal", "t30", "exponential"),
    compute_ratios = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("tail_type" %in% names(result))
  expect_true("thin" %in% result$tail_type)
  expect_true("fat" %in% result$tail_type)
  expect_true("medium" %in% result$tail_type)

  # Test with ratios
  result_ratios <- analyze_tail_thickness(
    x_points = c(2, 3, 4),
    distributions = c("normal", "t30", "exponential"),
    compute_ratios = TRUE
  )

  expect_true("t_df30_to_normal_ratio" %in% names(result_ratios))
  expect_true("exponential_to_normal_ratio" %in% names(result_ratios))

  # Check that ratios make sense
  # t(30) should have higher Mills ratio than normal at large x
  expect_true(all(result_ratios$t_df30_to_normal_ratio[result_ratios$x > 3] > 1))
})

test_that("find_crossover_point works correctly", {
  # Test case where crossover exists
  # Normal and t distributions should cross somewhere
  crossover <- find_crossover_point("t", "normal", df1 = 30, x_range = c(0.01, 10))

  if (!is.na(crossover)) {
    expect_true(crossover > 0)
    expect_true(crossover < 10)

    # Check that Mills ratios are approximately equal at crossover
    m_t <- mills_ratio_t(crossover, df = 30)
    m_n <- mills_ratio_normal(crossover)
    expect_equal(m_t, m_n, tolerance = 0.01)
  }

  # Test case where no crossover exists
  # Exponential is constant, normal decreases, so they might not cross
  crossover_exp <- find_crossover_point("exponential", "normal", x_range = c(5, 10))
  # This might be NA if they don't cross in the range
})

test_that("analyze_t30_paradox works correctly", {
  paradox_data <- analyze_t30_paradox(x_range = c(0, 5), n_points = 50)

  # Check structure
  expect_s3_class(paradox_data, "data.frame")
  expect_equal(nrow(paradox_data), 50)

  expected_cols <- c("x", "mills_normal", "mills_t30", "mills_ratio",
                     "pdf_normal", "pdf_t30", "pdf_ratio",
                     "cdf_normal", "cdf_t30", "cdf_difference",
                     "similarity_zone")
  expect_true(all(expected_cols %in% names(paradox_data)))

  # Check that PDFs and CDFs are valid
  expect_true(all(paradox_data$pdf_normal >= 0))
  expect_true(all(paradox_data$pdf_t30 >= 0))
  expect_true(all(paradox_data$cdf_normal >= 0 & paradox_data$cdf_normal <= 1))
  expect_true(all(paradox_data$cdf_t30 >= 0 & paradox_data$cdf_t30 <= 1))

  # Check similarity zones
  expect_true(all(paradox_data$similarity_zone %in% c("similar", "different")))

  # For small x, distributions should be similar
  small_x_data <- paradox_data[paradox_data$x < 1 & paradox_data$x > 0, ]
  if (nrow(small_x_data) > 0) {
    expect_true(sum(small_x_data$similarity_zone == "similar") > 0)
  }

  # Mills ratio of t(30) should exceed normal for large x
  large_x_data <- paradox_data[paradox_data$x > 4, ]
  if (nrow(large_x_data) > 0) {
    expect_true(all(large_x_data$mills_ratio > 1))
  }
})

test_that("monte_carlo_mills works correctly", {
  # Set seed for reproducibility
  set.seed(123)

  # Test normal distribution
  mc_result <- monte_carlo_mills(
    n_sim = 1000,
    x_val = 2,
    distribution = "normal",
    seed = 123
  )

  expect_type(mc_result, "list")
  expect_true(all(c("empirical_mills", "true_mills", "error",
                   "relative_error", "ci_lower", "ci_upper") %in% names(mc_result)))

  # Empirical should be close to true for large n_sim
  expect_equal(mc_result$empirical_mills, mc_result$true_mills, tolerance = 0.2)

  # Confidence interval should contain true value
  expect_true(mc_result$true_mills >= mc_result$ci_lower)
  expect_true(mc_result$true_mills <= mc_result$ci_upper)

  # Test t-distribution
  mc_t <- monte_carlo_mills(
    n_sim = 1000,
    x_val = 2,
    distribution = "t",
    df = 30,
    seed = 456
  )

  expect_equal(mc_t$empirical_mills, mc_t$true_mills, tolerance = 0.3)

  # Test error handling
  expect_error(monte_carlo_mills(n_sim = 100, x_val = 2, distribution = "t"),
              "df required for t-distribution")
})