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
    updateNavbarPage(session, "main_nav", selected = "Normal Distribution")
  })

  observeEvent(input$go_to_theory, {
    updateNavbarPage(session, "main_nav", selected = "Definitions")
  })

  observeEvent(input$go_to_playground, {
    updateNavbarPage(session, "main_nav", selected = "Custom Analysis")
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
                line = list(color = "#2c3e50", width = 2)) %>%
      add_trace(x = x, y = m_t30, name = "t(30)",
                type = "scatter", mode = "lines",
                line = list(color = "#e74c3c", width = 2)) %>%
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
                         line = list(color = "#2c3e50", width = 2))

    # Asymptotic approximation
    if (input$normal_show_asymptotic) {
      m_asymp <- 1/x
      p <- p %>% add_trace(x = x, y = m_asymp, name = "Asymptotic (1/x)",
                           type = "scatter", mode = "lines",
                           line = list(color = "#95a5a6", width = 2, dash = "dash"))
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
      strong(sprintf("m(%.1f) = %.3f", x_mid, m_val))
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
                         line = list(color = "#e74c3c", width = 3))

    # Comparison distributions
    colors <- c("3" = "#3498db", "10" = "#9b59b6", "30" = "#f39c12", "inf" = "#2c3e50")
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
                           line = list(color = "#95a5a6", width = 1, dash = "dash"))
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
    div(
      class = "alert alert-info",
      strong(sprintf("t(%d): m(3) = %.3f", input$t_df_slider, m_val))
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

    # Check if we have data
    if (nrow(data) == 0) {
      return(plot_ly() %>%
               add_annotations(
                 text = "Select distributions to compare",
                 xref = "paper", yref = "paper",
                 x = 0.5, y = 0.5, showarrow = FALSE
               ))
    }

    # Calculate ratios relative to baseline
    baseline_dist <- if (input$compare_baseline == "normal") {
      "Normal"
    } else {
      unique(data$distribution)[1]
    }

    wide_data <- data %>%
      select(x, distribution, mills_ratio) %>%
      pivot_wider(names_from = distribution, values_from = mills_ratio)

    # Check baseline exists
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

    # Prepare data for heatmap
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
                line = list(color = "#2c3e50", width = 2)) %>%
      add_trace(y = ~mills_t30, name = "t(30)",
                type = "scatter", mode = "lines",
                line = list(color = "#e74c3c", width = 2)) %>%
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
                type = "scatter", mode = "lines") %>%
      add_trace(y = ~pdf_t30, name = "t(30) PDF",
                type = "scatter", mode = "lines") %>%
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
                type = "scatter", mode = "lines") %>%
      add_trace(y = ~cdf_t30, name = "t(30) CDF",
                type = "scatter", mode = "lines") %>%
      layout(
        xaxis = list(title = "x"),
        yaxis = list(title = "Cumulative Probability"),
        title = "CDF Comparison: Highly Similar"
      )
  })

  output$paradox_similarity <- renderUI({
    data <- paradox_data()
    focus_data <- data[abs(data$x - input$paradox_x_focus) < 0.05, ]
    if (nrow(focus_data) > 0) {
      cdf_diff <- abs(focus_data$cdf_difference[1])
      div(
        class = "alert alert-success",
        strong("CDF Difference"),
        br(),
        sprintf("%.4f", cdf_diff)
      )
    }
  })

  output$paradox_divergence <- renderUI({
    data <- paradox_data()
    focus_data <- data[abs(data$x - input$paradox_x_focus) < 0.05, ]
    if (nrow(focus_data) > 0) {
      mills_ratio <- focus_data$mills_ratio[1]
      div(
        class = "alert alert-warning",
        strong("Mills Ratio"),
        br(),
        sprintf("%.2f%%", (mills_ratio - 1) * 100)
      )
    }
  })

  # ============================================================================
  # Theory Pages - Simplified
  # ============================================================================

  output$def_mills_value <- renderText({
    x <- input$def_mills_x
    if (input$def_mills_dist == "Normal") {
      m <- mills_ratio_normal(x)
    } else if (input$def_mills_dist == "Exponential") {
      m <- mills_ratio_exp(x)
    } else {
      m <- mills_ratio_t(x, df = 10)  # Default df
    }
    sprintf("Mills ratio at x=%.1f: %.4f", x, m)
  })

  output$def_hazard_value <- renderText({
    x <- input$def_mills_x
    if (input$def_mills_dist == "Normal") {
      m <- mills_ratio_normal(x)
    } else if (input$def_mills_dist == "Exponential") {
      m <- mills_ratio_exp(x)
    } else {
      m <- mills_ratio_t(x, df = 10)
    }
    h <- 1/m
    sprintf("Hazard at x=%.1f: %.4f", x, h)
  })

  output$asymp_error_box <- renderUI({
    # Add asymptotic error display
    div(
      class = "alert alert-warning",
      strong("Asymptotic Approximation"),
      br(),
      "Select a distribution to see error"
    )
  })

  # ============================================================================
  # Playground - Custom Analysis
  # ============================================================================

  observeEvent(input$run_custom, {
    output$custom_output <- renderPlot({
      code <- input$custom_code
      tryCatch({
        eval(parse(text = code))
      }, error = function(e) {
        plot.new()
        text(0.5, 0.5, paste("Error:", e$message), col = "red")
      })
    })
  })

  output$custom_console <- renderPrint({
    if (input$run_custom > 0) {
      cat("Code executed successfully at", format(Sys.time()))
    }
  })

  # ============================================================================
  # Quick Reference
  # ============================================================================

  output$reference_functions <- renderDT({
    funcs <- data.frame(
      Function = c("mills_ratio_normal", "mills_ratio_t", "mills_ratio_exp",
                   "compare_mills_ratios", "simulate_mills_curves"),
      Description = c("Normal distribution Mills ratio",
                      "Student's t Mills ratio",
                      "Exponential Mills ratio",
                      "Compare multiple distributions",
                      "Generate simulation curves"),
      stringsAsFactors = FALSE
    )
    datatable(funcs, options = list(dom = "t", pageLength = 10))
  })

  output$reference_formulas <- renderDT({
    formulas <- data.frame(
      Distribution = c("Normal", "Student t", "Exponential"),
      `Mills Ratio` = c("m(x) → 1/x", "m(x) → x/df", "m(x) = 1/rate"),
      `Tail Type` = c("Thin", "Fat", "Medium"),
      stringsAsFactors = FALSE
    )
    datatable(formulas, options = list(dom = "t", pageLength = 10))
  })
}