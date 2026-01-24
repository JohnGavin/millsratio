# Simplified Dashboard UI - Focus on Content, Not Flash

library(bslib)
library(shiny)
library(plotly)
library(DT)

ui <- page_navbar(
  title = "Mills Ratio Analysis",
  theme = bs_theme(version = 5, bootswatch = "minty"),

  # Main Analysis Page
  nav_panel(
    title = "Analysis",
    icon = icon("chart-line"),

    # Enable MathJax
    tags$head(
      tags$script(src = "https://polyfill.io/v3/polyfill.min.js?features=es6"),
      tags$script(id = "MathJax-script", async = "true",
                  src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js")
    ),

    layout_columns(
      col_widths = c(12),

      # Introduction Card
      card(
        card_header("Understanding Mills Ratios"),
        card_body(
          p("The Mills ratio \\(m(x) = \\frac{1 - F(x)}{f(x)}\\) quantifies tail thickness:"),
          tags$ul(
            tags$li("Decreasing \\(m(x)\\): Thin tails (Normal: \\(m(x) \\sim 1/x\\))"),
            tags$li("Increasing \\(m(x)\\): Fat tails (Student's t: \\(m(x) \\sim x/\\nu\\))"),
            tags$li("Constant \\(m(x)\\): Exponential tails (\\(m(x) = 1/\\lambda\\))")
          ),
          p("Reference: Cook, J.D. (2026). Mills Ratio and Tail Thickness.",
            tags$a(href = "https://www.johndcook.com/blog/2026/01/21/mills-ratio/",
                   target = "_blank", "Blog post"))
        )
      ),

      # Interactive Comparison
      card(
        card_header("Distribution Comparison"),
        card_body(
          layout_columns(
            col_widths = c(4, 8),

            # Controls
            div(
              selectInput("dist_compare", "Distributions:",
                         choices = c("Normal" = "normal",
                                   "t(3)" = "t3",
                                   "t(10)" = "t10",
                                   "t(30)" = "t30",
                                   "Exponential" = "exp"),
                         selected = c("normal", "t30", "exp"),
                         multiple = TRUE),

              sliderInput("x_range", "X Range:",
                         min = 0.1, max = 10, value = c(0.5, 5),
                         step = 0.1),

              checkboxInput("log_scale", "Log Scale", FALSE),

              hr(),

              h5("Key Finding: t(30) Paradox"),
              p("t(30) appears normal centrally but has substantially fatter tails."),
              p("At x=4: t(30)/Normal ratio = 1.54")
            ),

            # Main plot
            plotlyOutput("main_plot", height = "400px")
          ),

          # Caption
          tags$small(class = "text-muted",
                    "Figure 1: Mills ratios for selected distributions. ",
                    "The divergence between t(30) and normal demonstrates ",
                    "why assuming normality can severely underestimate tail risk.")
        )
      ),

      # Numerical Results
      card(
        card_header("Numerical Comparison"),
        card_body(
          DTOutput("comparison_table"),
          tags$small(class = "text-muted mt-2",
                    "Table 1: Mills ratio values at selected points. ",
                    "Note how t(30) increasingly diverges from normal as x increases.")
        )
      )
    )
  ),

  # Theory Page (Consolidated)
  nav_panel(
    title = "Theory",
    icon = icon("book"),

    layout_columns(
      col_widths = c(12),

      card(
        card_header("Mathematical Foundation"),
        card_body(
          h4("Definition"),
          p("The Mills ratio is the ratio of the survival function to the density:"),
          p("$$m(x) = \\frac{\\bar{F}(x)}{f(x)} = \\frac{\\int_x^\\infty f(t) dt}{f(x)}$$"),

          h4("Asymptotic Behavior"),
          tags$table(class = "table table-sm",
            tags$thead(
              tags$tr(
                tags$th("Distribution"),
                tags$th("Mills Ratio Behavior"),
                tags$th("Tail Classification")
              )
            ),
            tags$tbody(
              tags$tr(
                tags$td("Normal"),
                tags$td("\\(m(x) \\sim \\frac{1}{x}\\) as \\(x \\to \\infty\\)"),
                tags$td("Thin (sub-exponential)")
              ),
              tags$tr(
                tags$td("Student's t(\\(\\nu\\))"),
                tags$td("\\(m(x) \\sim \\frac{x}{\\nu}\\) as \\(x \\to \\infty\\)"),
                tags$td("Fat (power law)")
              ),
              tags$tr(
                tags$td("Exponential"),
                tags$td("\\(m(x) = \\frac{1}{\\lambda}\\) (constant)"),
                tags$td("Light (exponential)")
              )
            )
          ),

          h4("Connection to Hazard Function"),
          p("The hazard function \\(h(x) = \\frac{f(x)}{\\bar{F}(x)} = \\frac{1}{m(x)}\\) is the reciprocal of the Mills ratio."),

          h4("Applications"),
          tags$ul(
            tags$li("Risk assessment: Tail probabilities in finance"),
            tags$li("Reliability engineering: Failure time analysis"),
            tags$li("Survival analysis: Medical statistics"),
            tags$li("Quality control: Extreme value detection")
          ),

          h4("References"),
          tags$ol(
            tags$li("Mills, J.P. (1926). Table of the ratio: Area to bounding ordinate, for any portion of normal curve. Biometrika, 18(3/4), 395-400."),
            tags$li("Cook, J.D. (2026). Mills Ratio and Tail Thickness. Blog post."),
            tags$li("Johnson, N.L., Kotz, S., & Balakrishnan, N. (1994). Continuous Univariate Distributions, Vol. 1 & 2. Wiley.")
          )
        )
      )
    )
  ),

  # R Code Examples
  nav_panel(
    title = "R Code",
    icon = icon("code"),

    layout_columns(
      col_widths = c(12),

      card(
        card_header("Working with Mills Ratios in R"),
        card_body(
          h4("Basic Usage"),
          pre(code = '# Load the package
library(millsratio)
library(tidyverse)  # For data manipulation

# Calculate Mills ratios
x <- seq(1, 5, by = 0.5)
tibble(
  x = x,
  normal = mills_ratio_normal(x),
  t30 = mills_ratio_t(x, df = 30),
  exponential = mills_ratio_exp(x)
) %>%
  mutate(t30_normal_ratio = t30 / normal)'),

          h4("Visualization"),
          pre(code = '# Create comparison plot
library(ggplot2)

curves <- simulate_mills_curves(
  x_range = c(0.5, 5),
  distributions = c("normal", "t30", "exponential")
)

ggplot(curves, aes(x = x, y = mills_ratio, color = distribution)) +
  geom_line(linewidth = 1) +
  scale_y_log10() +
  labs(
    title = "Mills Ratio Comparison",
    x = "x",
    y = "Mills Ratio m(x) (log scale)",
    caption = "t(30) diverges from normal in the tails"
  ) +
  theme_minimal()'),

          h4("Verify Properties"),
          pre(code = '# Verify theoretical properties
x_seq <- seq(1, 5, by = 0.5)

# Normal: decreasing (thin tails)
all(diff(mills_ratio_normal(x_seq)) < 0)
#> [1] TRUE

# t(3): increasing (fat tails)
all(diff(mills_ratio_t(x_seq, df = 3)) > 0)
#> [1] TRUE

# Exponential: constant
all(abs(diff(mills_ratio_exp(x_seq))) < 1e-10)
#> [1] TRUE'),

          h4("The t(30) Paradox"),
          pre(code = '# Quantify the t(30) paradox
analyze_t30_paradox() %>%
  filter(x %in% c(1, 2, 3, 4, 5)) %>%
  select(x, mills_normal, mills_t30, mills_ratio) %>%
  mutate(across(where(is.numeric), ~round(.x, 3)))')
        )
      )
    )
  ),

  # About
  nav_panel(
    title = "About",
    icon = icon("info-circle"),

    card(
      card_body(
        h4("Mills Ratio Analysis Dashboard"),
        p("Version: 0.1.0"),
        p("Author: John Gavin"),
        p("This dashboard implements concepts from John D. Cook's analysis of Mills ratios and tail thickness."),
        p("Source code: ",
          tags$a(href = "https://github.com/johngavin/millsratio", "GitHub"))
      )
    )
  )
)