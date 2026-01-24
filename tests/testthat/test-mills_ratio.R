# Tests for Mills Ratio Functions

test_that("mills_ratio_normal works correctly", {
  # Test at x = 0 (should be sqrt(pi/2) ≈ 1.253)
  expect_equal(mills_ratio_normal(0), sqrt(pi/2), tolerance = 0.001)

  # Test vectorized input
  x_vals <- c(0, 1, 2, 3)
  m_vals <- mills_ratio_normal(x_vals)
  expect_length(m_vals, 4)
  expect_true(all(m_vals > 0))

  # Test that Mills ratio decreases for normal (thin tails)
  expect_true(all(diff(m_vals) < 0))

  # Test log Mills ratio
  log_m <- mills_ratio_normal(10, log = TRUE)
  expect_equal(exp(log_m), mills_ratio_normal(10), tolerance = 1e-10)

  # Test with non-standard parameters
  m_shifted <- mills_ratio_normal(2, mean = 1, sd = 2)
  expect_true(m_shifted > 0)
})

test_that("mills_ratio_t works correctly", {
  # Test basic functionality
  m_t30 <- mills_ratio_t(2, df = 30)
  expect_true(m_t30 > 0)

  # Test that Mills ratio increases for t (fat tails)
  x_vals <- c(1, 2, 3, 4)
  m_t3 <- mills_ratio_t(x_vals, df = 3)
  expect_true(all(diff(m_t3) > 0))  # Should increase

  # Test df validation
  expect_error(mills_ratio_t(2), "Degrees of freedom")
  expect_error(mills_ratio_t(2, df = 0), "Degrees of freedom")
  expect_error(mills_ratio_t(2, df = -1), "Degrees of freedom")

  # Test convergence to normal as df increases
  m_t100 <- mills_ratio_t(2, df = 100)
  m_normal <- mills_ratio_normal(2)
  expect_equal(m_t100, m_normal, tolerance = 0.1)
})

test_that("mills_ratio_exp works correctly", {
  # Test that exponential Mills ratio is constant
  x_vals <- c(0.5, 1, 2, 3, 4)
  m_exp <- mills_ratio_exp(x_vals, rate = 1)
  expect_true(all(m_exp == 1))  # Should be 1/rate = 1

  # Test with different rate
  m_exp2 <- mills_ratio_exp(x_vals, rate = 2)
  expect_true(all(m_exp2 == 0.5))  # Should be 1/rate = 0.5

  # Test negative x values (outside support)
  m_neg <- mills_ratio_exp(c(-1, 0, 1), rate = 1)
  expect_true(is.na(m_neg[1]))
  expect_false(is.na(m_neg[2]))
  expect_false(is.na(m_neg[3]))

  # Test rate validation
  expect_error(mills_ratio_exp(2, rate = 0), "Rate parameter must be positive")
  expect_error(mills_ratio_exp(2, rate = -1), "Rate parameter must be positive")
})

test_that("mills_ratio_generic works correctly", {
  # Test with normal distribution
  m_generic <- mills_ratio_generic(2, cdf_fun = pnorm, pdf_fun = dnorm)
  m_direct <- mills_ratio_normal(2)
  expect_equal(m_generic, m_direct, tolerance = 1e-10)

  # Test with t-distribution
  m_generic_t <- mills_ratio_generic(2, cdf_fun = pt, pdf_fun = dt, df = 30)
  m_direct_t <- mills_ratio_t(2, df = 30)
  expect_equal(m_generic_t, m_direct_t, tolerance = 1e-10)

  # Test log version
  log_m_generic <- mills_ratio_generic(2, cdf_fun = pnorm, pdf_fun = dnorm, log = TRUE)
  expect_equal(exp(log_m_generic), m_generic, tolerance = 1e-10)
})

test_that("compare_mills_ratios works correctly", {
  x_vals <- c(1, 2, 3)
  result <- compare_mills_ratios(x_vals, c("normal", "t30", "exponential"))

  # Check structure
  expect_equal(nrow(result), 3)
  expect_true("x" %in% names(result))
  expect_true("normal" %in% names(result))
  expect_true("t_df30" %in% names(result))
  expect_true("exponential" %in% names(result))

  # Check values make sense
  expect_true(all(result$normal > 0))
  expect_true(all(result$t_df30 > 0))
  expect_true(all(result$exponential == 1))  # Exponential is constant

  # Test warning for unknown distribution
  expect_warning(compare_mills_ratios(x_vals, c("normal", "unknown")))
})

test_that("mills_asymptotic works correctly", {
  x_vals <- c(5, 10, 20)

  # Test normal asymptotic (1/x)
  asymp_normal <- mills_asymptotic(x_vals, "normal")
  expect_equal(asymp_normal, 1/x_vals)

  # Test t asymptotic (x/df)
  asymp_t <- mills_asymptotic(x_vals, "t", df = 30)
  expect_equal(asymp_t, x_vals/30)

  # Test exponential (constant)
  asymp_exp <- mills_asymptotic(x_vals, "exponential")
  expect_true(all(asymp_exp == 1))

  # Test error handling
  expect_error(mills_asymptotic(x_vals, "unknown"))
  expect_error(mills_asymptotic(x_vals, "t"), "Degrees of freedom")
})

test_that("mills_ratio_comparison works correctly", {
  x_vals <- seq(1, 5, by = 1)

  # Test t(30) to normal ratio
  ratio <- mills_ratio_comparison(x_vals, "t", "normal", df1 = 30)
  expect_length(ratio, length(x_vals))
  expect_true(all(ratio > 0))

  # At large x, t(30) should have larger Mills ratio than normal
  expect_true(ratio[length(ratio)] > 1)

  # Test exponential to normal ratio
  ratio_exp <- mills_ratio_comparison(x_vals, "exponential", "normal")
  expect_true(all(ratio_exp > 0))

  # Test error handling
  expect_error(mills_ratio_comparison(x_vals, "t", "normal"),
              "df1 required for t-distribution")
  expect_error(mills_ratio_comparison(x_vals, "unknown", "normal"),
              "Unknown distribution")
})

test_that("Mills ratio behavior matches theoretical expectations", {
  x_vals <- seq(2, 10, by = 2)

  # Normal: Mills ratio should decrease (thin tails)
  m_normal <- mills_ratio_normal(x_vals)
  expect_true(all(diff(m_normal) < 0))

  # t(3): Mills ratio should increase (fat tails)
  m_t3 <- mills_ratio_t(x_vals, df = 3)
  expect_true(all(diff(m_t3) > 0))

  # Exponential: Mills ratio should be constant
  m_exp <- mills_ratio_exp(x_vals)
  expect_true(all(abs(diff(m_exp)) < 1e-10))

  # t(30) paradox: Similar to normal for small x, diverges for large x
  m_t30 <- mills_ratio_t(x_vals, df = 30)
  ratio_small <- m_t30[1] / m_normal[1]
  ratio_large <- m_t30[length(x_vals)] / m_normal[length(x_vals)]
  expect_true(ratio_large > ratio_small)  # Divergence increases
})