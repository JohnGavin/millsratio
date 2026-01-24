#' Mills Ratio Functions for Various Distributions
#'
#' @description
#' Functions to compute Mills ratios for different probability distributions.
#' The Mills ratio m(x) is defined as the ratio of the complementary cumulative
#' distribution function (CCDF) to the probability density function (PDF):
#' m(x) = \\[1 - F(x)\\] / f(x)
#'
#' @author John Gavin <john.b.gavin@gmail.com>

#' Compute Mills Ratio for Normal Distribution
#'
#' @param x Numeric vector of quantiles
#' @param mean Mean of the distribution (default = 0)
#' @param sd Standard deviation (default = 1)
#' @param log Logical; if TRUE, returns log(Mills ratio) for numerical stability
#'
#' @return Numeric vector of Mills ratios
#' @export
#'
#' @examples
#' # Standard normal Mills ratio at x = 2
#' mills_ratio_normal(2)
#'
#' # Multiple values
#' mills_ratio_normal(c(1, 2, 3, 4))
#'
#' # Log Mills ratio for extreme values
#' mills_ratio_normal(10, log = TRUE)
mills_ratio_normal <- function(x, mean = 0, sd = 1, log = FALSE) {
  # Standardize
  z <- (x - mean) / sd

  if (log) {
    # Use log for numerical stability in extreme tails
    log_mills <- stats::pnorm(z, lower.tail = FALSE, log.p = TRUE) -
                 stats::dnorm(z, log = TRUE)
    return(log_mills)
  } else {
    # Standard calculation
    mills <- stats::pnorm(z, lower.tail = FALSE) / stats::dnorm(z)
    return(mills)
  }
}

#' Compute Mills Ratio for Student's t Distribution
#'
#' @param x Numeric vector of quantiles
#' @param df Degrees of freedom (> 0)
#' @param log Logical; if TRUE, returns log(Mills ratio)
#'
#' @return Numeric vector of Mills ratios
#' @export
#'
#' @examples
#' # t-distribution with df = 30 at x = 2
#' mills_ratio_t(2, df = 30)
#'
#' # Compare different degrees of freedom
#' x_vals <- seq(0, 5, by = 0.5)
#' m_t3 <- mills_ratio_t(x_vals, df = 3)
#' m_t30 <- mills_ratio_t(x_vals, df = 30)
mills_ratio_t <- function(x, df, log = FALSE) {
  if (missing(df) || df <= 0) {
    stop("Degrees of freedom (df) must be positive")
  }

  if (log) {
    # Log Mills ratio for numerical stability
    log_mills <- stats::pt(x, df = df, lower.tail = FALSE, log.p = TRUE) -
                 stats::dt(x, df = df, log = TRUE)
    return(log_mills)
  } else {
    # Standard calculation
    mills <- stats::pt(x, df = df, lower.tail = FALSE) / stats::dt(x, df = df)
    return(mills)
  }
}

#' Compute Mills Ratio for Exponential Distribution
#'
#' @param x Numeric vector of quantiles
#' @param rate Rate parameter (> 0)
#' @param log Logical; if TRUE, returns log(Mills ratio)
#'
#' @return Numeric vector of Mills ratios
#' @export
#'
#' @examples
#' # Exponential with rate = 1 at x = 2
#' mills_ratio_exp(2, rate = 1)
#'
#' # Mills ratio is constant for exponential!
#' mills_ratio_exp(c(1, 2, 3, 4), rate = 1)
mills_ratio_exp <- function(x, rate = 1, log = FALSE) {
  if (rate <= 0) {
    stop("Rate parameter must be positive")
  }

  # For exponential distribution, Mills ratio is constant = 1/rate
  # This is because CCDF = exp(-rate*x) and PDF = rate*exp(-rate*x)
  # So Mills = exp(-rate*x) / (rate*exp(-rate*x)) = 1/rate

  n <- length(x)
  mills <- rep(1/rate, n)

  # Handle x < 0 (outside support)
  mills[x < 0] <- NA

  if (log) {
    return(log(mills))
  } else {
    return(mills)
  }
}

