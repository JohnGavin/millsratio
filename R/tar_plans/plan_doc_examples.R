# Documentation examples pipeline
# Stores README code chunks as text targets with parse & eval validation
# Per CLAUDE.md mandatory code-as-targets pattern

library(targets)

# Helper: parse code text and return validation result
parse_code_example <- function(code_lines) {
  code_text <- paste(code_lines, collapse = "\n")
  tryCatch(
    {
      parsed <- parse(text = code_text)
      list(
        valid = TRUE, n_expressions = length(parsed),
        code = code_lines, error = NULL
      )
    },
    error = function(e) {
      list(
        valid = FALSE, n_expressions = 0L,
        code = code_lines, error = conditionMessage(e)
      )
    }
  )
}

# Helper: evaluate code and return success/failure
eval_code_example <- function(code_lines) {
  code_text <- paste(code_lines, collapse = "\n")
  tryCatch(
    {
      eval(parse(text = code_text), envir = new.env(parent = globalenv()))
      list(success = TRUE, error = NULL)
    },
    error = function(e) {
      list(success = FALSE, error = conditionMessage(e))
    }
  )
}

plan_doc_examples <- list(
  # ── Code chunk 1: Basic usage ──────────────────────────────────
  targets::tar_target(
    code_readme_basic,
    c(
      "x <- seq(1, 5, by = 0.5)",
      "m_normal <- mills_ratio_normal(x)",
      "print(round(m_normal, 3))",
      "",
      "m_t30 <- mills_ratio_t(x, df = 30)",
      "print(round(m_t30, 3))",
      "",
      "x_compare <- c(1, 2, 3, 4)",
      "comparison <- compare_mills_ratios(x_compare, c(\"normal\", \"t30\", \"exponential\"))",
      "print(comparison)"
    )
  ),
  targets::tar_target(code_parsed_basic, parse_code_example(code_readme_basic)),
  targets::tar_target(code_eval_basic, eval_code_example(code_readme_basic)),

  # ── Code chunk 2: Visualization ────────────────────────────────
  targets::tar_target(
    code_readme_viz,
    c(
      "curves <- simulate_mills_curves(",
      "  x_range = c(0.5, 5),",
      "  distributions = c(\"normal\", \"t30\", \"exponential\")",
      ")",
      "",
      "plot_mills_curves(curves, log_y = TRUE)"
    )
  ),
  targets::tar_target(code_parsed_viz, parse_code_example(code_readme_viz)),
  targets::tar_target(code_eval_viz, eval_code_example(code_readme_viz)),

  # ── Code chunk 3: t(30) paradox ────────────────────────────────
  targets::tar_target(
    code_readme_paradox,
    c(
      "paradox_data <- analyze_t30_paradox(x_range = c(0, 5), n_points = 100)",
      "",
      "x_vals <- c(1, 2, 3, 4, 5)",
      "ratio <- mills_ratio_t(x_vals, df = 30) / mills_ratio_normal(x_vals)",
      "cat(\"t(30)/Normal Mills ratio divergence:\\n\")",
      "for (i in seq_along(x_vals)) {",
      "  cat(sprintf(\"x = %d: ratio = %.3f\\n\", x_vals[i], ratio[i]))",
      "}"
    )
  ),
  targets::tar_target(code_parsed_paradox, parse_code_example(code_readme_paradox)),
  targets::tar_target(code_eval_paradox, eval_code_example(code_readme_paradox)),

  # ── Code chunk 4: Paradox plot ─────────────────────────────────
  targets::tar_target(
    code_readme_paradox_plot,
    c(
      "paradox_data <- analyze_t30_paradox(x_range = c(0, 5), n_points = 100)",
      "plot_t30_paradox(paradox_data, focus = \"mills\")"
    )
  ),
  targets::tar_target(
    code_parsed_paradox_plot,
    parse_code_example(code_readme_paradox_plot)
  ),
  targets::tar_target(
    code_eval_paradox_plot,
    eval_code_example(code_readme_paradox_plot)
  ),

  # ── Code chunk 5: Property verification ────────────────────────
  targets::tar_target(
    code_readme_properties,
    c(
      "x <- seq(1, 5, by = 0.5)",
      "m <- mills_ratio_normal(x)",
      "cat(\"Normal Mills ratio decreasing:\", all(diff(m) < 0), \"\\n\")",
      "",
      "m_t <- mills_ratio_t(x, df = 3)",
      "cat(\"t(3) Mills ratio increasing:\", all(diff(m_t) > 0), \"\\n\")",
      "",
      "m_exp <- mills_ratio_exp(x)",
      "cat(\"Exponential Mills ratio constant:\", all(abs(diff(m_exp)) < 1e-10), \"\\n\")"
    )
  ),
  targets::tar_target(
    code_parsed_properties,
    parse_code_example(code_readme_properties)
  ),
  targets::tar_target(
    code_eval_properties,
    eval_code_example(code_readme_properties)
  ),

  # ── Code chunk 6: Interactive plotly ───────────────────────────
  targets::tar_target(
    code_readme_interactive,
    c(
      "library(plotly)",
      "curves <- simulate_mills_curves(",
      "  x_range = c(0.1, 10),",
      "  distributions = c(\"normal\", \"t3\", \"t10\", \"t30\"),",
      "  log_scale = TRUE",
      ")",
      "",
      "p <- plot_mills_curves(curves, log_y = TRUE, interactive = TRUE)",
      "p"
    )
  ),
  targets::tar_target(
    code_parsed_interactive,
    parse_code_example(code_readme_interactive)
  ),
  targets::tar_target(
    code_eval_interactive,
    eval_code_example(code_readme_interactive)
  ),

  # ── Code chunk 7: Monte Carlo ──────────────────────────────────
  targets::tar_target(
    code_readme_monte_carlo,
    c(
      "set.seed(123)",
      "mc_result <- monte_carlo_mills(",
      "  n_sim = 10000,",
      "  x_val = 2,",
      "  distribution = \"normal\"",
      ")",
      "",
      "cat(\"Empirical Mills ratio:\", round(mc_result$empirical_mills, 4), \"\\n\")",
      "cat(\"True Mills ratio:\", round(mc_result$true_mills, 4), \"\\n\")",
      "cat(\"Relative error:\", round(mc_result$relative_error, 4), \"\\n\")"
    )
  ),
  targets::tar_target(
    code_parsed_monte_carlo,
    parse_code_example(code_readme_monte_carlo)
  ),
  targets::tar_target(
    code_eval_monte_carlo,
    eval_code_example(code_readme_monte_carlo)
  ),

  # ── Validation gate ────────────────────────────────────────────
  targets::tar_target(
    doc_examples_validation,
    {
      parse_results <- list(
        basic = code_parsed_basic,
        viz = code_parsed_viz,
        paradox = code_parsed_paradox,
        paradox_plot = code_parsed_paradox_plot,
        properties = code_parsed_properties,
        interactive = code_parsed_interactive,
        monte_carlo = code_parsed_monte_carlo
      )
      eval_results <- list(
        basic = code_eval_basic,
        viz = code_eval_viz,
        paradox = code_eval_paradox,
        paradox_plot = code_eval_paradox_plot,
        properties = code_eval_properties,
        interactive = code_eval_interactive,
        monte_carlo = code_eval_monte_carlo
      )

      all_parsed <- all(vapply(
        parse_results, function(x) x$valid, logical(1)
      ))
      all_evald <- all(vapply(
        eval_results, function(x) x$success, logical(1)
      ))

      if (!all_parsed) {
        failed <- names(parse_results)[
          !vapply(parse_results, function(x) x$valid, logical(1))
        ]
        cli::cli_abort(c(
          "x" = "README code examples failed syntax validation",
          "i" = "Failed: {paste(failed, collapse = ', ')}"
        ))
      }
      if (!all_evald) {
        failed <- names(eval_results)[
          !vapply(eval_results, function(x) x$success, logical(1))
        ]
        cli::cli_abort(c(
          "x" = "README code examples failed evaluation",
          "i" = "Failed: {paste(failed, collapse = ', ')}"
        ))
      }

      list(
        all_valid = TRUE,
        n_examples = length(parse_results),
        parse_ok = all_parsed,
        eval_ok = all_evald
      )
    }
  )
)
