# Dashboard UI Definition

# Ensure required packages are loaded
library(bslib)
library(shiny)
library(plotly)
library(DT)

ui <- page_navbar(
  title = "Mills Ratio Explorer",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2c3e50",
    success = "#18bc9c"
  ),

  # Page 1: Welcome & Overview
  nav_panel(
    title = "Welcome",
    icon = icon("home"),
    layout_columns(
      col_widths = c(12),
      card(
        card_header("Welcome to Mills Ratio Explorer"),
        card_body(
          h3("Understanding Tail Thickness Through Mills Ratios"),
          br(),
          p("The Mills ratio m(x) = [1 - F(x)] / f(x) reveals fundamental differences
            between distribution tails that are invisible in the center."),
          br(),
          layout_columns(
            col_widths = c(4, 4, 4),
            card(
              card_header(class = "bg-primary text-white", "Explore"),
              card_body(
                icon("chart-line", class = "fa-3x text-primary"),
                br(), br(),
                p("Interactive visualizations of Mills ratios across distributions"),
                actionButton("go_to_normal", "Start Exploring", class = "btn-primary")
              )
            ),
            card(
              card_header(class = "bg-info text-white", "Learn"),
              card_body(
                icon("graduation-cap", class = "fa-3x text-info"),
                br(), br(),
                p("Mathematical foundations and asymptotic analysis"),
                actionButton("go_to_theory", "View Theory", class = "btn-info")
              )
            ),
            card(
              card_header(class = "bg-success text-white", "Create"),
              card_body(
                icon("code", class = "fa-3x text-success"),
                br(), br(),
                p("Build your own Mills ratio experiments"),
                actionButton("go_to_playground", "Open Playground", class = "btn-success")
              )
            )
          ),
          br(),
          card(
            card_header("Key Finding: The t(30) Paradox"),
            card_body(
              plotlyOutput("welcome_plot", height = "300px"),
              p(class = "text-muted mt-2",
                "t(30) appears nearly identical to normal in the center but diverges dramatically in the tails")
            )
          )
        )
      )
    )
  ),

  # ANALYSIS SECTION
  nav_menu(
    title = "Analysis",
    icon = icon("chart-bar"),

    # Page 2: Normal Distribution Explorer
    nav_panel(
      title = "Normal Distribution",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Normal Distribution Mills Ratio"),
          card_body(
            plotlyOutput("normal_mills_plot", height = "500px")
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
            p(class = "text-info",
              "Normal distribution has thin tails: Mills ratio decreases as ~1/x"),
            br(),
            div(id = "normal_value_box", class = "alert alert-info")
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
            plotlyOutput("t_mills_plot", height = "500px")
          )
        ),
        card(
          card_header("Controls"),
          card_body(
            sliderInput("t_df_slider", "Degrees of Freedom:",
                       min = 1, max = 100, value = 30, step = 1,
                       animate = animationOptions(interval = 100)),
            br(),
            checkboxGroupInput("t_df_compare", "Compare with:",
                             choices = c("df=3" = "3", "df=10" = "10",
                                       "df=30" = "30", "Normal" = "inf"),
                             selected = c("3", "30", "inf")),
            br(),
            checkboxInput("t_show_asymptotic", "Show Asymptotic (x/df)", TRUE),
            br(),
            h5("Key Insight"),
            p(class = "text-info",
              "t-distribution has fat tails: Mills ratio increases as ~x/df"),
            br(),
            div(id = "t_value_box", class = "alert alert-info")
          )
        )
      )
    ),

    # Page 4: Distribution Battle Arena
    nav_panel(
      title = "Distribution Comparison",
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
            plotlyOutput("thickness_heatmap", height = "500px")
          )
        ),
        card(
          card_header("Point Analysis"),
          card_body(
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
      layout_columns(
        col_widths = c(12),
        card(
          card_header("The t(30) Paradox: Similar Centers, Different Tails"),
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
            layout_columns(
              col_widths = c(4, 4, 4),
              sliderInput("paradox_x_focus", "Focus on X:",
                         min = 0, max = 10, value = 3, step = 0.1,
                         animate = TRUE),
              div(id = "paradox_similarity", class = "alert alert-success"),
              div(id = "paradox_divergence", class = "alert alert-warning")
            )
          )
        )
      )
    )
  ),

  # THEORY SECTION
  nav_menu(
    title = "Theory",
    icon = icon("book"),

    # Page 7: Living Definitions
    nav_panel(
      title = "Definitions",
      layout_columns(
        col_widths = c(4, 4, 4),
        card(
          card_header("Mills Ratio"),
          card_body(
            withMathJax(),
            p("$$m(x) = \\frac{1 - F(x)}{f(x)} = \\frac{\\bar{F}(x)}{f(x)}$$"),
            br(),
            selectInput("def_mills_dist", "Distribution:",
                       choices = c("Normal", "t(df)", "Exponential")),
            sliderInput("def_mills_x", "x value:", 0, 5, 2, step = 0.1),
            textOutput("def_mills_value"),
            plotlyOutput("def_mills_plot", height = "200px")
          )
        ),
        card(
          card_header("Hazard Function"),
          card_body(
            p("$$h(x) = \\frac{f(x)}{1 - F(x)} = \\frac{1}{m(x)}$$"),
            br(),
            p("The hazard function is the reciprocal of the Mills ratio."),
            textOutput("def_hazard_value"),
            plotlyOutput("def_hazard_plot", height = "200px")
          )
        ),
        card(
          card_header("Survival Function"),
          card_body(
            p("$$S(x) = 1 - F(x) = \\bar{F}(x)$$"),
            br(),
            p("The survival function appears in the Mills ratio numerator."),
            textOutput("def_survival_value"),
            plotlyOutput("def_survival_plot", height = "200px")
          )
        )
      )
    ),

    # Page 8: Asymptotic Playground
    nav_panel(
      title = "Asymptotics",
      layout_columns(
        col_widths = c(8, 4),
        card(
          card_header("Asymptotic Approximation Accuracy"),
          card_body(
            plotlyOutput("asymptotic_plot", height = "500px"),
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
            br(),
            sliderInput("asymp_x_range", "X Range:",
                       min = 1, max = 20, value = c(2, 10)),
            br(),
            h5("Asymptotic Formulas"),
            tags$ul(
              tags$li("Normal: m(x) ~ 1/x"),
              tags$li("t(df): m(x) ~ x/df"),
              tags$li("Exponential: m(x) = 1/rate")
            ),
            br(),
            div(id = "asymp_error_box", class = "alert alert-warning")
          )
        )
      )
    )
  ),

  # PLAYGROUND SECTION
  nav_menu(
    title = "Playground",
    icon = icon("flask"),

    # Page 11: Build Your Own
    nav_panel(
      title = "Custom Analysis",
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
            actionButton("run_custom", "Run Code", class = "btn-success"),
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

    # Page 12: Quick Reference
    nav_panel(
      title = "Reference",
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
                br(),
                verbatimTextOutput("template_code"),
                br(),
                actionButton("copy_template", "Copy to Clipboard",
                           class = "btn-secondary")
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
    icon = icon("info-circle"),
    card(
      card_header("About This Dashboard"),
      card_body(
        h4("Mills Ratio Interactive Explorer"),
        p("Version:", as.character(utils::packageVersion("millsratio"))),
        br(),
        p("This dashboard implements and extends the concepts from John D. Cook's blog post on Mills ratios and tail thickness."),
        br(),
        p("Reference: ",
          a("Mills Ratio and Tail Thickness",
            href = "https://www.johndcook.com/blog/2026/01/21/mills-ratio/",
            target = "_blank")),
        br(),
        p("Created by: John Gavin"),
        p("Implementation support: Claude Assistant"),
        br(),
        h5("Key Features:"),
        tags$ul(
          tags$li("Interactive exploration of Mills ratios"),
          tags$li("Comparison across multiple distributions"),
          tags$li("Asymptotic analysis and verification"),
          tags$li("The t(30) paradox visualization"),
          tags$li("Custom code playground")
        )
      )
    )
  ),

  # Footer
  nav_spacer(),
  nav_item(
    tags$a(
      icon("github"),
      href = "https://github.com/yourusername/millsratio",
      target = "_blank"
    )
  )
)