#' Generic Mills Ratio Function
#'
#' @param x Numeric vector of quantiles
#' @param cdf_fun CDF function (must accept lower.tail and log.p arguments)
#' @param pdf_fun PDF function (must accept log argument)
#' @param log Logical; if TRUE, returns log(Mills ratio)
#' @param ... Additional arguments passed to cdf_fun and pdf_fun
#'
#' @return Numeric vector of Mills ratios
#' @export
#'
#' @examples
#' # Using generic function for normal distribution
#' mills_ratio_generic(2, cdf_fun = pnorm, pdf_fun = dnorm)
#'
#' # Using for custom distribution
#' # mills_ratio_generic(x, cdf_fun = my_cdf, pdf_fun = my_pdf, param1 = value1)
mills_ratio_generic <- function(x, cdf_fun, pdf_fun, log = FALSE, ...) {
  if (log) {
    # Use log for numerical stability
    log_ccdf <- cdf_fun(x, ..., lower.tail = FALSE, log.p = TRUE)
    log_pdf <- pdf_fun(x, ..., log = TRUE)
    return(log_ccdf - log_pdf)
  } else {
    # Standard calculation
    ccdf <- cdf_fun(x, ..., lower.tail = FALSE)
    pdf <- pdf_fun(x, ...)
    return(ccdf / pdf)
  }
}

#' Compare Mills Ratios Across Distributions
#'
#' @param x Numeric vector of quantiles
#' @param distributions Character vector of distribution names
#'   ("normal", "t3", "t10", "t30", "exponential")
#'
#' @return Data frame with Mills ratios for each distribution
#' @export
#'
#' @examples
#' x_vals <- c(1, 2, 3, 4)
#' compare_mills_ratios(x_vals, c("normal", "t30", "exponential"))
compare_mills_ratios <- function(x, distributions = c("normal", "t30", "exponential")) {

  results <- data.frame(x = x)

  for (dist in distributions) {
    if (dist == "normal") {
      results$normal <- mills_ratio_normal(x)
    } else if (dist == "exponential") {
      results$exponential <- mills_ratio_exp(x)
    } else if (grepl("^t\\d+$", dist)) {
      # Extract df from distribution name like "t3", "t10", "t30"
      df <- as.numeric(sub("^t", "", dist))
      col_name <- paste0("t_df", df)
      results[[col_name]] <- mills_ratio_t(x, df = df)
    } else {
      warning(paste("Unknown distribution:", dist))
    }
  }

  return(results)
}

#' Calculate Asymptotic Approximation of Mills Ratio
#'
#' @param x Numeric vector of quantiles
#' @param distribution Character string: "normal", "t", or "exponential"
#' @param df Degrees of freedom for t-distribution
#'
#' @return Numeric vector of asymptotic approximations
#' @export
#'
#' @examples
#' # Normal asymptotic approximation (1/x for large x)
#' mills_asymptotic(10, "normal")
#'
#' # Student's t asymptotic approximation (x/df for large x)
#' mills_asymptotic(10, "t", df = 30)
mills_asymptotic <- function(x, distribution, df = NULL) {

  if (distribution == "normal") {
    # For normal: m(x) ~ 1/x as x -> infinity
    return(1/x)
  } else if (distribution == "t") {
    if (is.null(df)) {
      stop("Degrees of freedom (df) required for t-distribution")
    }
    # For t-distribution: m(x) ~ x/df as x -> infinity
    return(x/df)
  } else if (distribution == "exponential") {
    # For exponential: m(x) = constant = 1/rate
    # Default rate = 1
    return(rep(1, length(x)))
  } else {
    stop("Unknown distribution. Choose 'normal', 't', or 'exponential'")
  }
}

#' Compute Ratio of Mills Ratios
#'
#' @param x Numeric vector of quantiles
#' @param dist1 First distribution ("normal", "t", "exponential")
#' @param dist2 Second distribution ("normal", "t", "exponential")
#' @param df1 Degrees of freedom for first distribution (if t)
#' @param df2 Degrees of freedom for second distribution (if t)
#'
#' @return Numeric vector of ratios m1(x)/m2(x)
#' @export
#'
#' @examples
#' # Ratio of t(30) to normal Mills ratios
#' x_vals <- seq(1, 5, by = 0.5)
#' ratio <- mills_ratio_comparison(x_vals, "t", "normal", df1 = 30)
mills_ratio_comparison <- function(x, dist1, dist2, df1 = NULL, df2 = NULL) {

  # Calculate Mills ratio for first distribution
  if (dist1 == "normal") {
    m1 <- mills_ratio_normal(x)
  } else if (dist1 == "t") {
    if (is.null(df1)) stop("df1 required for t-distribution")
    m1 <- mills_ratio_t(x, df = df1)
  } else if (dist1 == "exponential") {
    m1 <- mills_ratio_exp(x)
  } else {
    stop("Unknown distribution for dist1")
  }

  # Calculate Mills ratio for second distribution
  if (dist2 == "normal") {
    m2 <- mills_ratio_normal(x)
  } else if (dist2 == "t") {
    if (is.null(df2)) stop("df2 required for t-distribution")
    m2 <- mills_ratio_t(x, df = df2)
  } else if (dist2 == "exponential") {
    m2 <- mills_ratio_exp(x)
  } else {
    stop("Unknown distribution for dist2")
  }

  return(m1 / m2)
}
