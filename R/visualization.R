# Suppress R CMD check notes for dplyr/ggplot2 bare column names
utils::globalVariables(c(

  "x", "y", "value", "mills_ratio", "distribution", "type",
  "mills_normal", "mills_t30", "pdf_normal", "pdf_t30",
  "cdf_normal", "cdf_t30", "dist", "function_type", "metric",
  "panel", "tail_type"
))

#' Visualization Functions for Mills Ratio Analysis
#'
#' @description
#' Functions to create static and interactive visualizations of Mills ratios,
#' supporting both ggplot2 and plotly outputs.
#'
#' @author John Gavin <john.b.gavin@gmail.com>

#' Plot Mills Ratio Curves
#'
#' @param data Data frame from simulate_mills_curves()
#' @param log_y Logical; if TRUE, uses log scale for y-axis
#' @param log_x Logical; if TRUE, uses log scale for x-axis
#' @param interactive Logical; if TRUE, returns plotly object
#' @param title Plot title
#' @param show_asymptotic Logical; if TRUE, shows asymptotic approximations
#'
#' @return ggplot2 or plotly object
#' @export
#'
#' @examples
#' # Generate and plot Mills ratio curves
#' curves <- simulate_mills_curves(distributions = c("normal", "t30", "exponential"))
#' plot_mills_curves(curves, log_y = TRUE)
plot_mills_curves <- function(data,
                             log_y = FALSE,
                             log_x = FALSE,
                             interactive = FALSE,
                             title = "Mills Ratio Comparison",
                             show_asymptotic = TRUE) {

  # Filter data based on asymptotic setting
  if (!show_asymptotic) {
    data <- data[data$type == "exact", ]
  }

  # Create base ggplot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = x, y = mills_ratio,
                                          color = distribution,
                                          linetype = type)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = title,
      x = "x",
      y = "Mills Ratio m(x)",
      color = "Distribution",
      linetype = "Type"
    ) +
    ggplot2::theme(
      legend.position = "bottom",
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      panel.grid.minor = ggplot2::element_blank()
    )

  # Add scale transformations
  if (log_y) {
    p <- p + ggplot2::scale_y_log10(labels = scales::label_number())
  }
  if (log_x) {
    p <- p + ggplot2::scale_x_log10(labels = scales::label_number())
  }

  # Color palette
  p <- p + ggplot2::scale_color_brewer(palette = "Set1")

  # Convert to plotly if requested
  if (interactive) {
    return(plotly::ggplotly(p, tooltip = c("x", "y", "colour")))
  }

  return(p)
}

#' Plot Tail Thickness Heatmap
#'
#' @param x_points Vector of x values
#' @param distributions Vector of distribution names
#' @param interactive Logical; if TRUE, returns plotly object
#'
#' @return ggplot2 or plotly heatmap
#' @export
#'
#' @examples
#' plot_tail_thickness_heatmap(
#'   x_points = seq(1, 5, by = 0.5),
#'   distributions = c("normal", "t3", "t10", "t30", "exponential")
#' )
plot_tail_thickness_heatmap <- function(x_points,
                                       distributions,
                                       interactive = FALSE) {

  # Get Mills ratios
  data <- compare_mills_ratios(x_points, distributions)

  # Reshape for heatmap
  data_long <- tidyr::pivot_longer(
    data,
    cols = -x,
    names_to = "distribution",
    values_to = "mills_ratio"
  )

  # Clean distribution names
  data_long$distribution <- gsub("t_df", "t", data_long$distribution)

  # Create heatmap
  p <- ggplot2::ggplot(data_long,
                       ggplot2::aes(x = factor(x), y = distribution,
                                   fill = log10(mills_ratio))) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_gradient2(
      low = "blue", mid = "white", high = "red",
      midpoint = 0,
      name = "log10(m(x))"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "Mills Ratio Heatmap: Tail Thickness Comparison",
      x = "x",
      y = "Distribution"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      axis.text.x = ggplot2::element_text(angle = 0),
      panel.grid = ggplot2::element_blank()
    )

  # Add text annotations
  p <- p + ggplot2::geom_text(
    ggplot2::aes(label = sprintf("%.2f", mills_ratio)),
    size = 3
  )

  if (interactive) {
    return(plotly::ggplotly(p))
  }

  return(p)
}

