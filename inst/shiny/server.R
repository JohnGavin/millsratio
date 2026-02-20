# Dashboard Server Logic

# Ensure required packages are loaded
library(shiny)
library(bslib)
library(plotly)
library(DT)
library(millsratio)
library(dplyr)
library(tidyr)
library(ggplot2)

server <- function(input, output, session) {

  # Reactive values for sharing data across pages
  values <- reactiveValues(
    current_x = 2,
    current_dist = "normal"
  )

  # Page navigation
  observeEvent(input$go_to_normal, {
    nav_select("main_nav", selected = "Normal Distribution")
  })

  observeEvent(input$go_to_theory, {
    nav_select("main_nav", selected = "Definitions")
  })

  observeEvent(input$go_to_playground, {
    nav_select("main_nav", selected = "Custom Analysis")
  })

  # ============================================================================
  # Page 1: Welcome
  # ============================================================================

  output$welcome_plot <- renderPlotly({
    x <- seq(0, 5, length.out = 100)
    m_normal <- mills_ratio_normal(x)
    m_t30 <- mills_ratio_t(x, df = 30)

    plot_ly() %>%
      add_trace(x = x, y = m_normal, name = "Normal",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(x = x, y = m_t30, name = "t(30)",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545", width = 2)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Mills Ratio m(x)"),
        hovermode = "x unified",
        showlegend = TRUE,
        margin = list(t = 10)
      )
  })

  # ============================================================================
  # Page 2: Normal Distribution
  # ============================================================================

  output$normal_mills_plot <- renderPlotly({
    x <- seq(input$normal_x_range[1], input$normal_x_range[2], length.out = 200)
    m_exact <- mills_ratio_normal(x)

    p <- plot_ly()

    # Exact Mills ratio
    p <- p %>% add_trace(x = x, y = m_exact, name = "Exact",
                         type = "scatter", mode = "lines",
                         line = list(color = "#0d6efd", width = 2))

    # Asymptotic approximation
    if (input$normal_show_asymptotic) {
      m_asymp <- 1/x
      p <- p %>% add_trace(x = x, y = m_asymp, name = "Asymptotic (1/x)",
                           type = "scatter", mode = "lines",
                           line = list(color = "#6c757d", width = 2, dash = "dash"))
    }

    # Apply log scales if requested
    yaxis_type <- if (input$normal_log_y) "log" else "linear"
    xaxis_type <- if (input$normal_log_x) "log" else "linear"

    p %>% layout(
      xaxis = list(title = "x", type = xaxis_type),
      yaxis = list(title = "Mills Ratio m(x)", type = yaxis_type),
      hovermode = "x unified",
      title = "Normal Distribution Mills Ratio"
    )
  })

  output$normal_value_box <- renderUI({
    x_mid <- mean(input$normal_x_range)
    m_val <- mills_ratio_normal(x_mid)
    div(
      class = "alert alert-info",
      strong(sprintf("At x = %.1f:", x_mid)),
      br(),
      sprintf("Mills ratio = %.4f", m_val),
      br(),
      sprintf("Asymptotic (1/x) = %.4f", 1/x_mid)
    )
  })

  # ============================================================================
  # Page 3: Student's t Distribution
  # ============================================================================

  output$t_mills_plot <- renderPlotly({
    x <- seq(0.1, 5, length.out = 200)

    p <- plot_ly()

    # Current df from slider
    m_current <- mills_ratio_t(x, df = input$t_df_slider)
    p <- p %>% add_trace(x = x, y = m_current,
                         name = paste0("t(", input$t_df_slider, ")"),
                         type = "scatter", mode = "lines",
                         line = list(color = "#dc3545", width = 3))

    # Comparison distributions
    colors <- c("3" = "#0d6efd", "10" = "#6f42c1", "30" = "#fd7e14", "inf" = "#212529")
    for (df_val in input$t_df_compare) {
      if (df_val == "inf") {
        m_comp <- mills_ratio_normal(x)
        name_comp <- "Normal"
      } else {
        df_num <- as.numeric(df_val)
        if (df_num != input$t_df_slider) {
          m_comp <- mills_ratio_t(x, df = df_num)
          name_comp <- paste0("t(", df_val, ")")
        } else {
          next
        }
      }
      p <- p %>% add_trace(x = x, y = m_comp, name = name_comp,
                           type = "scatter", mode = "lines",
                           line = list(color = colors[df_val], width = 2, dash = "dot"))
    }

    # Asymptotic approximation
    if (input$t_show_asymptotic && input$t_df_slider < 100) {
      m_asymp <- x / input$t_df_slider
      p <- p %>% add_trace(x = x, y = m_asymp,
                           name = paste0("Asymptotic (x/", input$t_df_slider, ")"),
                           type = "scatter", mode = "lines",
                           line = list(color = "#6c757d", width = 1, dash = "dash"))
    }

    p %>% layout(
      xaxis = list(title = "x"),
      yaxis = list(title = "Mills Ratio m(x)"),
      hovermode = "x unified",
      title = "Student's t Distribution Mills Ratios"
    )
  })

  output$t_value_box <- renderUI({
    x_test <- 3
    m_val <- mills_ratio_t(x_test, df = input$t_df_slider)
    m_normal <- mills_ratio_normal(x_test)
    div(
      class = "alert alert-info",
      strong(sprintf("At x = %d, df = %d:", x_test, input$t_df_slider)),
      br(),
      sprintf("t(%d) Mills ratio = %.4f", input$t_df_slider, m_val),
      br(),
      sprintf("Normal Mills ratio = %.4f", m_normal),
      br(),
      sprintf("Ratio t/Normal = %.2f", m_val / m_normal)
    )
  })

  # ============================================================================
  # Page 4: Distribution Comparison
  # ============================================================================

  comparison_data <- reactive({
    simulate_mills_curves(
      x_range = input$compare_x_range,
      n_points = 100,
      distributions = input$compare_dists,
      include_asymptotic = FALSE
    )
  })

  output$comparison_mills_plot <- renderPlotly({
    data <- comparison_data()

    plot_ly(data, x = ~x, y = ~mills_ratio, color = ~distribution,
            type = "scatter", mode = "lines") %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Mills Ratio m(x)", type = "log"),
        title = "Mills Ratio Comparison"
      )
  })

  output$comparison_ratio_plot <- renderPlotly({
    data <- comparison_data()

    if (nrow(data) == 0) {
      return(plot_ly() %>%
               add_annotations(
                 text = "Select distributions to compare",
                 xref = "paper", yref = "paper",
                 x = 0.5, y = 0.5, showarrow = FALSE
               ))
    }

    baseline_dist <- if (input$compare_baseline == "normal") {
      "Normal"
    } else {
      unique(data$distribution)[1]
    }

    wide_data <- data %>%
      select(x, distribution, mills_ratio) %>%
      pivot_wider(names_from = distribution, values_from = mills_ratio)

    if (!baseline_dist %in% names(wide_data)) {
      return(plot_ly() %>%
               add_annotations(
                 text = paste("Baseline", baseline_dist, "not available"),
                 xref = "paper", yref = "paper",
                 x = 0.5, y = 0.5, showarrow = FALSE
               ))
    }

    baseline_col <- wide_data[[baseline_dist]]

    p <- plot_ly()
    for (col_name in setdiff(names(wide_data)[-1], baseline_dist)) {
      if (!is.null(wide_data[[col_name]]) && length(wide_data[[col_name]]) > 0) {
        ratio <- wide_data[[col_name]] / baseline_col
        p <- p %>% add_trace(x = wide_data$x, y = ratio,
                             name = paste0(col_name, "/", baseline_dist),
                             type = "scatter", mode = "lines")
      }
    }

    p %>%
      add_trace(x = wide_data$x, y = rep(1, nrow(wide_data)),
                name = "Reference (1.0)",
                type = "scatter", mode = "lines",
                line = list(color = "gray", dash = "dash")) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Ratio relative to baseline"),
        title = paste("Ratios relative to", baseline_dist)
      )
  })

  # ============================================================================
  # Page 5: Tail Thickness Analyzer
  # ============================================================================

  thickness_data <- reactive({
    x_points <- seq(input$thickness_x_points[1],
                    input$thickness_x_points[2],
                    by = 0.5)
    analyze_tail_thickness(
      x_points = x_points,
      distributions = c("normal", "t3", "t10", "t30", "exponential"),
      compute_ratios = TRUE
    )
  })

  output$thickness_heatmap <- renderPlotly({
    data <- thickness_data()

    mills_cols <- c("normal", "t_df3", "t_df10", "t_df30", "exponential")
    mills_data <- as.matrix(data[, mills_cols])
    rownames(mills_data) <- data$x

    plot_ly(
      z = t(log10(mills_data)),
      x = data$x,
      y = c("Normal", "t(3)", "t(10)", "t(30)", "Exponential"),
      type = "heatmap",
      colorscale = "RdBu",
      reversescale = TRUE,
      hovertemplate = "x: %{x}<br>Distribution: %{y}<br>log10(m(x)): %{z:.2f}<extra></extra>"
    ) %>%
      layout(
        title = "Mills Ratio Heatmap (log10 scale)",
        xaxis = list(title = "x"),
        yaxis = list(title = "Distribution")
      )
  })

  output$thickness_table <- renderDT({
    data <- thickness_data()
    data %>%
      select(x, normal, t_df30, exponential,
             t_df30_to_normal_ratio, exponential_to_normal_ratio) %>%
      mutate(across(where(is.numeric), ~round(.x, 4))) %>%
      datatable(
        options = list(
          pageLength = 10,
          dom = "t",
          ordering = TRUE
        ),
        rownames = FALSE
      )
  })

  output$download_thickness <- downloadHandler(
    filename = function() {
      paste0("mills_ratio_analysis_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(thickness_data(), file, row.names = FALSE)
    }
  )

  # ============================================================================
  # Page 6: t(30) Paradox
  # ============================================================================

  paradox_data <- reactive({
    analyze_t30_paradox(x_range = c(0, 5), n_points = 200)
  })

  output$paradox_mills <- renderPlotly({
    data <- paradox_data()
    focus_x <- input$paradox_x_focus

    plot_ly(data, x = ~x) %>%
      add_trace(y = ~mills_normal, name = "Normal",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(y = ~mills_t30, name = "t(30)",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545", width = 2)) %>%
      add_trace(x = c(focus_x, focus_x), y = c(0, 2),
                type = "scatter", mode = "lines",
                line = list(color = "gray", dash = "dash"),
                showlegend = FALSE) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Mills Ratio m(x)"),
        title = "Mills Ratio: t(30) vs Normal"
      )
  })

  output$paradox_pdf <- renderPlotly({
    data <- paradox_data()

    plot_ly(data, x = ~x) %>%
      add_trace(y = ~pdf_normal, name = "Normal PDF",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(y = ~pdf_t30, name = "t(30) PDF",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545", width = 2)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Probability Density"),
        title = "PDF Comparison: Nearly Identical"
      )
  })

  output$paradox_cdf <- renderPlotly({
    data <- paradox_data()

    plot_ly(data, x = ~x) %>%
      add_trace(y = ~cdf_normal, name = "Normal CDF",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(y = ~cdf_t30, name = "t(30) CDF",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545", width = 2)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Cumulative Probability"),
        title = "CDF Comparison: Highly Similar"
      )
  })

  output$paradox_all <- renderPlotly({
    data <- paradox_data()

    # Create 4-panel subplot
    p1 <- plot_ly(data, x = ~x) %>%
      add_trace(y = ~pdf_normal, name = "Normal PDF",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd")) %>%
      add_trace(y = ~pdf_t30, name = "t(30) PDF",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545")) %>%
      layout(yaxis = list(title = "PDF"))

    p2 <- plot_ly(data, x = ~x) %>%
      add_trace(y = ~cdf_normal, name = "Normal CDF",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd"), showlegend = FALSE) %>%
      add_trace(y = ~cdf_t30, name = "t(30) CDF",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545"), showlegend = FALSE) %>%
      layout(yaxis = list(title = "CDF"))

    p3 <- plot_ly(data, x = ~x) %>%
      add_trace(y = ~mills_normal, name = "Normal Mills",
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd"), showlegend = FALSE) %>%
      add_trace(y = ~mills_t30, name = "t(30) Mills",
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545"), showlegend = FALSE) %>%
      layout(yaxis = list(title = "Mills Ratio"))

    p4 <- plot_ly(data, x = ~x) %>%
      add_trace(y = ~mills_ratio, name = "t(30)/Normal ratio",
                type = "scatter", mode = "lines",
                line = list(color = "#198754")) %>%
      add_trace(x = range(data$x), y = c(1, 1),
                type = "scatter", mode = "lines",
                line = list(color = "gray", dash = "dash"),
                showlegend = FALSE) %>%
      layout(yaxis = list(title = "Ratio t(30)/Normal"))

    subplot(p1, p2, p3, p4, nrows = 2, shareX = TRUE,
            titleX = TRUE, titleY = TRUE) %>%
      layout(title = "Complete t(30) vs Normal Analysis")
  })

  output$paradox_similarity <- renderUI({
    data <- paradox_data()
    focus_data <- data[abs(data$x - input$paradox_x_focus) < 0.05, ]
    if (nrow(focus_data) > 0) {
      cdf_diff <- abs(focus_data$cdf_difference[1])
      div(
        class = "alert alert-success",
        strong("CDF Difference at x = ", round(input$paradox_x_focus, 1)),
        br(),
        sprintf("%.6f (very small = similar distributions)", cdf_diff)
      )
    }
  })

  output$paradox_divergence <- renderUI({
    data <- paradox_data()
    focus_data <- data[abs(data$x - input$paradox_x_focus) < 0.05, ]
    if (nrow(focus_data) > 0) {
      mills_ratio_val <- focus_data$mills_ratio[1]
      div(
        class = "alert alert-warning",
        strong("Mills Ratio t(30)/Normal at x = ", round(input$paradox_x_focus, 1)),
        br(),
        sprintf("%.4f (%.1f%% difference)", mills_ratio_val, (mills_ratio_val - 1) * 100)
      )
    }
  })

  # ============================================================================
  # Page 7: Definitions - Interactive Calculators
  # ============================================================================

  # Helper to get Mills ratio for selected distribution
  get_mills <- function(x, dist) {
    if (dist == "Normal") {
      mills_ratio_normal(x)
    } else if (dist == "Exponential") {
      mills_ratio_exp(x)
    } else {
      mills_ratio_t(x, df = 10)
    }
  }

  # Helper to get density for selected distribution
  get_density <- function(x, dist) {
    if (dist == "Normal") {
      dnorm(x)
    } else if (dist == "Exponential") {
      dexp(x)
    } else {
      dt(x, df = 10)
    }
  }

  # Helper to get survival for selected distribution
  get_survival <- function(x, dist) {
    if (dist == "Normal") {
      1 - pnorm(x)
    } else if (dist == "Exponential") {
      1 - pexp(x)
    } else {
      1 - pt(x, df = 10)
    }
  }

  output$def_mills_value <- renderText({
    m <- get_mills(input$def_mills_x, input$def_mills_dist)
    sprintf("Mills ratio at x = %.1f: %.4f", input$def_mills_x, m)
  })

  output$def_mills_plot <- renderPlotly({
    x <- seq(0.1, 5, length.out = 100)
    m <- sapply(x, function(xi) get_mills(xi, input$def_mills_dist))
    m_point <- get_mills(input$def_mills_x, input$def_mills_dist)

    plot_ly() %>%
      add_trace(x = x, y = m, type = "scatter", mode = "lines",
                name = "Mills ratio",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(x = input$def_mills_x, y = m_point,
                type = "scatter", mode = "markers",
                name = sprintf("x=%.1f", input$def_mills_x),
                marker = list(color = "#dc3545", size = 10)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "m(x)"),
        showlegend = FALSE,
        margin = list(t = 5, b = 30, l = 50, r = 10)
      )
  })

  output$def_hazard_value <- renderText({
    m <- get_mills(input$def_mills_x, input$def_mills_dist)
    h <- 1 / m
    sprintf("Hazard at x = %.1f: %.4f (= 1/%.4f)", input$def_mills_x, h, m)
  })

  output$def_hazard_plot <- renderPlotly({
    x <- seq(0.1, 5, length.out = 100)
    h <- sapply(x, function(xi) 1 / get_mills(xi, input$def_mills_dist))
    h_point <- 1 / get_mills(input$def_mills_x, input$def_mills_dist)

    plot_ly() %>%
      add_trace(x = x, y = h, type = "scatter", mode = "lines",
                name = "Hazard",
                line = list(color = "#198754", width = 2)) %>%
      add_trace(x = input$def_mills_x, y = h_point,
                type = "scatter", mode = "markers",
                name = sprintf("x=%.1f", input$def_mills_x),
                marker = list(color = "#dc3545", size = 10)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "h(x)"),
        showlegend = FALSE,
        margin = list(t = 5, b = 30, l = 50, r = 10)
      )
  })

  output$def_survival_value <- renderText({
    s <- get_survival(input$def_mills_x, input$def_mills_dist)
    sprintf("Survival at x = %.1f: %.6f", input$def_mills_x, s)
  })

  output$def_survival_plot <- renderPlotly({
    x <- seq(0.1, 5, length.out = 100)
    s <- sapply(x, function(xi) get_survival(xi, input$def_mills_dist))
    s_point <- get_survival(input$def_mills_x, input$def_mills_dist)

    plot_ly() %>%
      add_trace(x = x, y = s, type = "scatter", mode = "lines",
                name = "Survival",
                line = list(color = "#fd7e14", width = 2)) %>%
      add_trace(x = input$def_mills_x, y = s_point,
                type = "scatter", mode = "markers",
                name = sprintf("x=%.1f", input$def_mills_x),
                marker = list(color = "#dc3545", size = 10)) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "S(x)"),
        showlegend = FALSE,
        margin = list(t = 5, b = 30, l = 50, r = 10)
      )
  })

  # ============================================================================
  # Page 8: Asymptotics
  # ============================================================================

  asymp_data <- reactive({
    x <- seq(input$asymp_x_range[1], input$asymp_x_range[2], length.out = 100)
    dist <- input$asymp_distribution

    if (dist == "normal") {
      exact <- mills_ratio_normal(x)
      approx <- 1 / x
      label_exact <- "Normal (exact)"
      label_approx <- "Asymptotic (1/x)"
    } else {
      df_val <- as.numeric(gsub("t", "", dist))
      exact <- mills_ratio_t(x, df = df_val)
      approx <- x / df_val
      label_exact <- sprintf("t(%d) (exact)", df_val)
      label_approx <- sprintf("Asymptotic (x/%d)", df_val)
    }

    list(
      x = x,
      exact = exact,
      approx = approx,
      error = abs(exact - approx) / exact,
      label_exact = label_exact,
      label_approx = label_approx
    )
  })

  output$asymptotic_plot <- renderPlotly({
    d <- asymp_data()

    plot_ly() %>%
      add_trace(x = d$x, y = d$exact, name = d$label_exact,
                type = "scatter", mode = "lines",
                line = list(color = "#0d6efd", width = 2)) %>%
      add_trace(x = d$x, y = d$approx, name = d$label_approx,
                type = "scatter", mode = "lines",
                line = list(color = "#dc3545", width = 2, dash = "dash")) %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Mills Ratio m(x)"),
        hovermode = "x unified",
        title = "Exact vs Asymptotic Approximation"
      )
  })

  output$asymptotic_table <- renderDT({
    d <- asymp_data()

    # Sample points for table
    idx <- seq(1, length(d$x), length.out = min(10, length(d$x)))
    idx <- round(idx)

    data.frame(
      x = round(d$x[idx], 2),
      Exact = round(d$exact[idx], 4),
      Asymptotic = round(d$approx[idx], 4),
      `Relative Error` = sprintf("%.2f%%", d$error[idx] * 100),
      check.names = FALSE
    ) %>%
      datatable(
        options = list(dom = "t", pageLength = 10, ordering = TRUE),
        rownames = FALSE
      )
  })

  output$asymp_error_box <- renderUI({
    d <- asymp_data()
    mean_err <- mean(d$error, na.rm = TRUE)
    max_err <- max(d$error, na.rm = TRUE)
    div(
      class = "alert alert-info",
      strong("Approximation Accuracy"),
      br(),
      sprintf("Mean relative error: %.2f%%", mean_err * 100),
      br(),
      sprintf("Max relative error: %.2f%%", max_err * 100),
      br(), br(),
      p(class = "text-muted mb-0",
        "Error decreases for larger x values where the asymptotic formula is more accurate.")
    )
  })

  # ============================================================================
  # Page 9: Playground - Custom Analysis
  # ============================================================================

  observeEvent(input$run_custom, {
    output$custom_output <- renderPlot({
      code <- input$custom_code
      tryCatch({
        eval(parse(text = code))
      }, error = function(e) {
        plot.new()
        text(0.5, 0.5, paste("Error:", e$message), col = "red", cex = 1.2)
      })
    })

    output$custom_console <- renderPrint({
      code <- input$custom_code
      tryCatch({
        result <- eval(parse(text = code))
        if (!is.null(result) && !inherits(result, "recordedplot")) {
          cat("Code executed at", format(Sys.time()), "\n")
        } else {
          cat("Plot generated at", format(Sys.time()), "\n")
        }
      }, error = function(e) {
        cat("Error:", e$message, "\n")
      })
    })
  })

  output$download_code <- downloadHandler(
    filename = function() {
      paste0("mills_ratio_code_", Sys.Date(), ".R")
    },
    content = function(file) {
      writeLines(input$custom_code, file)
    }
  )

  # ============================================================================
  # Page 10: Quick Reference
  # ============================================================================

  output$reference_functions <- renderDT({
    funcs <- data.frame(
      Function = c("mills_ratio_normal(x)", "mills_ratio_t(x, df)",
                   "mills_ratio_exp(x, rate)", "compare_mills_ratios(x, dists)",
                   "simulate_mills_curves(...)", "analyze_t30_paradox(...)",
                   "monte_carlo_mills(...)"),
      Description = c("Normal distribution Mills ratio",
                      "Student's t Mills ratio (specify df)",
                      "Exponential Mills ratio (rate=1 default)",
                      "Compare multiple distributions at x",
                      "Generate curves for plotting",
                      "Analyze t(30) vs Normal paradox",
                      "Monte Carlo verification"),
      stringsAsFactors = FALSE
    )
    datatable(funcs, options = list(dom = "t", pageLength = 10))
  })

  output$reference_formulas <- renderDT({
    formulas <- data.frame(
      Distribution = c("Normal", "Student t(df)", "Exponential(rate)"),
      `Asymptotic Mills Ratio` = c("m(x) ~ 1/x", "m(x) ~ x/df", "m(x) = 1/rate"),
      `Tail Type` = c("Thin (decreasing)", "Fat (increasing)", "Medium (constant)"),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    datatable(formulas, options = list(dom = "t", pageLength = 10))
  })

  # Code templates
  templates <- list(
    basic = "# Basic Mills Ratio Calculation\nx <- seq(0.5, 5, by = 0.1)\nm <- mills_ratio_normal(x)\nplot(x, m, type = 'l', col = 'blue',\n     main = 'Normal Mills Ratio',\n     xlab = 'x', ylab = 'm(x)')",
    compare = "# Compare Multiple Distributions\nx <- seq(0.5, 5, by = 0.1)\nm_norm <- mills_ratio_normal(x)\nm_t30 <- mills_ratio_t(x, df = 30)\nm_exp <- mills_ratio_exp(x)\n\nplot(x, m_norm, type = 'l', col = 'blue',\n     ylim = c(0, max(m_t30)),\n     main = 'Mills Ratio Comparison',\n     xlab = 'x', ylab = 'm(x)')\nlines(x, m_t30, col = 'red')\nlines(x, m_exp, col = 'green')\nlegend('topright', c('Normal', 't(30)', 'Exponential'),\n       col = c('blue', 'red', 'green'), lty = 1)",
    asymptotic = "# Asymptotic Accuracy\nx <- seq(1, 10, by = 0.1)\nm_exact <- mills_ratio_normal(x)\nm_approx <- 1/x\nerror <- abs(m_exact - m_approx) / m_exact\n\npar(mfrow = c(1, 2))\nplot(x, m_exact, type = 'l', col = 'blue',\n     main = 'Exact vs Asymptotic')\nlines(x, m_approx, col = 'red', lty = 2)\nlegend('topright', c('Exact', '1/x'),\n       col = c('blue', 'red'), lty = c(1, 2))\nplot(x, error * 100, type = 'l', col = 'purple',\n     main = 'Relative Error (%)',\n     xlab = 'x', ylab = 'Error %')",
    monte_carlo = "# Monte Carlo Verification\nset.seed(42)\nmc <- monte_carlo_mills(\n  n_sim = 5000,\n  x_val = 2,\n  distribution = 'normal'\n)\ncat('Empirical:', round(mc$empirical_mills, 4), '\\n')\ncat('True:     ', round(mc$true_mills, 4), '\\n')\ncat('Error:    ', round(mc$relative_error * 100, 2), '%\\n')"
  )

  output$template_code <- renderPrint({
    cat(templates[[input$template_select]])
  })

  # Copy template to custom analysis
  observeEvent(input$use_template, {
    updateTextAreaInput(session, "custom_code",
                       value = templates[[input$template_select]])
    nav_select("main_nav", selected = "Custom Analysis")
  })
}
