# Documentation pipeline for auto-updating README and website
library(targets)
library(tarchetypes)

documentation_plan <- list(
  # Track vignette/article files
  tar_target(
    vignette_files,
    list.files(
      path = c("vignettes", "articles"),
      pattern = "\\.Rmd$|\\.qmd$",
      full.names = TRUE,
      recursive = TRUE
    ),
    format = "file"
  ),

  # Track README.qmd
  tar_target(
    readme_qmd,
    "README.qmd",
    format = "file"
  ),

  # Track R source files (for documentation updates)
  tar_target(
    r_files,
    list.files("R", pattern = "\\.R$", full.names = TRUE),
    format = "file"
  ),

  # Render README when vignettes or R files change
  tar_target(
    readme_md,
    {
      # Dependencies to trigger re-rendering
      vignette_files
      r_files

      # Check if quarto is available
      if(requireNamespace("quarto", quietly = TRUE)) {
        # Use quarto for .qmd files
        quarto::quarto_render(
          input = readme_qmd,
          output_format = "gfm"  # GitHub Flavored Markdown
        )
      } else {
        # Fall back to rmarkdown
        rmarkdown::render(
          input = readme_qmd,
          output_format = "github_document"
        )
      }

      # Return the output file
      "README.md"
    },
    format = "file"
  ),

  # Update package documentation
  tar_target(
    package_docs,
    {
      r_files  # Depend on R source files

      # Regenerate documentation
      devtools::document(quiet = TRUE)

      # List generated man files
      list.files("man", pattern = "\\.Rd$", full.names = TRUE)
    }
  ),

  # Build pkgdown site
  tar_target(
    pkgdown_site,
    {
      # Dependencies
      readme_md
      package_docs
      vignette_files

      # Check if we're in CI or local
      if(Sys.getenv("CI") != "") {
        # In CI, skip building
        message("Skipping pkgdown build in CI")
        NULL
      } else if(requireNamespace("pkgdown", quietly = TRUE)) {
        # Build site locally
        pkgdown::build_site(quiet = TRUE)
        "docs/index.html"
      } else {
        message("pkgdown not available")
        NULL
      }
    },
    format = "file"
  ),

  # Build Quarto website
  tar_target(
    quarto_site,
    {
      # Dependencies
      vignette_files

      # Check if _quarto.yml exists
      if(file.exists("_quarto.yml") && requireNamespace("quarto", quietly = TRUE)) {
        # Load package so vignettes can call library(millsratio)
        pkgload::load_all(export_all = FALSE, quiet = TRUE)
        quarto::quarto_render()
        "docs/index.html"
      } else {
        message("Quarto not configured")
        NULL
      }
    },
    format = "file"
  ),

  # Generate project structure for README
  tar_target(
    project_structure,
    {
      # Track file changes
      vignette_files
      r_files

      # Generate structure using fs - FIXED: removed max_depth argument
      if(requireNamespace("fs", quietly = TRUE)) {
        structure_text <- capture.output(
          fs::dir_tree(
            path = ".",
            recurse = 2,  # Use recurse with numeric depth instead
            type = "any",
            regexp = "^[^._]"  # Exclude hidden and _ prefixed
          )
        )

        # Filter out build artifacts
        structure_text <- structure_text[!grepl(
          "nix-shell-root|docs/|man/|Meta/|help/|_targets/|renv/",
          structure_text
        )]

        # Save to file for inclusion
        writeLines(structure_text, "project_structure.txt")
        "project_structure.txt"
      } else {
        message("fs package not available")
        NULL
      }
    },
    format = "file"
  ),

  # Check that all articles are referenced in _quarto.yml
  tar_target(
    check_quarto_config,
    {
      vignette_files

      if(file.exists("_quarto.yml")) {
        config <- yaml::read_yaml("_quarto.yml")

        # Get all .qmd files in articles/
        article_files <- list.files("articles", pattern = "\\.qmd$", full.names = FALSE)

        # Check if all are referenced in config
        # This is a simple check - could be more sophisticated
        config_text <- readLines("_quarto.yml")
        missing <- character()

        for(article in article_files) {
          article_ref <- file.path("articles", article)
          if(!any(grepl(article, config_text))) {
            missing <- c(missing, article)
          }
        }

        if(length(missing) > 0) {
          warning("Articles not in _quarto.yml: ", paste(missing, collapse = ", "))
        }

        list(
          articles = article_files,
          missing = missing,
          config_ok = length(missing) == 0
        )
      } else {
        list(articles = character(), missing = character(), config_ok = TRUE)
      }
    }
  ),

  # Summary report
  tar_target(
    documentation_report,
    {
      # Gather all documentation status
      list(
        readme_exists = file.exists(readme_md),
        readme_size = file.size(readme_md),
        vignette_count = length(vignette_files),
        man_count = length(list.files("man", pattern = "\\.Rd$")),
        pkgdown_built = !is.null(pkgdown_site),
        quarto_built = !is.null(quarto_site),
        structure_generated = !is.null(project_structure),
        quarto_check = check_quarto_config,
        last_updated = Sys.time()
      )
    }
  )
)

# Export the plan
documentation_plan
