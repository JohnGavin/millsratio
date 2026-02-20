# Dashboard UI Definition

# Ensure required packages are loaded
library(bslib)
library(shiny)
library(plotly)
library(DT)

ui <- page_navbar(
  id = "main_nav",
  title = "Mills Ratio Explorer",
  theme = bs_theme(
    version = 5,
    bootswatch = "cosmo",
    "body-color" = "#212529",
    "headings-color" = "#212529"
  ),

  # Custom CSS for high contrast and scrolling

  header = tags$head(tags$style(HTML("
    /* High-contrast buttons - dark text on colored backgrounds */
    .btn-primary { background-color: #0d6efd; color: #fff; border-color: #0d6efd; }
    .btn-secondary { background-color: #6c757d; color: #fff; border-color: #6c757d; }
    .btn-success { background-color: #198754; color: #fff; border-color: #198754; }
    .btn-info { background-color: #0dcaf0; color: #000; border-color: #0dcaf0; }
    .btn-warning { background-color: #ffc107; color: #000; border-color: #ffc107; }
    .btn-danger { background-color: #dc3545; color: #fff; border-color: #dc3545; }

    /* Ensure all card headers have readable text */
    .card-header { background-color: #f8f9fa; color: #212529; font-weight: 600; }

    /* Alert boxes - ensure readable text */
    .alert-info { background-color: #cff4fc; color: #055160; border-color: #b6effb; }
    .alert-success { background-color: #d1e7dd; color: #0f5132; border-color: #badbcc; }
    .alert-warning { background-color: #fff3cd; color: #664d03; border-color: #ffecb5; }
    .alert-danger { background-color: #f8d7da; color: #842029; border-color: #f5c2c7; }

    /* Ensure all text is readable */
    .text-muted { color: #6c757d !important; }
    p, li, span, div, label { color: #212529; }
    h1, h2, h3, h4, h5, h6 { color: #212529; }

    /* Page sections explanatory text */
    .page-explanation {
      background-color: #f8f9fa;
      border-left: 4px solid #0d6efd;
      padding: 12px 16px;
      margin-bottom: 16px;
      color: #212529;
    }

    /* Scrollable page content */
    .tab-pane { overflow-y: auto; max-height: calc(100vh - 80px); padding-bottom: 20px; }

    /* Make plotly outputs respect container */
    .plotly { width: 100% !important; }
  "))),

  # Page 1: Welcome & Overview
  nav_panel(
    title = "Welcome",
    layout_columns(
      col_widths = c(12),
      card(
        card_header("Mills Ratio Explorer"),
        card_body(
          div(class = "page-explanation",
            p(strong("What is this dashboard?"),
              "This tool lets you explore Mills ratios interactively across
              different probability distributions. The Mills ratio m(x) = [1 - F(x)] / f(x)
              reveals fundamental differences between distribution tails that are invisible
              in the center of the distribution."),
            p("Use the navigation bar above to explore different pages. Each page
              focuses on a different aspect of Mills ratios.")
          ),
          h4("Navigate to:"),
          tags$ul(
            tags$li(strong("Analysis"), " - Interactive plots comparing distributions.
                    Adjust sliders and checkboxes to see how Mills ratios change."),
            tags$li(strong("Theory"), " - Mathematical definitions with interactive
                    calculators. Move the slider to compute Mills ratio, hazard function,
                    and survival function at any x value."),
            tags$li(strong("Playground"), " - Write and run your own R code for custom
                    Mills ratio experiments.")
          ),
          br(),
          actionButton("go_to_normal", "Start Exploring (Analysis)", class = "btn-primary btn-lg"),
          actionButton("go_to_theory", "View Theory", class = "btn-secondary btn-lg"),
          actionButton("go_to_playground", "Open Playground", class = "btn-secondary btn-lg"),
          br(), br(),
          card(
            card_header("Key Finding: The t(30) Paradox"),
            card_body(
              p("The t(30) distribution looks nearly identical to the normal distribution
                in the center, but their Mills ratios diverge dramatically in the tails.
                This has important implications for risk modeling."),
              plotlyOutput("welcome_plot", height = "300px")
            )
          )
        )
      )
    )
  ),

  # ANALYSIS SECTION
  nav_menu(
    title = "Analysis",

    # Page 2: Normal Distribution Explorer
    nav_panel(
      title = "Normal Distribution",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Normal Distribution Mills Ratio"),
          card_body(
            div(class = "page-explanation",
              p("This plot shows the exact Mills ratio for the normal distribution.
                Use the controls on the right to adjust the x range,
                toggle the asymptotic approximation (1/x), and switch to log scales.
                Hover over the plot for exact values.")
            ),
            plotlyOutput("normal_mills_plot", height = "450px")
          )
        ),
        card(
          card_header("Controls"),
          card_body(
            sliderInput("normal_x_range", "X Range:",
                       min = 0, max = 10, value = c(0, 5), step = 0.1),
            br(),
            checkboxInput("normal_show_asymptotic", "Show Asymptotic (1/x)", TRUE),
            checkboxInput("normal_log_y", "Log Y Scale", FALSE),
            checkboxInput("normal_log_x", "Log X Scale", FALSE),
            br(),
            h5("Key Insight"),
            p("The normal distribution has ", strong("thin tails"), ": its Mills ratio
              decreases as approximately 1/x for large x. This means the tail probability
              falls off very quickly relative to the density."),
            br(),
            uiOutput("normal_value_box")
          )
        )
      )
    ),

    # Page 3: Student's t Comparison
    nav_panel(
      title = "Student's t Distribution",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Student's t Distribution Mills Ratios"),
          card_body(
            div(class = "page-explanation",
              p("Compare Mills ratios for t-distributions with different degrees of freedom.
                Use the slider to change df. Check boxes below to overlay comparison
                distributions. The dashed line shows the asymptotic approximation x/df.")
            ),
            plotlyOutput("t_mills_plot", height = "450px")
          )
        ),
        card(
          card_header("Controls"),
          card_body(
            sliderInput("t_df_slider", "Degrees of Freedom:",
                       min = 1, max = 100, value = 30, step = 1,
                       animate = animationOptions(interval = 100)),
            p(class = "text-muted", "Drag the slider or click the play button to animate."),
            br(),
            checkboxGroupInput("t_df_compare", "Compare with:",
                             choices = c("df=3" = "3", "df=10" = "10",
                                       "df=30" = "30", "Normal" = "inf"),
                             selected = c("3", "30", "inf")),
            br(),
            checkboxInput("t_show_asymptotic", "Show Asymptotic (x/df)", TRUE),
            br(),
            h5("Key Insight"),
            p("The t-distribution has ", strong("fat tails"), ": its Mills ratio
              increases as approximately x/df. Lower df means fatter tails and faster
              Mills ratio growth."),
            br(),
            uiOutput("t_value_box")
          )
        )
      )
    ),

    # Page 4: Distribution Comparison
    nav_panel(
      title = "Distribution Comparison",
      div(class = "page-explanation",
        p("Compare Mills ratios across multiple distributions simultaneously.
          The left plot shows the raw Mills ratios. The right plot shows the ratio
          relative to the baseline distribution. Use the controls below to select
          which distributions to compare and adjust the x range.")
      ),
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header("Mills Ratio Curves"),
          card_body(
            plotlyOutput("comparison_mills_plot", height = "400px")
          )
        ),
        card(
          card_header("Relative Ratios"),
          card_body(
            plotlyOutput("comparison_ratio_plot", height = "400px")
          )
        )
      ),
      layout_columns(
        col_widths = c(12),
        card(
          card_header("Controls"),
          card_body(
            layout_columns(
              col_widths = c(4, 4, 4),
              checkboxGroupInput("compare_dists", "Distributions:",
                               choices = c("Normal" = "normal",
                                         "t(3)" = "t3",
                                         "t(10)" = "t10",
                                         "t(30)" = "t30",
                                         "Exponential" = "exponential"),
                               selected = c("normal", "t30", "exponential"),
                               inline = TRUE),
              radioButtons("compare_baseline", "Baseline for Ratios:",
                         choices = c("Normal" = "normal", "First Selected" = "first"),
                         selected = "normal",
                         inline = TRUE),
              sliderInput("compare_x_range", "X Range:",
                         min = 0, max = 10, value = c(0.5, 5), step = 0.1)
            )
          )
        )
      )
    ),

    # Page 5: Tail Thickness Analyzer
    nav_panel(
      title = "Tail Thickness",
      layout_columns(
        col_widths = c(7, 5),
        card(
          card_header("Mills Ratio Heatmap"),
          card_body(
            div(class = "page-explanation",
              p("The heatmap shows log10(Mills ratio) across distributions and x values.
                Red/warm colors = higher Mills ratio (fatter tails).
                Blue/cool colors = lower Mills ratio (thinner tails).
                Hover over cells for exact values.")
            ),
            plotlyOutput("thickness_heatmap", height = "450px")
          )
        ),
        card(
          card_header("Point Analysis"),
          card_body(
            p("Adjust the slider to select the x value range for the table below.
              The table shows exact Mills ratios and ratios relative to the normal distribution."),
            sliderInput("thickness_x_points", "X Values:",
                       min = 0, max = 10, value = c(1, 5), step = 0.5),
            br(),
            DTOutput("thickness_table", height = "300px"),
            br(),
            downloadButton("download_thickness", "Download Table",
                          class = "btn-sm btn-secondary")
          )
        )
      )
    ),

    # Page 6: t(30) Paradox
    nav_panel(
      title = "t(30) Paradox",
      div(class = "page-explanation",
        p(strong("The t(30) Paradox: "), "The t(30) distribution is often called
          'practically normal', but their tails tell a very different story.
          Click the tabs below to see the comparison from different angles.
          Use the slider to focus on a specific x value and see the divergence.")
      ),
      layout_columns(
        col_widths = c(12),
        card(
          card_header("Comparing t(30) and Normal"),
          card_body(
            tabsetPanel(
              tabPanel("Mills Ratio",
                      plotlyOutput("paradox_mills", height = "400px")),
              tabPanel("PDF Comparison",
                      plotlyOutput("paradox_pdf", height = "400px")),
              tabPanel("CDF Similarity",
                      plotlyOutput("paradox_cdf", height = "400px")),
              tabPanel("Complete Analysis",
                      plotlyOutput("paradox_all", height = "600px"))
            )
          )
        )
      ),
      layout_columns(
        col_widths = c(12),
        card(
          card_header("Analysis Controls"),
          card_body(
            p("Drag the slider to move the vertical focus line on the Mills Ratio plot.
              The boxes below update to show how similar the distributions are (CDF difference)
              vs how different their Mills ratios are at that x value."),
            layout_columns(
              col_widths = c(4, 4, 4),
              sliderInput("paradox_x_focus", "Focus on X:",
                         min = 0, max = 10, value = 3, step = 0.1,
                         animate = TRUE),
              uiOutput("paradox_similarity"),
              uiOutput("paradox_divergence")
            )
          )
        )
      )
    )
  ),

  # THEORY SECTION
  nav_menu(
    title = "Theory",

    # Page 7: Definitions
    nav_panel(
      title = "Definitions",
      div(class = "page-explanation",
        p("Interactive mathematical definitions. Use the ", strong("Distribution"),
          " dropdown and ", strong("x value"), " slider on the left card to change the
          distribution and point. All three cards update simultaneously to show the
          Mills ratio, hazard function, and survival function at your chosen x value.")
      ),
      layout_columns(
        col_widths = c(4, 4, 4),
        card(
          card_header("Mills Ratio"),
          card_body(
            withMathJax(),
            p("$$m(x) = \\frac{1 - F(x)}{f(x)} = \\frac{\\bar{F}(x)}{f(x)}$$"),
            p("The ratio of the survival function to the density. It measures
              how much probability remains in the tail relative to the density at x."),
            selectInput("def_mills_dist", "Distribution:",
                       choices = c("Normal", "t(df)", "Exponential")),
            sliderInput("def_mills_x", "x value:", 0, 5, 2, step = 0.1),
            p(class = "text-muted", "Drag the slider to see values change in all three cards."),
            strong(textOutput("def_mills_value")),
            plotlyOutput("def_mills_plot", height = "200px")
          )
        ),
        card(
          card_header("Hazard Function"),
          card_body(
            p("$$h(x) = \\frac{f(x)}{1 - F(x)} = \\frac{1}{m(x)}$$"),
            p("The reciprocal of the Mills ratio. It gives the instantaneous
              failure rate at x given survival to x. Higher hazard = thinner tails."),
            strong(textOutput("def_hazard_value")),
            plotlyOutput("def_hazard_plot", height = "200px")
          )
        ),
        card(
          card_header("Survival Function"),
          card_body(
            p("$$S(x) = 1 - F(x) = \\bar{F}(x)$$"),
            p("The probability of exceeding x. This is the numerator of the Mills ratio.
              Fat-tailed distributions have higher survival for large x."),
            strong(textOutput("def_survival_value")),
            plotlyOutput("def_survival_plot", height = "200px")
          )
        )
      )
    ),

    # Page 8: Asymptotics
    nav_panel(
      title = "Asymptotics",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Asymptotic Approximation Accuracy"),
          card_body(
            div(class = "page-explanation",
              p("This plot compares the exact Mills ratio (solid line) with its
                asymptotic approximation (dashed line). Use the dropdown on the right
                to choose a distribution and the slider to adjust the x range.
                The table below shows the approximation error at selected points.")
            ),
            plotlyOutput("asymptotic_plot", height = "400px"),
            br(),
            DTOutput("asymptotic_table", height = "200px")
          )
        ),
        card(
          card_header("Controls"),
          card_body(
            selectInput("asymp_distribution", "Distribution:",
                       choices = c("Normal" = "normal",
                                 "t(3)" = "t3",
                                 "t(10)" = "t10",
                                 "t(30)" = "t30")),
            p(class = "text-muted", "Select a distribution to see its approximation accuracy."),
            br(),
            sliderInput("asymp_x_range", "X Range:",
                       min = 1, max = 20, value = c(2, 10)),
            br(),
            h5("Asymptotic Formulas"),
            tags$ul(
              tags$li(strong("Normal:"), " m(x) ~ 1/x as x grows large"),
              tags$li(strong("t(df):"), " m(x) ~ x/df as x grows large"),
              tags$li(strong("Exponential:"), " m(x) = 1/rate (constant, exact)")
            ),
            br(),
            uiOutput("asymp_error_box")
          )
        )
      )
    )
  ),

  # PLAYGROUND SECTION
  nav_menu(
    title = "Playground",

    # Page 9: Custom Analysis
    nav_panel(
      title = "Custom Analysis",
      div(class = "page-explanation",
        p("Write R code in the left panel and click ", strong("Run Code"),
          " to execute it. The plot output appears on the right. You can use any
          millsratio package function (e.g., mills_ratio_normal, mills_ratio_t,
          simulate_mills_curves, plot_mills_curves). Text output appears below the plot.")
      ),
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header("R Code Input"),
          card_body(
            textAreaInput("custom_code",
                         label = NULL,
                         height = "400px",
                         width = "100%",
                         value = "# Example: Custom Mills ratio analysis\nx <- seq(0, 5, by = 0.1)\nm_normal <- mills_ratio_normal(x)\nm_t30 <- mills_ratio_t(x, df = 30)\n\nplot(x, m_normal, type = 'l', col = 'blue',\n     ylab = 'Mills Ratio', main = 'Custom Comparison')\nlines(x, m_t30, col = 'red')\nlegend('topright', c('Normal', 't(30)'), \n       col = c('blue', 'red'), lty = 1)"),
            br(),
            actionButton("run_custom", "Run Code", class = "btn-primary btn-lg"),
            downloadButton("download_code", "Download Script", class = "btn-secondary")
          )
        ),
        card(
          card_header("Output"),
          card_body(
            plotOutput("custom_output", height = "400px"),
            verbatimTextOutput("custom_console")
          )
        )
      )
    ),

    # Page 10: Quick Reference
    nav_panel(
      title = "Reference",
      div(class = "page-explanation",
        p("Quick reference for all millsratio package functions and formulas.
          Select a code template from the dropdown at the bottom to see example R code
          you can copy into the Custom Analysis playground.")
      ),
      layout_columns(
        col_widths = c(12),
        card(
          card_header("Quick Reference Guide"),
          card_body(
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header("Functions"),
                DTOutput("reference_functions")
              ),
              card(
                card_header("Formulas"),
                DTOutput("reference_formulas")
              )
            ),
            br(),
            card(
              card_header("Code Templates"),
              card_body(
                selectInput("template_select", "Select Template:",
                           choices = c("Basic Mills Ratio" = "basic",
                                     "Comparison Plot" = "compare",
                                     "Asymptotic Analysis" = "asymptotic",
                                     "Monte Carlo Verification" = "monte_carlo")),
                p(class = "text-muted",
                  "Select a template above to see the code. Copy it to the Custom Analysis page to run it."),
                br(),
                verbatimTextOutput("template_code"),
                br(),
                actionButton("use_template", "Copy to Custom Analysis",
                           class = "btn-primary")
              )
            )
          )
        )
      )
    )
  ),

  # About page
  nav_panel(
    title = "About",
    card(
      card_header("About This Dashboard"),
      card_body(
        h4("Mills Ratio Interactive Explorer"),
        p("Version: ", as.character(utils::packageVersion("millsratio"))),
        br(),
        p("This dashboard implements and extends the concepts from John D. Cook's blog
          post on Mills ratios and tail thickness. It provides interactive visualizations
          for exploring how different probability distributions behave in their tails."),
        br(),
        h5("How to Use This Dashboard"),
        tags$ul(
          tags$li(strong("Analysis pages"), " - Adjust sliders and checkboxes to change
                  plots in real time. Hover over plots for exact values."),
          tags$li(strong("Theory pages"), " - Interactive calculators for Mills ratio,
                  hazard function, and survival function. Change the distribution and x
                  value to see all three update."),
          tags$li(strong("Playground"), " - Write and execute custom R code.
                  The Reference page has templates you can copy.")
        ),
        br(),
        p("Reference: ",
          a("Mills Ratio and Tail Thickness (John D. Cook)",
            href = "https://www.johndcook.com/blog/2026/01/21/mills-ratio/",
            target = "_blank")),
        br(),
        p("Created by: John Gavin"),
        p("Implementation support: Claude Assistant")
      )
    )
  ),

  # Footer
  nav_spacer(),
  nav_item(
    tags$a(
      "GitHub",
      href = "https://github.com/JohnGavin/millsratio",
      target = "_blank"
    )
  )
)