#' Plot t(30) Paradox Visualization
#'
#' @param data Data frame from analyze_t30_paradox()
#' @param focus Character: "mills", "pdf", "cdf", or "all"
#' @param interactive Logical; if TRUE, returns plotly object
#'
#' @return ggplot2 or plotly object
#' @export
#'
#' @examples
#' paradox_data <- analyze_t30_paradox()
#' plot_t30_paradox(paradox_data, focus = "mills")
plot_t30_paradox <- function(data, focus = "mills", interactive = FALSE) {

  if (focus == "mills") {
    # Mills ratio comparison
    p <- ggplot2::ggplot(data, ggplot2::aes(x = x)) +
      ggplot2::geom_line(ggplot2::aes(y = mills_normal, color = "Normal"),
                        linewidth = 1.2) +
      ggplot2::geom_line(ggplot2::aes(y = mills_t30, color = "t(30)"),
                        linewidth = 1.2) +
      ggplot2::scale_color_manual(
        values = c("Normal" = "#1f77b4", "t(30)" = "#ff7f0e"),
        name = "Distribution"
      ) +
      ggplot2::labs(
        title = "The t(30) Paradox: Mills Ratios",
        x = "x",
        y = "Mills Ratio m(x)"
      )

  } else if (focus == "pdf") {
    # PDF comparison
    p <- ggplot2::ggplot(data, ggplot2::aes(x = x)) +
      ggplot2::geom_line(ggplot2::aes(y = pdf_normal, color = "Normal"),
                        linewidth = 1.2) +
      ggplot2::geom_line(ggplot2::aes(y = pdf_t30, color = "t(30)"),
                        linewidth = 1.2) +
      ggplot2::scale_color_manual(
        values = c("Normal" = "#1f77b4", "t(30)" = "#ff7f0e"),
        name = "Distribution"
      ) +
      ggplot2::labs(
        title = "The t(30) Paradox: Probability Density Functions",
        x = "x",
        y = "PDF f(x)"
      )

  } else if (focus == "cdf") {
    # CDF comparison with similarity zones
    p <- ggplot2::ggplot(data, ggplot2::aes(x = x)) +
      ggplot2::geom_ribbon(
        data = data[data$similarity_zone == "similar", ],
        ggplot2::aes(ymin = 0, ymax = 1),
        fill = "green", alpha = 0.1
      ) +
      ggplot2::geom_line(ggplot2::aes(y = cdf_normal, color = "Normal"),
                        linewidth = 1.2) +
      ggplot2::geom_line(ggplot2::aes(y = cdf_t30, color = "t(30)"),
                        linewidth = 1.2) +
      ggplot2::scale_color_manual(
        values = c("Normal" = "#1f77b4", "t(30)" = "#ff7f0e"),
        name = "Distribution"
      ) +
      ggplot2::labs(
        title = "The t(30) Paradox: Cumulative Distribution Functions",
        subtitle = "Green zones indicate high similarity",
        x = "x",
        y = "CDF F(x)"
      )

  } else if (focus == "all") {
    # Create faceted plot
    data_mills <- data.frame(x = data$x, value = data$mills_normal,
                             dist = "Normal", metric = "Mills Ratio")
    data_mills <- rbind(data_mills,
                        data.frame(x = data$x, value = data$mills_t30,
                                  dist = "t(30)", metric = "Mills Ratio"))
    data_pdf <- data.frame(x = data$x, value = data$pdf_normal,
                           dist = "Normal", metric = "PDF")
    data_pdf <- rbind(data_pdf,
                      data.frame(x = data$x, value = data$pdf_t30,
                                dist = "t(30)", metric = "PDF"))
    data_cdf <- data.frame(x = data$x, value = data$cdf_normal,
                           dist = "Normal", metric = "CDF")
    data_cdf <- rbind(data_cdf,
                      data.frame(x = data$x, value = data$cdf_t30,
                                dist = "t(30)", metric = "CDF"))

    data_all <- rbind(data_mills, data_pdf, data_cdf)

    p <- ggplot2::ggplot(data_all, ggplot2::aes(x = x, y = value, color = dist)) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::facet_wrap(~metric, scales = "free_y", ncol = 1) +
      ggplot2::scale_color_manual(
        values = c("Normal" = "#1f77b4", "t(30)" = "#ff7f0e"),
        name = "Distribution"
      ) +
      ggplot2::labs(
        title = "The t(30) Paradox: Complete Comparison",
        x = "x"
      )
  }

  # Common theme
  p <- p +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      legend.position = "bottom"
    )

  if (interactive) {
    return(plotly::ggplotly(p))
  }

  return(p)
}

