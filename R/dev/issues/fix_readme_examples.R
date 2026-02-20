# Fix: README.qmd code examples and code-as-targets pattern
# Version: 0.2.2 -> 0.2.3
# Date: 2026-02-19
#
# Changes:
# 1. README.qmd:
#    - Removed R prompt '>' from library() call in Nix section
#    - Fixed rix() example: r_ver -> date, correct deps from DESCRIPTION,
#      commit SHA instead of branch, ide = "none"
#    - Replaced devtools::test()/check() with library() + conditional devtools
#    - Fixed citation URL (yourusername -> JohnGavin)
#
# 2. R/tar_plans/plan_doc_examples.R (NEW):
#    - 7 README code chunks stored as text targets
#    - Parse validation (syntax check) for each chunk
#    - Eval validation (runtime check) for each chunk
#    - Validation gate: pipeline fails if any example is broken
#
# 3. _targets.R:
#    - Added plan_doc_examples to combined plans list
#
# 4. Vignettes:
#    - Added output-fold: true to dashboard.qmd
#    - Added output-fold: true and code-summary to webr-playground.qmd
#
# Verification:
# grep '> library' README.qmd       # Should return nothing
# grep 'r_ver' README.qmd           # Should return nothing
# grep 'yourusername' README.qmd    # Should return nothing
# targets::tar_make()               # doc_examples_validation passes
