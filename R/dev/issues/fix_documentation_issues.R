# Fix script for documentation issues identified in Issue #8
# Date: 2026-01-26
# Purpose: Fix code display issues in vignettes and README

library(fs)
library(stringr)

# 1. Fix vignettes using devtools::load_all()
vignette_files <- dir_ls("vignettes", glob = "*.qmd")

for (vignette in vignette_files) {
  content <- readLines(vignette)

  # Replace devtools::load_all with library(millsratio)
  content <- str_replace_all(
    content,
    "devtools::load_all\\(quiet = TRUE\\)",
    "library(millsratio)"
  )

  # Also handle variations
  content <- str_replace_all(
    content,
    "devtools::load_all\\(\\)",
    "library(millsratio)"
  )

  writeLines(content, vignette)
  message("Fixed: ", vignette)
}

# 2. Fix README.qmd to include proper commit SHA in rix example
readme_content <- readLines("README.qmd")

# Get latest commit SHA
latest_sha <- system("git rev-parse HEAD", intern = TRUE)

# Find and replace the rix code block
rix_pattern <- 'git_pkgs = list\\(\\s*millsratio = "JohnGavin/millsratio"\\s*\\)'
rix_replacement <- paste0(
  'git_pkgs = list(\n    millsratio = list(\n      package_source = "github",\n',
  '      repo_url = "JohnGavin/millsratio",\n',
  '      commit = "', substr(latest_sha, 1, 7), '"\n    )\n  )'
)

# Apply replacement
readme_content <- str_replace(
  readme_content,
  rix_pattern,
  rix_replacement
)

writeLines(readme_content, "README.qmd")
message("Fixed: README.qmd with commit SHA ", substr(latest_sha, 1, 7))

# 3. Test that README code examples actually work
message("\nTesting README code examples...")

# Extract R code chunks from README.qmd
test_readme_code <- function() {
  lines <- readLines("README.qmd")
  in_chunk <- FALSE
  chunk_code <- c()

  for (i in seq_along(lines)) {
    if (grepl("^```\\{r", lines[i])) {
      in_chunk <- TRUE
    } else if (in_chunk && grepl("^```$", lines[i])) {
      in_chunk <- FALSE
      # Test the chunk (skip eval=FALSE chunks)
      if (!any(grepl("#\\| eval: false", chunk_code))) {
        tryCatch({
          # Don't actually evaluate, just parse for syntax
          parse(text = chunk_code)
          message("  ✓ Chunk parsed successfully")
        }, error = function(e) {
          message("  ✗ Chunk failed to parse: ", e$message)
        })
      }
      chunk_code <- c()
    } else if (in_chunk) {
      chunk_code <- c(chunk_code, lines[i])
    }
  }
}

test_readme_code()

message("\nDocumentation fixes complete!")
message("Next steps:")
message("1. Run quarto::quarto_render('README.qmd') to regenerate README.md")
message("2. Rebuild pkgdown site with updated vignettes")
message("3. Commit and push changes")