#' Plot Mills Ratio Comparison
#'
#' @param x_range Range of x values
#' @param dist1 First distribution
#' @param dist2 Second distribution
#' @param df1 Degrees of freedom for first distribution
#' @param df2 Degrees of freedom for second distribution
#' @param show_ratio Logical; if TRUE, shows ratio plot
#'
#' @return ggplot2 object
#' @export
#'
#' @examples
#' plot_mills_comparison(c(0, 5), "t", "normal", df1 = 30)
plot_mills_comparison <- function(x_range = c(0, 5),
                                 dist1, dist2,
                                 df1 = NULL, df2 = NULL,
                                 show_ratio = TRUE) {

  x_vals <- seq(x_range[1], x_range[2], length.out = 200)

  # Calculate Mills ratios
  if (dist1 == "normal") {
    m1 <- mills_ratio_normal(x_vals)
    label1 <- "Normal"
  } else if (dist1 == "t") {
    m1 <- mills_ratio_t(x_vals, df = df1)
    label1 <- paste0("t(", df1, ")")
  } else if (dist1 == "exponential") {
    m1 <- mills_ratio_exp(x_vals)
    label1 <- "Exponential"
  }

  if (dist2 == "normal") {
    m2 <- mills_ratio_normal(x_vals)
    label2 <- "Normal"
  } else if (dist2 == "t") {
    m2 <- mills_ratio_t(x_vals, df = df2)
    label2 <- paste0("t(", df2, ")")
  } else if (dist2 == "exponential") {
    m2 <- mills_ratio_exp(x_vals)
    label2 <- "Exponential"
  }

  if (show_ratio) {
    # Create two-panel plot
    data_mills <- data.frame(
      x = rep(x_vals, 2),
      value = c(m1, m2),
      distribution = rep(c(label1, label2), each = length(x_vals)),
      panel = "Mills Ratios"
    )

    data_ratio <- data.frame(
      x = x_vals,
      value = m1 / m2,
      distribution = paste0(label1, "/", label2),
      panel = "Ratio"
    )

    data_all <- rbind(data_mills, data_ratio)

    p <- ggplot2::ggplot(data_all, ggplot2::aes(x = x, y = value,
                                                color = distribution)) +
      ggplot2::geom_line(linewidth = 1.2) +
      ggplot2::facet_wrap(~panel, scales = "free_y", nrow = 2) +
      ggplot2::geom_hline(data = data.frame(panel = "Ratio", y = 1),
                          ggplot2::aes(yintercept = y),
                          linetype = "dashed", alpha = 0.5) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::labs(
        title = paste("Mills Ratio Comparison:", label1, "vs", label2),
        x = "x",
        y = "Value",
        color = "Distribution"
      )

  } else {
    # Single panel plot
    data <- data.frame(
      x = rep(x_vals, 2),
      mills_ratio = c(m1, m2),
      distribution = rep(c(label1, label2), each = length(x_vals))
    )

    p <- ggplot2::ggplot(data, ggplot2::aes(x = x, y = mills_ratio,
                                            color = distribution)) +
      ggplot2::geom_line(linewidth = 1.2) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::labs(
        title = paste("Mills Ratio Comparison:", label1, "vs", label2),
        x = "x",
        y = "Mills Ratio m(x)",
        color = "Distribution"
      )
  }

  p <- p +
    ggplot2::scale_color_brewer(palette = "Set1") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      legend.position = "bottom"
    )

  return(p)
}

#' Plot Mills Ratio vs Hazard Function Side-by-Side
#'
#' @param x_range Numeric vector of length 2 giving the range of x values
#' @param distributions Character vector of distribution names
#'   (e.g., c("normal", "t30", "exponential"))
#' @param n_points Number of points to compute (default 200)
#' @param interactive Logical; if TRUE, returns plotly object
#' @param log_y Logical; if TRUE, uses log scale for y-axis
#'
#' @return ggplot2 or plotly object with faceted m(x) and h(x) panels
#' @export
#'
#' @examples
#' plot_mills_vs_hazard()
#' plot_mills_vs_hazard(x_range = c(0.5, 8), distributions = c("normal", "t30"))
plot_mills_vs_hazard <- function(x_range = c(0.1, 5),
                                 distributions = c("normal", "t30", "exponential"),
                                 n_points = 200,
                                 interactive = FALSE,
                                 log_y = TRUE) {

  x_vals <- seq(x_range[1], x_range[2], length.out = n_points)

  # Build data for each distribution using compare_mills_hazard
  data_list <- lapply(distributions, function(dist) {
    if (grepl("^t\\d+$", dist)) {
      df_val <- as.numeric(sub("^t", "", dist))
      result <- compare_mills_hazard(x_vals, "t", df = df_val)
      result$distribution <- paste0("t(", df_val, ")")
    } else {
      result <- compare_mills_hazard(x_vals, dist)
      result$distribution <- switch(dist,
        normal = "Normal",
        exponential = "Exponential",
        dist
      )
    }
    result
  })
  data_wide <- do.call(rbind, data_list)

  # Pivot to long for faceting
  data_long <- tidyr::pivot_longer(
    data_wide,
    cols = c("mills_ratio", "hazard"),
    names_to = "function_type",
    values_to = "value"
  )
  data_long$function_type <- ifelse(
    data_long$function_type == "mills_ratio",
    "Mills Ratio m(x)",
    "Hazard h(x)"
  )

  p <- ggplot2::ggplot(data_long,
    ggplot2::aes(x = x, y = value, color = distribution)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::facet_wrap(~function_type, scales = "free_y") +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "Mills Ratio vs Hazard Function",
      subtitle = "h(x) = 1/m(x) for all distributions",
      x = "x",
      y = "Value",
      color = "Distribution"
    ) +
    ggplot2::scale_color_brewer(palette = "Set1") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, face = "bold"),
      legend.position = "bottom"
    )

  if (log_y) {
    p <- p + ggplot2::scale_y_log10(labels = scales::label_number())
  }

  if (interactive) {
    return(plotly::ggplotly(p, tooltip = c("x", "y", "colour")))
  }

  return(p)
}