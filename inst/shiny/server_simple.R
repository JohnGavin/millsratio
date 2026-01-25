# Simplified Server Logic - Focus on Functionality

library(shiny)
library(millsratio)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)

server <- function(input, output, session) {

  # Reactive data generation
  mills_data <- reactive({
    req(input$dist_compare)

    x <- seq(input$x_range[1], input$x_range[2], length.out = 100)
    data <- list()

    for (dist in input$dist_compare) {
      if (dist == "normal") {
        data[[dist]] <- tibble(
          x = x,
          mills_ratio = mills_ratio_normal(x),
          distribution = "Normal"
        )
      } else if (dist == "exp") {
        data[[dist]] <- tibble(
          x = x,
          mills_ratio = mills_ratio_exp(x),
          distribution = "Exponential"
        )
      } else if (grepl("^t", dist)) {
        df <- as.numeric(sub("^t", "", dist))
        data[[dist]] <- tibble(
          x = x,
          mills_ratio = mills_ratio_t(x, df = df),
          distribution = paste0("t(", df, ")")
        )
      }
    }

    bind_rows(data)
  })

  # Main plot
  output$main_plot <- renderPlotly({
    data <- mills_data()

    p <- plot_ly()

    for (dist in unique(data$distribution)) {
      dist_data <- filter(data, distribution == dist)
      p <- p %>%
        add_trace(
          x = dist_data$x,
          y = dist_data$mills_ratio,
          name = dist,
          type = 'scatter',
          mode = 'lines',
          line = list(width = 2)
        )
    }

    if (input$log_scale) {
      p <- p %>% layout(yaxis = list(type = "log", title = "Mills Ratio m(x) (log scale)"))
    } else {
      p <- p %>% layout(yaxis = list(title = "Mills Ratio m(x)"))
    }

    p %>% layout(
      xaxis = list(title = "x"),
      title = "Mills Ratio Comparison",
      hovermode = "x unified",
      legend = list(orientation = "h", y = -0.2)
    )
  })

  # Comparison table
  output$comparison_table <- renderDT({
    req(input$dist_compare)

    x_points <- c(1, 2, 3, 4, 5)
    results <- list()

    for (dist in input$dist_compare) {
      if (dist == "normal") {
        results[[dist]] <- mills_ratio_normal(x_points)
      } else if (dist == "exp") {
        results[[dist]] <- mills_ratio_exp(x_points)
      } else if (grepl("^t", dist)) {
        df <- as.numeric(sub("^t", "", dist))
        results[[dist]] <- mills_ratio_t(x_points, df = df)
      }
    }

    # Create table
    table_data <- data.frame(x = x_points)
    for (name in names(results)) {
      col_name <- switch(name,
                        "normal" = "Normal",
                        "exp" = "Exponential",
                        paste0("t(", sub("^t", "", name), ")"))
      table_data[[col_name]] <- round(results[[name]], 4)
    }

    # Add ratios if normal is selected
    if ("normal" %in% names(results) && length(results) > 1) {
      for (name in setdiff(names(results), "normal")) {
        col_name <- switch(name,
                          "exp" = "Exp/Normal",
                          paste0("t(", sub("^t", "", name), ")/Normal"))
        table_data[[col_name]] <- round(results[[name]] / results[["normal"]], 3)
      }
    }

    datatable(
      table_data,
      options = list(
        dom = 't',
        paging = FALSE,
        searching = FALSE
      ),
      rownames = FALSE
    ) %>%
      formatRound(columns = -1, digits = 4)
  })

  # Hazard Function Page Outputs
  output$hazard_plot <- renderPlotly({
    req(input$hazard_dist, input$hazard_range)

    x <- seq(input$hazard_range[1], input$hazard_range[2], length.out = 100)

    # Calculate Mills ratio and hazard
    if (input$hazard_dist == "normal") {
      mills <- mills_ratio_normal(x)
      dist_label <- "Normal"
    } else if (input$hazard_dist == "exp") {
      mills <- mills_ratio_exp(x)
      dist_label <- "Exponential"
    } else if (grepl("^t", input$hazard_dist)) {
      df <- as.numeric(sub("^t", "", input$hazard_dist))
      mills <- mills_ratio_t(x, df = df)
      dist_label <- paste0("t(", df, ")")
    }

    hazard <- 1 / mills

    p <- plot_ly()

    if (input$show_both) {
      # Show both functions
      p <- p %>%
        add_trace(x = x, y = mills, name = "Mills ratio m(x)",
                  type = "scatter", mode = "lines",
                  line = list(color = "#2c3e50", width = 2)) %>%
        add_trace(x = x, y = hazard, name = "Hazard h(x) = 1/m(x)",
                  type = "scatter", mode = "lines",
                  line = list(color = "#e74c3c", width = 2, dash = "dash"))

      y_title <- "Value"
    } else {
      # Show only hazard
      p <- p %>%
        add_trace(x = x, y = hazard, name = "Hazard h(x)",
                  type = "scatter", mode = "lines",
                  line = list(color = "#e74c3c", width = 2))

      y_title <- "Hazard h(x)"
    }

    p %>% layout(
      title = paste(dist_label, "Distribution"),
      xaxis = list(title = "x"),
      yaxis = list(title = y_title, type = "log"),
      hovermode = "x unified",
      legend = list(orientation = "h", y = -0.2)
    )
  })

  output$hazard_properties <- renderText({
    req(input$hazard_dist)

    if (input$hazard_dist == "normal") {
      "Normal: Increasing hazard (IFR) - aging effect. As x increases, failure becomes more likely."
    } else if (input$hazard_dist == "exp") {
      "Exponential: Constant hazard (CFR) - memoryless property. Failure rate doesn't depend on age."
    } else if (input$hazard_dist == "t3") {
      "t(3): Eventually decreasing hazard - heavy tails. Extreme events become relatively less likely."
    } else if (input$hazard_dist == "t30") {
      "t(30): Nearly normal centrally, but decreasing hazard in tails due to heavier tails than normal."
    }
  })
}