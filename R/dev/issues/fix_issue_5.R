# Fix Script for Issue #5: Documentation errors and missing dependencies
# Created: 2026-01-25
# Issue: https://github.com/JohnGavin/millsratio/issues/5

# PROBLEMS FIXED:

# 1. Incorrect Nix installation instructions
#    - Fixed in README.qmd: Clarified that default.sh calls default.R internally
#    - Fixed in readme-qmd-standard.md skill

# 2. Missing gt package dependency
#    - Added gt to DESCRIPTION Suggests field
#    - Will regenerate default.nix after this

# 3. WebR playground incorrect claims
#    - Fixed in webr-playground.qmd: Clarified that functions are manually defined
#    - Not loaded from package (since not on CRAN)

# 4. Syntax error in dashboard.qmd
#    - Fixed line 188: Changed 'function' to 'func_type' (reserved word issue)
#    - Updated line 194 to use new variable name

# 5. Missing article files
#    - Created articles/theory.qmd
#    - Created articles/applications.qmd
#    - Created articles/benchmarks.qmd

# 6. Missing references.bib
#    - Created references.bib with Mills, Cook, Johnson, and Sampford citations

# FILES MODIFIED:
# - README.qmd
# - articles/dashboard.qmd
# - articles/webr-playground.qmd
# - DESCRIPTION
# - /Users/johngavin/docs_gh/llm/.claude/skills/readme-qmd-standard.md

# FILES CREATED:
# - references.bib
# - articles/theory.qmd
# - articles/applications.qmd
# - articles/benchmarks.qmd
# - R/dev/issues/fix_issue_5.R (this file)

# NEXT STEPS:
# 1. Regenerate default.nix: source("default.R")
# 2. Test website build: quarto::quarto_render()
# 3. Run checks: devtools::check()
# 4. Push changes: usethis::pr_push()
# 5. Monitor CI
# 6. Merge PR when CI passes

# FINAL RESOLUTION:
# - gt package added to DESCRIPTION and now works
# - microbenchmark removed from DESCRIPTION due to C compiler issues in Nix
# - benchmarks.qmd updated to make microbenchmark optional
# - All articles now build except webr-playground (expected - no webr filter)