# Fix for Issue #17: devtools::check() warnings, notes, and tar_make() failure
# https://github.com/JohnGavin/millsratio/issues/17
#
# Changes:
# 1. Added VignetteBuilder: quarto to DESCRIPTION
# 2. Moved bslib, DT, purrr from Imports to Suggests (only used in inst/shiny)
# 3. Moved scales from Suggests to Imports (used in R/visualization.R)
# 4. Added utils::globalVariables() in R/visualization.R for bare column names
# 5. Updated .Rbuildignore with missing entries (HTML artifacts, dev notes, etc.)
# 6. Fixed quarto_site target: pkgload::load_all() before quarto::quarto_render()
# 7. Bumped version 0.2.1 -> 0.2.2
#
# Version bump: 0.2.1 -> 0.2.2
