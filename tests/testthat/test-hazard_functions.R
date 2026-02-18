# Tests for Hazard Functions
# Tests hazard_from_mills, hazard_function, compare_mills_hazard, hazard_properties

# --- hazard_from_mills() ---

test_that("hazard_from_mills computes reciprocal correctly", {
  expect_equal(hazard_from_mills(2), 0.5)
  expect_equal(hazard_from_mills(0.5), 2)
  expect_equal(hazard_from_mills(1), 1)
})

test_that("hazard_from_mills handles vectorized input", {
  mills <- c(0.5, 1, 2, 4)
  h <- hazard_from_mills(mills)
  expect_length(h, 4)
  expect_equal(h, 1 / mills)
})

test_that("hazard_from_mills handles edge cases", {
  # Zero input -> Inf

expect_equal(hazard_from_mills(0), Inf)

  # Inf input -> 0
  expect_equal(hazard_from_mills(Inf), 0)

  # Negative input (mathematically valid, just 1/x)
  expect_equal(hazard_from_mills(-2), -0.5)
})

test_that("hazard_from_mills roundtrips with mills_ratio_normal", {
  x <- c(1, 2, 3, 4)
  m <- mills_ratio_normal(x)
  h <- hazard_from_mills(m)
  # h(x) should equal f(x)/S(x) directly
  h_direct <- dnorm(x) / pnorm(x, lower.tail = FALSE)
  expect_equal(h, h_direct, tolerance = 1e-10)
})

test_that("hazard_from_mills roundtrips with mills_ratio_t", {
  x <- c(1, 2, 3, 4)
  m <- mills_ratio_t(x, df = 30)
  h <- hazard_from_mills(m)
  h_direct <- dt(x, df = 30) / pt(x, df = 30, lower.tail = FALSE)
  expect_equal(h, h_direct, tolerance = 1e-10)
})

# --- hazard_function() ---

test_that("hazard_function works for normal distribution", {
  x <- c(1, 2, 3)
  h <- hazard_function(x, "normal")
  expect_length(h, 3)
  expect_true(all(h > 0))
  # Compare with direct calculation
  h_direct <- dnorm(x) / pnorm(x, lower.tail = FALSE)
  expect_equal(h, h_direct, tolerance = 1e-10)
})

test_that("hazard_function works for t distribution", {
  x <- c(1, 2, 3)
  h <- hazard_function(x, "t", df = 30)
  expect_length(h, 3)
  expect_true(all(h > 0))
  h_direct <- dt(x, df = 30) / pt(x, df = 30, lower.tail = FALSE)
  expect_equal(h, h_direct, tolerance = 1e-10)
})

test_that("hazard_function works for exponential distribution", {
  x <- c(0.5, 1, 2, 3)
  h <- hazard_function(x, "exponential", rate = 1)
  expect_length(h, 4)
  # Exponential hazard is constant = rate
  expect_equal(h, rep(1, 4), tolerance = 1e-10)
})

test_that("hazard_function errors on unknown distribution", {
  expect_error(hazard_function(1, "unknown"), "Unknown distribution")
})

test_that("hazard_function handles vectorized input", {
  x <- seq(0.1, 5, by = 0.1)
  h <- hazard_function(x, "normal")
  expect_length(h, 50)
  expect_true(all(h > 0))
})

test_that("hazard_function equals 1/mills_ratio for normal", {
  x <- seq(0.5, 5, by = 0.5)
  h <- hazard_function(x, "normal")
  m <- mills_ratio_normal(x)
  expect_equal(h, 1 / m, tolerance = 1e-10)
})

test_that("hazard_function equals 1/mills_ratio for t distribution", {
  x <- seq(0.5, 5, by = 0.5)
  h <- hazard_function(x, "t", df = 10)
  m <- mills_ratio_t(x, df = 10)
  expect_equal(h, 1 / m, tolerance = 1e-10)
})

test_that("hazard_function passes extra parameters", {
  x <- c(1, 2, 3)
  h <- hazard_function(x, "normal", mean = 1, sd = 2)
  h_direct <- dnorm(x, mean = 1, sd = 2) / pnorm(x, mean = 1, sd = 2, lower.tail = FALSE)
  expect_equal(h, h_direct, tolerance = 1e-10)
})

# --- compare_mills_hazard() ---

test_that("compare_mills_hazard returns correct structure", {
  x <- c(1, 2, 3)
  result <- compare_mills_hazard(x, "normal")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_true(all(c("x", "mills_ratio", "hazard", "distribution") %in% names(result)))
})

test_that("compare_mills_hazard verifies reciprocal relationship", {
  x <- seq(0.5, 5, by = 0.5)
  result <- compare_mills_hazard(x, "normal")
  product <- result$mills_ratio * result$hazard
  expect_equal(product, rep(1, length(x)), tolerance = 1e-10)
})

test_that("compare_mills_hazard works for all distributions", {
  x <- c(1, 2, 3)
  for (dist in c("normal", "t", "exponential")) {
    args <- list(x = x, distribution = dist)
    if (dist == "t") args$df <- 30
    result <- do.call(compare_mills_hazard, args)
    expect_s3_class(result, "data.frame")
    expect_equal(result$distribution[1], dist)
    # Verify reciprocal
    expect_equal(result$mills_ratio * result$hazard, rep(1, 3), tolerance = 1e-10)
  }
})

test_that("compare_mills_hazard errors on unknown distribution", {
  expect_error(compare_mills_hazard(1, "unknown"), "Unknown distribution")
})

test_that("compare_mills_hazard handles vectorized input", {
  x <- seq(0.1, 10, by = 0.1)
  result <- compare_mills_hazard(x, "normal")
  expect_equal(nrow(result), 100)
  expect_true(all(result$mills_ratio > 0))
  expect_true(all(result$hazard > 0))
})

# --- hazard_properties() ---

test_that("hazard_properties classifies normal as IFR", {
  props <- hazard_properties("normal")
  expect_type(props, "list")
  expect_match(props$behavior, "Increasing")
  expect_equal(props$distribution, "normal")
})

test_that("hazard_properties classifies exponential as CFR", {
  props <- hazard_properties("exponential")
  expect_match(props$behavior, "Constant")
  expect_equal(props$distribution, "exponential")
})

test_that("hazard_properties handles t-distribution with df", {
  props <- hazard_properties("t", df = 30)
  expect_type(props, "list")
  expect_equal(props$distribution, "t")
  # t-distribution hazard is non-monotonic (rises then falls)
  expect_true(nchar(props$behavior) > 0)
})

test_that("hazard_properties returns all expected fields", {
  props <- hazard_properties("normal")
  expect_true(all(c("distribution", "behavior", "asymptotic_behavior",
                     "interpretation") %in% names(props)))
})

test_that("hazard_properties errors on unknown distribution", {
  expect_error(hazard_properties("unknown"), "Unknown distribution")
})
