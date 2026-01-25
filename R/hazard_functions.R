#' Hazard Function Calculations
#'
#' @description
#' Functions for calculating hazard functions and their relationship to Mills ratios.
#' The hazard function h(x) = f(x)/(1-F(x)) is the reciprocal of the Mills ratio m(x).
#'
#' @details
#' The hazard function (also called failure rate or force of mortality) represents
#' the instantaneous rate of occurrence of an event at time x, given survival to time x.
#'
#' Mathematical relationship: h(x) = 1/m(x)
#'
#' @name hazard_functions
NULL

#' Convert Mills Ratio to Hazard Function
#'
#' @param mills_ratio Numeric vector of Mills ratio values
#'
#' @return Numeric vector of hazard function values
#' @export
#'
#' @examples
#' # Normal distribution example
#' x <- seq(0, 5, by = 0.5)
#' m <- mills_ratio_normal(x)
#' h <- hazard_from_mills(m)
#'
#' # Tidyverse example
#' library(dplyr)
#' data.frame(x = x) %>%
#'   mutate(
#'     mills = mills_ratio_normal(x),
#'     hazard = hazard_from_mills(mills)
#'   )
hazard_from_mills <- function(mills_ratio) {
  1 / mills_ratio
}

#' Calculate Hazard Function Directly
#'
#' @param x Numeric vector of values
#' @param distribution Character string: "normal", "t", "exponential"
#' @param ... Additional parameters for the distribution
#'
#' @return Numeric vector of hazard function values
#' @export
#'
#' @examples
#' # Compare hazard functions across distributions
#' x <- seq(0.1, 5, by = 0.1)
#' h_normal <- hazard_function(x, "normal")
#' h_t30 <- hazard_function(x, "t", df = 30)
#' h_exp <- hazard_function(x, "exponential", rate = 1)
#'
#' # Tidyverse comparison
#' library(dplyr)
#' library(tidyr)
#' data.frame(x = x) %>%
#'   mutate(
#'     Normal = hazard_function(x, "normal"),
#'     `t(30)` = hazard_function(x, "t", df = 30),
#'     Exponential = hazard_function(x, "exponential")
#'   ) %>%
#'   pivot_longer(-x, names_to = "distribution", values_to = "hazard")
hazard_function <- function(x, distribution = "normal", ...) {
  # Calculate density
  f <- switch(distribution,
    normal = stats::dnorm(x, ...),
    t = stats::dt(x, ...),
    exponential = stats::dexp(x, ...),
    stop("Unknown distribution: ", distribution)
  )

  # Calculate survival function (1 - CDF)
  survival <- switch(distribution,
    normal = stats::pnorm(x, ..., lower.tail = FALSE),
    t = stats::pt(x, ..., lower.tail = FALSE),
    exponential = stats::pexp(x, ..., lower.tail = FALSE)
  )

  # Return hazard = f(x) / S(x)
  f / survival
}

#' Compare Mills Ratio and Hazard Function
#'
#' @param x Numeric vector of values
#' @param distribution Character string specifying distribution
#' @param ... Additional distribution parameters
#'
#' @return Data frame with x, mills_ratio, and hazard columns
#' @export
#'
#' @examples
#' # Compare for normal distribution
#' compare_mills_hazard(seq(0, 5, by = 0.5), "normal")
#'
#' # Tidyverse visualization
#' library(dplyr)
#' library(ggplot2)
#' compare_mills_hazard(seq(0.1, 5, by = 0.1), "normal") %>%
#'   tidyr::pivot_longer(c(mills_ratio, hazard),
#'                        names_to = "function_type",
#'                        values_to = "value") %>%
#'   ggplot(aes(x, value, color = function_type)) +
#'   geom_line() +
#'   scale_y_log10() +
#'   labs(title = "Mills Ratio vs Hazard Function",
#'        subtitle = "Note: h(x) = 1/m(x)")
compare_mills_hazard <- function(x, distribution = "normal", ...) {
  mills <- switch(distribution,
    normal = mills_ratio_normal(x, ...),
    t = mills_ratio_t(x, ...),
    exponential = mills_ratio_exp(x, ...),
    stop("Unknown distribution: ", distribution)
  )

  data.frame(
    x = x,
    mills_ratio = mills,
    hazard = 1 / mills,
    distribution = distribution
  )
}

#' Hazard Function Properties
#'
#' @description
#' Analyze properties of the hazard function for different distributions.
#'
#' @param distribution Character string: "normal", "t", or "exponential"
#' @param df Degrees of freedom for t-distribution
#'
#' @return List with hazard function properties
#' @export
#'
#' @examples
#' # Analyze normal distribution hazard
#' hazard_properties("normal")
#'
#' # Compare properties across distributions
#' library(purrr)
#' list(
#'   normal = hazard_properties("normal"),
#'   t30 = hazard_properties("t", df = 30),
#'   exponential = hazard_properties("exponential")
#' ) %>%
#'   map_df(~ as.data.frame(.x), .id = "distribution")
hazard_properties <- function(distribution = "normal", df = NULL) {
  x_test <- seq(0.1, 10, by = 0.1)

  h <- if (distribution == "t" && !is.null(df)) {
    hazard_function(x_test, distribution, df = df)
  } else {
    hazard_function(x_test, distribution)
  }

  # Check if hazard is increasing/decreasing
  diffs <- diff(h)

  list(
    distribution = distribution,
    behavior = if (all(diffs > 0)) {
      "Increasing (IFR - Increasing Failure Rate)"
    } else if (all(diffs < 0)) {
      "Decreasing (DFR - Decreasing Failure Rate)"
    } else if (all(abs(diffs) < 1e-10)) {
      "Constant (CFR - Constant Failure Rate)"
    } else {
      "Non-monotonic"
    },
    asymptotic_behavior = switch(distribution,
      normal = "h(x) ~ x as x → ∞",
      t = paste0("h(x) ~ ", df + 1, "/", df, "/x as x → ∞"),
      exponential = "h(x) = constant",
      "Unknown"
    ),
    interpretation = switch(distribution,
      normal = "Aging effect - failure rate increases with x",
      t = "Heavy tails - lower hazard than normal in tails",
      exponential = "Memoryless - constant failure rate",
      "Unknown"
    )
  )
}